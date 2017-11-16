local meta = FindMetaTable("Player")
if not meta then return end

function meta:RemoveAllStatus(bSilent, bInstant)
	if bInstant then
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent:Remove()
			end
		end
	else
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
		end
	end
end

function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
	local removed

	for _, ent in pairs(ents.FindByClass("status_"..sType)) do
		if ent:GetOwner() == self and not (sExclude and ent:GetClass() == "status_"..sExclude) then
			if bInstant then
				ent:Remove()
			else
				ent.SilentRemove = bSilent
				ent:SetDie()
			end
			removed = true
		end
	end

	return removed
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:IsValid() and ent:GetOwner() == self then return ent end
end

function meta:GiveStatus(sType, fDie)
	local cur = self:GetStatus(sType)
	if cur then
		if fDie then
			cur:SetDie(fDie)
		end
		cur:SetPlayer(self, true)
		return cur
	else
		local ent = ents.Create("status_"..sType)
		if ent:IsValid() then
			ent:Spawn()
			if fDie then
				ent:SetDie(fDie)
			end
			ent:SetPlayer(self)
			return ent
		end
	end
end

function meta:CustomGesture(gesture)
	self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, gesture)
	umsg.Start("cusges")
		umsg.Entity(self)
		umsg.Short(gesture)
	umsg.End()
end

function meta:RefreshPlayerModel()
	local bodytype = BODY_TYPE_NONE
	local armoritem = self:GetWearable(WEARABLE_SLOT_BODY)
	if armoritem then
		if armoritem.PlayerModel then
			self:SetModel(armoritem.PlayerModel)
			return
		end

		if armoritem.BodyType then
			bodytype = armoritem.BodyType
		end
	end

	local desired = player_manager.TranslatePlayerModel(self:GetInfo("cl_playermodel"))
	local lowerdesired = string.lower(desired)

	local bodytable = BODY_TYPE_MODELS[bodytype]
	if bodytable then
		self:SetModel(table.HasValue(bodytable, lowerdesired) and desired or bodytable[1] or desired)
	else
		self:SetModel("models/player/kleiner.mdl")
	end
end

function meta:Retribution(time)
	local zonedata = AllZones()[self:GetZone()]
	if not zonedata or zonedata.Ruleset ~= RULESET_PROTECTED or time == 0 then
		self:RemoveStatus("retribution", false, true)
	elseif not IsValid(self.status_retribution) then
		local status = self:GiveStatus("retribution")
		if status:IsValid() then
			if time then
				status:SetStartTime(CurTime() + time)
			elseif self:IsMurderer() then
				status:SetStartTime(CurTime() + 5)
			else
				status:SetStartTime(CurTime() + 10)
			end
		end
	end
end

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

function meta:OpenInventory()
	self:SendLua("MySelf:OpenInventory()")
end

function meta:CloseInventory()
	self:SendLua("MySelf:CloseInventory()")
end

function meta:ToggleInventory()
	self:SendLua("MySelf:ToggleInventory()")
end

function meta:OpenSkills()
	self:SendLua("MySelf:OpenSkills()")
end

function meta:CloseSkills()
	self:SendLua("MySelf:CloseSkills()")
end

function meta:ToggleSkills()
	self:SendLua("MySelf:ToggleSkills()")
end

function meta:SecondTick()
	if not self:CallMonsterFunction("SecondTick") then
		self:HealthRegeneration()
		self:CheckDrowning()
	end
end

local function CreateRagdoll(pl)
	if pl:IsValid() then pl:OldCreateRagdoll() end
end

local function SetModel(pl, mdl)
	if pl:IsValid() then
		pl:SetModel(mdl)
		timer.Simple(0, function() CreateRagdoll(pl) end)
	end
end

meta.OldCreateRagdoll = meta.CreateRagdoll
function meta:CreateRagdoll()
	local status = self.status_overridemodel
	if status and status:IsValid() then
		timer.Simple(0, function() SetModel(self, status:GetModel()) end)
		status:SetRenderMode(RENDERMODE_NONE)
	else
		self:OldCreateRagdoll()
	end
end

function meta:CheckDrowning()
	if self:Alive() and self:IsSubmerged() then
		self:StartDrowning()
	end
end

function meta:StartDrowning()
	if not self:DrowningStatusValid() then
		self:GiveStatus("drowning"):SetStartTime(CurTime())
	end
end

function meta:DrowningStatusValid()
	return IsValid(self:GetStatus("drowning"))
end

function meta:IsDrowning()
	local status = self:GetStatus("drowning")
	return status and status:IsValid() and status:IsDrowning()
end

function meta:StopDrowning()
	self:RemoveStatus("drowning", false, true)
end

function meta:IsMoving()
	return self:GetVelocity():Length2D() > 0.5
end

function meta:HealthRegeneration()
	if self:Alive() then
		local maxhealth = self:GetMaxHealth()
		local health = self:Health()
		local rate = 1 - (health / maxhealth)

		if self:IsMoving() then
			rate = rate * 0.75
		end

		if self:Crouching() and self:OnGround() then
			rate = rate * 1.25
		end

		local newcarry = self.m_CarryOverRegeneration + rate
		if newcarry >= 1 then
			local toheal = math.floor(newcarry)
			self:SetHealth(math.min(maxhealth, health + toheal))
			self.m_CarryOverRegeneration = newcarry - toheal
		else
			self.m_CarryOverRegeneration = newcarry
		end
	end
end

function meta:SetupPlayerInventory()
	if self:GetContainer() then return end

	local container = Item({["Owner"] = self:UniqueID()}, "container_playerinventory")
	container:SetDroppable(false)
	self:SetContainer(container)
end

function meta:GoToZone(dataname)
	local zonetab = GetAllZones(dataname)
	if not zonetab then return false end

	--[[local spawn = zone.GetBestHumanSpawn(dataname)
	if spawn then
		self:SetPos(spawn:GetPos())
		return true
	end]]

	return false
end

function meta:Respawn()
	if self:IsGhost() then
		self:SetGhost(false)
		self:ForceRespawn()
		self:SetHealth(math.ceil(self:GetMaxHealth() * 0.2))
		--self:SetStamina(0, true)
		self:SetMana(0, true)

		self:SendMessage("You have been resurrected!~sweapons/stunstick/alyx_stunner1.wav", "COLOR_LIMEGREEN", true)
	else
		self:ForceRespawn()
	end
end

function meta:EquipByUID(uid, silent, onlyputon)
	local item = Items[uid]
	if item then
		return self:EquipItem(item, silent, onlyputon)
	end
end

function meta:EquipAllByUIDs(tab, silent, onlyputon)
	if not tab then return end

	for _, uid in pairs(tab) do
		self:EquipByUID(uid, silent, onlyputon)
	end
end

function meta:EquipItem(item, silent, onlyputon)
	if item.WearableSlot and item:GetParent() == self:GetContainer() then
		if item.WearableSlot == WEARABLE_SLOT_WEAPON then
			return gamemode.Call("PlayerUseWeapon", self, item, onlyputon, silent)
		elseif item.WearableSlot then
			return gamemode.Call("PlayerUseWearable", self, item, onlyputon, silent)
		end
	end

	return false
end

function meta:UpdateMonsterClass(filter)
	self:SetMonsterClass(self:GetMonsterClass(), true, filter)
end

function meta:ChangeToHuman()
	if not self:IsMonster() then return end

	local tab = {}
	self:InsertRPGData(tab)
	self.MonsterData = tab

	self:StripWeapons()
	self:SetTeam(TEAM_HUMAN)
	--self:RefreshGuild()

	if self.RPGHumanData then
		gamemode.Call("PlayerInitialSpawnBasedOn", self, self.RPGHumanData)
		--self.RPGHumanData = nil
	end

	timer.Simple(0.25, function() self:ForceRespawn(true) end)

	NDB.SaveInfo(self)
end

function meta:ChangeToMonster()
	if self:IsMonster() then return end

	local tab = {}
	self:InsertRPGData(tab)
	self.RPGHumanData = tab

	self:StripWeapons()
	self:GuildNoLongerPlaying()
	self:SetTeam(TEAM_MONSTER)

	if self.MonsterData then
		gamemode.Call("PlayerInitialSpawnBasedOn", self, self.MonsterData)
		--self.MonsterData = nil
	end

	if self:GetMonsterClassTable() == nil then
		self:SetMonsterClass(1)
	end

	timer.Simple(0.25, function() self.ForceRespawn(true) end)

	NDB.SaveInfo(self)
end

function meta:GuildNoLongerPlaying()
	local guildid = self:GetGuildID()
	if guildid ~= 0 then
		PrintGuildMessage(guildid, HUD_PRINTTALK, "<defc=255,0,0>Guild member <white>"..self:Name().."</white> is no longer playing.")
	end
end

function meta:RefreshGuild()
	if self:IsMonster() then return end

	if self.RPGGuildUID then
		for _, guild in pairs(GetAllGuilds()) do
			if guild.UID == self.RPGGuildUID then
				PrintGuildMessage(guild.Index, HUD_PRINTTALK, "<defc=30,255,30>Guild member <white>"..self:Name().."</white> is now playing.")
				self:SetGuild(guild.Index)
				break
			end
		end

		self:PrintMessage(HUD_PRINTTALK, "<defc=255,0,0>The guild you were in no longer exists!")
		self.RPGGuildUID = nil
	end
end

function meta:LeaveGuild()
	if self:IsInGuild() then
		gamemode.Call("LoadGuilds", true)

		local guild = self:GetGuild()
		if not guild then return end

		self:SetTeam(TEAM_HUMAN)
		self.RPGGuildUID = nil
		guild.Members = guild.Members - 1

		if guild.Members == 0 then
			self:PrintMessage(HUD_PRINTTALK, tostring(guild.Name).." had no members left so it was disbanded.")
			NDB.SaveInfo(self)
			DisbandGuild(guild.Index)
		else
			PrintGuildMessage(guild.Index, HUD_PRINTTALK, self:NoParseName().." has left the guild.")
			NDB.SaveInfo(self)
			gamemode.Call("SaveGuilds")
			UpdateGuild(guild.Index)
		end
	end
end

function meta:JoinGuild(id, force)
	gamemode.Call("LoadGuilds", true)

	local guild = GetAllGuilds()[id]
	if not guild then return end

	if self:IsInGuild() then
		if not force then return end
		self:LeaveGuild()
	end

	self:SetGuild(id)
	self.RPGGuildUID = guild.UID
	guild.Members = guild.Members + 1

	PrintGuildMessage(guild.Index, HUD_PRINTTALK, self:NoParseName().." has joined the guild.")

	NDB.SaveInfo(self)

	gamemode.Call("SaveGuilds")
	UpdateGuild(id)
end

function meta:SetGuild(id)
	local guild = GetAllGuilds()[id]
	if not guild then return end

	self:SetTeam(TEAM_HUMAN + id)
end

function meta:UpdateSkills()
	self:SendLongString(LONGSTRING_UPDATESKILLS, Serialize(self.Skills))
end

function meta:SetSkill(skillid, amount, noupdate)
	local old = self:GetSkill(skillid)
	if old ~= amount then
		self.Skills[skillid] = amount
		gamemode.Call("PlayerSkillChanged", self, skillid, amount)
	end

	if not noupdate then
		umsg.Start("updskill", self)
			umsg.Short(skillid)
			umsg.Float(amount)
		umsg.End()
	end
end

function meta:SetCriminal(tim)
	local old = self:GetNetworkedFloat("crimtime", 0)
	self:SetNetworkedFloat("crimtime", math.min(tim, CurTime() + CRIMINAL_MAXIMUM))
	if self:IsCriminal() and old ~= self:GetNetworkedFloat("crimtime", 0) then
		local zonedata = AllZones()[self:GetZone()]
		if zonedata and zonedata.Ruleset == RULESET_PROTECTED then
			self:Retribution()
		end
	end
end

function meta:HostileAction(pl)
	if not pl or pl == self or not pl:IsValid() or not pl:IsPlayerCharacter() then return end

	if self ~= pl.LastAttacker and CurTime() < pl.LastAttacked + 3 and pl.LastAttacker:IsPlayer() then
		pl.LastAttacker2 = pl.LastAttacker
		pl.LastAttacked2 = CurTime()
	end
	pl:SetLastAttacker(self)

	if pl:IsMonster() or self:IsMonster() or self:IsInSameGuild(pl) or pl:IsGuildEnemy(self) then return end

	if pl:IsCriminal() then
		pl:CapCriminal(CurTime() + CRIMINAL_ATTACKED)
	elseif self:IsCriminal() then
		self:CapCriminal(self:GetCriminal() + CRIMINAL_SUBSEQUENT)
	else
		self:CapCriminal(CurTime() + CRIMINAL_INITIAL)
	end
end
meta.HarmfulAction = meta.HostileAction

function meta:BeneficialAction(pl)
	if not pl or pl == self or not pl:IsValid() or not pl:IsPlayerCharacter() or self:IsMonster() then return end

	if pl:IsMonster() then
		self:CapCriminal(CurTime() + CRIMINAL_HELPMONSTER)
	elseif pl:IsCriminal() and not self:IsInSameGuild(pl) then
		self:CapCriminal(CurTime() + CRIMINAL_HELPCRIMINAL)
	end
end
meta.HelpfulAction = meta.BeneficialAction

--[[function meta:SetStamina(stamina, send)
	self.Stamina = stamina
	self.StaminaBase = CurTime()
	if send then
		self:UpdateStamina()
	end
end]]

function meta:SetMana(mana, send)
	self.Mana = mana
	self.ManaBase = CurTime()
	if send then
		self:UpdateMana()
	end
end

--[[function meta:UpdateStamina()
	umsg.Start("SLS", self)
		umsg.Float(self.Stamina)
		umsg.Float(self.StaminaBase)
	umsg.End()
end]]

function meta:UpdateMana()
	umsg.Start("SLM", self)
		umsg.Float(self.Mana)
		umsg.Float(self.ManaBase)
	umsg.End()
end

meta.OldSetMaxHealth = FindMetaTable("Entity").SetMaxHealth
function meta:SetMaxHealth(num)
	num = math.ceil(num)
	self:SetDTInt(3, num)
	self:OldSetMaxHealth(num)
	if num < self:Health() then
		self:SetHealth(num)
	end
end

meta.OldExitVehicle = meta.ExitVehicle
function meta:ExitVehicle()
	local veh = self:GetVehicle()
	if veh and veh:IsValid() then
		self:OldExitVehicle()

		local vehbase = veh:GetNetworkedEntity("vehicle", NULL)
		if vehbase.Exit then
			vehbase:Exit(pl, veh)
		end
	end
end

meta.OldGive = meta.Give
function meta:Give(wep)
	self.AllowWeaponPickup = true
	self:OldGive(wep)
	self.AllowWeaponPickup = false
end

function meta:KnockDown(tim)
	if self:Alive() and not self:InVehicle() then
		self:GiveStatus("knockdown", tim or 5)
		self.VelocityRecovery = true

		self:HitReset()
	end
end

function meta:SetMaxMana(amount, regeneration)
	self.MaxMana = amount
	self.ManaRegenerate = regeneration
	self:SendLua("MySelf:SetMaxMana("..amount..","..regeneration..")")
end

--[[function meta:SetMaxStamina(amount, regeneration)
	self.MaxStamina = amount
	self.StaminaRegenerate = regeneration
	self:SendLua("MySelf:SetMaxStamina("..amount..","..regeneration..")")
end]]

meta.OldFreeze = meta.Freeze
function meta:Freeze(bFreeze)
	self.m_IsFrozen = bFreeze
	self:OldFreeze(bFreeze)
end

function meta:SetTeamID(iTeam)
	self:SetTeam(iTeam)
end

function meta:LMR(int, args)
	umsg.Start("lmr", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:LMG(int, args)
	umsg.Start("lmg", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:LM(int, args)
	umsg.Start("lm", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:SetLastAttacker(attacker)
	if attacker ~= self then
		self.LastAttacker = attacker
		self.LastAttacked = CurTime()
	end
end

function meta:GetLastAttacker()
	return self.LastAttacker, self.LastAttacked
end

function meta:ClearLastAttacker()
	self.LastAttacker = NULL
	self.LastAttacked = 0
end

function meta:UpdateInventory(pl)
	local container = self:GetContainer()
	if container then container:Sync() end
end
meta.UpdateContainer = meta.UpdateInventory

function meta:ForceRespawn(nostrip)
	if not nostrip then
		self:StripWeapons()
	end
	self.LastDeath = CurTime()
	self:RemoveAllStatus(true, true)
	self:Spawn()
end

function meta:CreatePlayerCorpse()
	local playerangles = self:GetAngles()
	local playerpos = self:GetPos()
	local startpos = playerpos + Vector(0, 0, 8)
	local endpos = playerpos + Vector(0, 0, -64)

	local tr = util.TraceLine({start = startpos, endpos = endpos, mask = MASK_PLAYERSOLID_BRUSHONLY, filter = self})
	if not tr.Hit then
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		mins.z = 0
		maxs.z = 2
		tr = util.TraceHull({start = startpos, endpos = endpos, mask = MASK_PLAYERSOLID_BRUSHONLY, filter = self, mins = mins, maxs = maxs})
	end

	if tr.Hit then
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), 270)
		ang:RotateAroundAxis(ang:Up(), playerangles.yaw)

		playerangles = ang
		playerpos = tr.HitPos
	else
		playerpos = self:GetPos()
	end

	local ent = SpawnItem(CORPSE_ITEMCLASS)
	if ent:IsValid() then
		ent:SetPos(playerpos)
		ent:SetAngles(playerangles)
		ent:SetPlayer(self)
		ent:Spawn()
		ent:Decay(CurTime() + PLAYERCORPSE_DECAY)
		-- TODO: Transfer loot to corpse. Less decay if empty.
	end
end

GM.GibData = {
	["humanhead"] = {Item = "head", Bone = "ValveBiped.Bip01_Head1", Rotation = Angle(0, 270, 270)},
	["humantorso"] = {Item = "torso", Bone = "ValveBiped.Bip01_Spine2", Rotation = Angle(90, 90, 180)},
	["humanleftfoot"] = {Item = "foot", Bone = "ValveBiped.Bip01_L_Foot", Rotation = Angle(90, 0, 0)},
	["humanrightfoot"] = {Item = "foot", Bone = "ValveBiped.Bip01_R_Foot", Rotation = Angle(90, 0, 0)},
	["humanlefthand"] = {Item = "hand", Bone = "ValveBiped.Bip01_L_Hand", Rotation = Angle(0, 90, 180)},
	["humanrighthand"] = {Item = "hand", Bone = "ValveBiped.Bip01_R_Hand", Rotation = Angle(180, 90, 0)},
	["humanleftarm"] = {Item = "arm", Bone = "ValveBiped.Bip01_L_Forearm", Rotation = Angle(0, 90, 180)},
	["humanrightarm"] = {Item = "arm", Bone = "ValveBiped.Bip01_R_Forearm", Rotation = Angle(180, 90, 180)},
	["humanleftleg"] = {Item = "leg", Bone = "ValveBiped.Bip01_L_Calf", Rotation = Angle(0, 90, 0)},
	["humanrightleg"] = {Item = "leg", Bone = "ValveBiped.Bip01_R_Calf", Rotation = Angle(0, 90, 180)}
}

function meta:CreateGib(gibtype)
	local gibdata = GAMEMODE.GibData[gibtype]
	if not gibdata then return NULL end

	local itemtype = gibdata.Item or "giblet"

	local ent = SpawnItem(itemtype)
	if ent:IsValid() then
		local item = ent:GetItem()
		if item then
			item.Name = self:RPGName().." "..item.Name
			item.PlayerUID = self:UniqueID()
		end

		local boneid = self:LookupBone(gibdata.Bone)
		if boneid > 0 then
			local pos, ang = self:GetBonePosition(boneid)

			local offset = gibdata.Offset
			if offset then
				pos = pos + offset.z * ang:Up() + offset.x * ang:Right() + offset.y * ang:Forward()
			end

			local rotation = gibdata.Rotation
			if rotation then
				ang:RotateAroundAxis(ang:Right(), rotation.pitch)
				ang:RotateAroundAxis(ang:Up(), rotation.yaw)
				ang:RotateAroundAxis(ang:Forward(), rotation.roll)
			end

			ent:SetPos(pos)
			ent:SetAngles(ang)
		else
			ent:SetPos(self:EyePos())
			ent:SetAngles(self:GetAngles())
		end

		ent:Spawn()

		ent:ResetDecay()

		return ent
	end

	return NULL
end

function meta:CreateGibs()
	if self:CallMonsterFunction("CreateGibs") then return end

	local gibs = {
		self:CreateGib("humanhead"),
		self:CreateGib("humantorso"),
		self:CreateGib("humanleftarm"),
		self:CreateGib("humanrightarm"),
		self:CreateGib("humanleftleg"),
		self:CreateGib("humanrightleg"),
		self:CreateGib("humanlefthand"),
		self:CreateGib("humanrighthand"),
		self:CreateGib("humanleftfoot"),
		self:CreateGib("humanrightfoot")
	}

	local center = self:GetPos()
	local vel = self:GetVelocity()
	local speed = vel:Length()
	for _, gib in pairs(gibs) do
		if gib:IsValid() then
			local phys = gib:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous((gib:GetPos() - center) * 2 + vel * math.Rand(0.8, 1) + math.Rand(-0.2, 0.2) * speed * VectorRand():Normalize())
				phys:AddAngleVelocity(speed * 0.02 * VectorRand())
			end
		end
	end
end

-- TODO: The gibs should use ThrowFromPosition.
function meta:Gib(dmginfo)
	local ragdoll = self:GetRagdollEntity()
	if ragdoll and ragdoll:IsValid() then ragdoll:Remove() end

	if self:CallMonsterFunction("Gib", dmginfo) then return end

	local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:EyePos())
		effectdata:SetScale(self.GibEffects)
		effectdata:SetRadius(self.BloodDye or 0)
	util.Effect("gib_player", effectdata, true, true)

	self:CreateGibs()
end
