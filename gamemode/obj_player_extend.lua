-- Reserved DT variables:
-- Int 3: Replicated maximum health

local meta = FindMetaTable("Player")
if not meta then return end

function meta:Thought(str)
	self:PrintMessage(HUD_PRINTTALK, str)
	self:PrintMessage(HUD_PRINTCONSOLE, str)
end

function meta:Think()
	self:CallMonsterFunction("Think")
end

function meta:CanUnderstand(other)
	return self == other or not other:IsPlayer() or not other:IsMonster() or self:IsMonster() and other:GetMonsterClassTable().Group == self:GetMonsterClassTable().Group
end

function meta:GetDrowningThreshold()
	return self:GetSkill(SKILL_VITALITY) * 0.4 + 20
end

function meta:GetRagdollEyes()
	local Ragdoll = self:GetRagdollEntity()
	if not Ragdoll then return end

	local att = Ragdoll:GetAttachmentByName("eyes")
	if att then
		att.Pos = att.Pos + att.Ang:Forward() * -2
		att.Ang = att.Ang

		return att.Pos, att.Ang
	end
end

local EyeHullMins = Vector(-8, -8, -8)
local EyeHullMaxs = Vector(8, 8, 8)
function meta:NewEyePos()
	local attach = self:GetAttachmentByName("eyes")
	if attach then
		local startpos = self:EyePos()
		local tr = util.TraceHull({start = startpos, endpos = attach.Pos + attach.Ang:Forward() * -2.2, mask = MASK_SOLID, filter = player.GetAll(), mins = EyeHullMins, maxs = EyeHullMaxs})
		if tr.Hit then
			return tr.HitPos + (tr.HitPos - startpos):GetNormalized() * 4
		end

		return tr.HitPos
	end

	return self:EyePos()
end

local ViewHullMins = Vector(-8, -8, -8)
local ViewHullMaxs = Vector(8, 8, 8)
function meta:GetCameraPos(origin, angles)
	if self.ThirdPerson then
		origin = origin or self:EyePos()
		angles = angles or self:EyeAngles()

		local allplayers = player.GetAll()
		local tr = util.TraceHull({start = origin, endpos = origin + angles:Right() * self.ViewOffset, mask = MASK_SOLID, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
		local startpos = tr.HitPos + tr.HitNormal * 4
		local tr2 = util.TraceHull({start = startpos, endpos = startpos + angles:Forward() * -92, mask = MASK_SOLID, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
		return tr2.HitPos + tr2.HitNormal * 4
	else
		origin = self:NewEyePos()
	end

	return origin
end
meta.GetCameraPosition = meta.GetCameraPos

function meta:DropItem(item, todrop)
	if CurTime() < (self.NextItemDrop or 0) or not item:IsDroppableBy(self) then return end

	local amount = item:GetAmount()
	todrop = math.min(amount, math.max(1, math.ceil(todrop or 1)))

	if not item:IsDroppable() then return end

	local itemdata = GetItemData(item.DataName)
	if itemdata.OnDrop and itemdata.OnDrop(item, self) then return end

	-- Make a copy and drop that instead.
	if todrop < amount then
		local copy = item:Copy()
		copy:SetAmount(todrop)
		item:SetAmount(amount - todrop)
		item = copy
	end

	item:CallParentContentsChanged()

	local ent = item:Spawn()
	if ent:IsValid() then
		local eyepos = self:NewEyePos()
		ent:SetPos(eyepos)
		ent:SetAngles(self:EyeAngles())
		ent:Spawn()
		ent:ResetDecay()

		local boundingradius = ent:BoundingRadius()
		local tr = util.TraceHull({start = eyepos, endpos = eyepos + self:GetAimVector() * math.max(32, boundingradius), mins = ent:OBBMins(), maxs = ent:OBBMaxs(), filter = {self, ent}})
		local droppos = tr.HitPos + tr.HitNormal * boundingradius
		ent:SetPos(droppos)

		if itemdata.OnDropped and itemdata.OnDropped(item, self, ent) then return end

		local displayname = item:GetDisplayName()
		self:SendMessage("You dropped "..displayname..".")
		PrintMessageToVisibleRadius(HUD_PRINTTALK, "You notice "..self:NoParseName().." drop "..displayname..".", droppos, RADIUS_GENERICACTIONMESSAGE, self)
	end

	self.NextItemDrop = ITEM_DROPDELAY
end

function meta:InteractItem(item, arguments)
	if not item:IsUsableBy(self) then return false end

	local itemdata = item:GetItemData()
	return itemdata.OnInteract and itemdata.OnInteract(item, pl, arguments)
end

function meta:UseItem(item)
	if not item:IsUsableBy(self) then return false end

	local data = item:GetItemData()

	if not data.OnUse then
		self:SendMessage("You can't think of a way to use "..item:GetDisplayName()..".", "COLOR_RED")
		return false
	end

	local ret = data.OnUse(item, self)
	if ret == ITEM_ONUSE_DECREMENT then
		item:SetAmount(item:GetAmount() - 1)
	elseif ret == ITEM_ONUSE_DESTROY then
		item:Destroy()
	end

	return true
end

function meta:MoveItem(item, x, y)
	if item:IsMoveableBy(self) then
		item:Move(x, y)
		return true
	end

	return false
end

function meta:TransferItem(item, newcontainer, x, y)
	if item:IsTransferableBy(self, newcontainer) then
		--item:CallParentContentsChanged()
		item:SetParent(newcontainer)

		if x and y then
			item:Move(x, y)
		end

		return true
	end

	return false
end

meta.OldAlive = meta.Alive
function meta:Alive()
	if self:IsGhost() then return false end

	return self:OldAlive()
end

function meta:SetGhost(ghost)
	if ghost then
		self:GiveStatus("playerghost")
	else
		self:RemoveStatus("playerghost", false, true)
	end
end

function meta:IsLivingHuman()
	return self:Alive() and not self:IsMonster()
end

function meta:GetGhost()
	return self.m_PlayerGhost
end

function meta:IsGhost()
	return self.m_PlayerGhost ~= nil
end

function meta:HitWithProjectile(ent, data)
	return self:StatusWeaponHook2("HitWithProjectile", ent, data)
end

function meta:InsertRPGData(tab)
	tab.FirstJoin = self.FirstJoin
	tab.Map = self.Map or game.GetMap()
	tab.Position = self:GetPos()
	tab.Angles = self:GetAngles()
	tab.Velocity = self:GetVelocity()
	tab.Health = self:Health()
	tab.Mana = self:GetMana()
	--tab.Stamina = self:GetStamina()
	tab.RPGIsMonster = self:IsMonster()
	tab.IsDead = not self:Alive() and not tab.RPGIsMonster
	tab.MonsterClass = self:GetMonsterClass()
	tab.EquippedUIDs = self:GetEquippedUIDs()
	tab.ItemData = self:GetContainer()
	tab.Skills = self.Skills
	tab.ShortTermMurders = self:GetShortTermMurders()
	tab.LongTermMurders = self:GetLongTermMurders()
	tab.MurderTimer = self.MurderTimer
	tab.Banks = self.Banks
end

function meta:GetEquipment(slot, returnentity)
	for _, status in pairs(ents.FindByClass("status_*")) do
		if status:GetOwner() == self and status:IsValid() and not status.Removing then
			local item = status:GetItem()
			if item and item.WearableSlot and item.WearableSlot == slot then return returnentity and status or item end
		end
	end
end
meta.GetWearable = meta.GetEquipment

function meta:RefreshFootSteps()
	local mdl = string.lower(self:GetModel())
	for bodytype, models in pairs(BODY_TYPE_MODELS) do
		if table.HasValue(models, mdl) then
			if FOOTSTEP_SETS[bodytype] then
				self.FootStepSet = FOOTSTEP_SETS[bodytype]
				return
			end
		end
	end

	self.FootStepSet = nil
end

function meta:GetEquippedUIDs()
	local tab = {}

	local wep = self:GetActiveWeapon()
	if wep:IsValid() then
		local item = wep:GetItem()
		if item then
			table.insert(tab, item.ID)
		end
	end

	for _, status in pairs(ents.FindByClass("status_*")) do
		if status:GetOwner() == self then
			local item = status:GetItem()
			if item then
				table.insert(tab, item.ID)
			end
		end
	end

	return tab
end

function meta:CallMonsterFunction(funcname, ...)
	if self:IsMonster() then
		local tab = self:GetMonsterClassTable()
		if tab and tab[funcname] then
			return tab[funcname](tab, self, ...)
		end
	end
end

function meta:ImplicitCallMonsterFunction(funcname, ...)
	local tab = self:GetMonsterClassTable()
	if tab and tab[funcname] then
		return tab[funcname](tab, self, ...)
	end
end

local deftab = {}
function meta:ResetData(tab)
	tab = tab or deftab

	self:SetHull(tab.HullMin or PLAYER_HULL_MIN, tab.HullMax or PLAYER_HULL_MAX)
	self:SetHullDuck(tab.HullDuckMin or PLAYER_HULL_DUCKED_MIN, tab.HullDuckMax or PLAYER_HULL_DUCKED_MAX)
	self:SetCollisionBounds(tab.HullMin or PLAYER_HULL_MIN, tab.HullMax or PLAYER_HULL_MAX)
	self:SetViewOffset(tab.ViewOffset or PLAYER_VIEWOFFSET)
	self:SetViewOffsetDucked(tab.ViewOffsetDucked or PLAYER_VIEWOFFSET_DUCKED)
	self:SetStepSize(tab.StepSize or PLAYER_STEPSIZE)

	self:SetJumpPower(tab.JumpPower or PLAYER_JUMPPOWER)

	if tab.Speed then
		self:SetWalkSpeed(tab.Speed)
		self:SetRunSpeed(tab.Speed)
		self:SetMaxSpeed(tab.Speed)
	end

	if SERVER then
		--[[local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(tab.Mass or PLAYER_MASS)
		end]]

		if tab.Health then
			self:SetMaxHealth(tab.Health)
		end
	end

	--[[if tab.Stamina then
		self:SetMaxStamina(tab.Stamina, tab.StaminaRegenerate or self.StaminaRegenerate or 1)
	end]]

	if tab.Mana then
		self:SetMaxMana(tab.Mana, tab.ManaRegenerate or self.ManaRegenerate or 1)
	end

	if CLIENT then
		self:SetModelScale(tab.ModelScale or PLAYER_MODELSCALE, 0)
	end
end

function meta:SetMonsterClass(id, onlyupdate, filter)
	local classtab = MonsterClasses[id]
	if not classtab then return false end

	if not onlyupdate then
		self.m_Class = id
		self.m_ClassTable = classtab
		if self:IsMonster() then
			self:ResetData(classtab)
		end
	end

	if SERVER then
		umsg.Start("setmonsterclass", filter)
			umsg.Entity(self)
			umsg.Short(id)
		umsg.End()
	end

	return true
end

function meta:GetMonsterClass()
	return self.m_Class --return self:GetDTInt(2)
end

function meta:GetMonsterClassTable()
	return self.m_ClassTable --return MonsterClasses[self:GetMonsterClass()]
end

function meta:SendHint()
end

function meta:GuildAttitude(pl)
	return GuildAttitude(self:GetGuildID(), pl:GetGuildID())
end

function meta:IsGuildEnemy(pl)
	return self:IsInGuild() and GuildIsEnemy(self:GetGuildID(), pl:GetGuildID())
end

function meta:IsGuildAlly(pl)
	return self:IsInGuild() and GuildIsAlly(self:GetGuildID(), pl:GetGuildID())
end

function meta:IsGuildFriendly(pl)
	return self:IsInGuild() and GuildIsFriendly(self:GetGuildID(), pl:GetGuildID())
end

function meta:IsInSameGuild(pl)
	return self:IsInGuild() and pl:GetGuildID() == self:GetGuildID()
end

function meta:IsGuildLeader()
	local guild = self:GetGuild()
	return guild and guild.Owner == self:UniqueID()
end

function meta:IsInGuild()
	return self:Team() > TEAM_HUMAN
end

function meta:GetGuildID()
	return self:Team() - TEAM_HUMAN
end

function meta:GetGuild()
	return GetAllGuilds()[self:GetGuildID()]
end

function meta:IsPointingAt(ent)
	return self:GetEyeTrace().Entity == ent
end

function meta:IsFrozen()
	return self.m_IsFrozen
end

function meta:SoftFreeze(bFreeze)
	self.m_IsFrozen = bFreeze
end

function meta:SendMessage(msg, col, allowreps)
	self:SendLua("GAMEMODE:AddNotify2("..string.format("%q", tostring(msg))..","..tostring(col)..","..tostring(allowreps)..")")
end

function meta:IsMonster()
	return self:Team() == TEAM_MONSTER
end

function meta:CallCastSpellEnchantments(...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() then
		wep:CastSpellEnchantments(...)
	end
end

function meta:ProcessDamage(dmginfo)
	self:StatusWeaponHook1("ProcessDamage", dmginfo)
	self:StatusWeaponHook1("PostProcessDamage", dmginfo)

	--[[local damagetype = dmginfo:GetDamageType()
	if STAMINA_DAMAGE[damagetype] then
		/*local damage = dmginfo:GetDamage()
		local stamina = self:GetStamina()

		dmginfo:SetDamage(damage - math.min(1, stamina / 75) * damage * STAMINA_ABSORPTION[damagetype])
		self:SetStamina(math.max(0, stamina - damage * STAMINA_DAMAGE[damagetype]))*/

		self:SetStamina(math.max(0, self:GetStamina() - dmginfo:GetDamage() * STAMINA_DAMAGE[damagetype]))
	end]]

	if self.BlockLethal then
		self.BlockLethal = nil

		if dmginfo:GetDamage() >= self:Health() - 1 then
			dmginfo:SetDamage(self:Health() - 1)
		end
	end
end

function meta:ShouldNotCollide(ent)
	return ent:IsPlayer() and not GAMEMODE:PlayerCanHarm(self, ent) -- Blocking someone is 'harmful'
end

function meta:HitReset()
	return self:StatusWeaponHook0("HitReset")
end

function meta:IsIdle(skipcastingcheck)
	if self:IsFrozen() or not skipcastingcheck and self:IsCasting() then return false end

	local ret = self:StatusWeaponHook0("IsIdle")
	if ret ~= nil then return ret end

	return true
end

function meta:IsCasting()
	return IsValid(self.Precast)
end

function meta:BloodSpray(pos, num, dir, force)
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(math.min(128, num))
		effectdata:SetRadius(self.BloodDye or 0)
		effectdata:SetNormal(dir)
		effectdata:SetScale(math.min(force, 6000))
		effectdata:SetEntity(self)
	util.Effect("bloodstream", effectdata, true, true)
end

function meta:EyeLevelPos()
	local pos = self:GetPos()
	pos.z = self:NewEyePos().z
	return pos
end

function meta:IsFacing(pos, thresh)
	return self:GetAimVector():Dot((pos - self:EyeLevelPos()):GetNormalized()) >= (thresh or 0.25)
end

function meta:ShouldGuardAgainst(attacker, wep, damage, damagetype, hitdata, ...)
	if not gamemode.Call("PlayerCanHarm", attacker, self) then return false end

	local mywep = self:GetActiveWeapon()
	if not mywep:IsValid() then return false end

	return mywep.ShouldGuardAgainst and mywep:ShouldGuardAgainst(attacker, wep, damage, damagetype, hitdata, ...) and not (wep.OverrideGuard and wep:OverrideGuard(self, mywep, damage, damagetype, hitdata, ...))
end

function meta:HitByMelee(attacker, attackerwep, damage, damagetype, hitdata, ...)
	-- TODO: Random Lua flinch animations

	self:StatusWeaponHook("OwnerHitByMelee", attacker, attackerwep, damage, damagetype, hitdata, ...)
end

function meta:GetPlayerCorpse()
	local uid = self:UniqueID()
	for _, ent in pairs(ents.FindByClass(CORPSE_ENTCLASS)) do
		if ent:GetPlayerUID() == uid then return ent end
	end

	return NULL
end

function meta:MeleeAttack(wep, ...)
	if not IsFirstTimePredicted() then return end
	if not wep then wep = self:GetActiveWeapon() end

	if not wep:IsValid() or wep.MeleeAttack and wep:MeleeAttack() then return end

	local damage = wep:GetDamage(...)
	local damagetype = wep:GetDamageType(...)
	local data = wep:GetSwingData(self, ...)

	local hit = data.HitWorld

	for _, ent in pairs(data.Entities) do
		if ent ~= self --[[and ent:IsInteractable()]] and not (ent:IsPlayer() and not gamemode.Call("PlayerCanHarm", self, ent)) then
			local hitdata = data.HitResults[ent]

			if ent:IsCharacter() and ent.ShouldGuardAgainst and ent:ShouldGuardAgainst(self, wep, damage, damagetype, hitdata, ...) then
				hit = true

				local entwep = ent:GetActiveWeapon()
				if not (wep.OnHitGuard and wep:OnHitGuard(ent, entwep, damage, damagetype, hitdata, ...)) and entwep:IsValid() and not (entwep.MeleeGuard and entwep:MeleeGuard(self, wep, damage, damagetype, hitdata, ...)) then
					entwep:GenericMeleeGuard(self, wep, damage, damagetype, hitdata, ...)
				end

				damage = 0 --damage = math.ceil(damage * 0.15)
			end

			if not wep.MeleeHit or not wep:MeleeHit(ent, damage, damagetype, hitdata, ...) then
				hit = true
				wep:GenericMeleeHit(ent, damage, damagetype, hitdata, ...)
			end
		end
	end

	if hit then
		if data.HitWorld and wep.OnHitWorld then
			wep:OnHitWorld(damage, damagetype, data.HitWorldResult, ...)
		end
	elseif wep.OnMeleeMiss then
		wep:OnMeleeMiss(damage, damagetype, ...)
	end
end
meta.MeleeSwing = meta.MeleeAttack

function meta:GetCastPosition()
	local wep = self:GetActiveWeapon()
	if wep:IsValid() then
		if wep.GetCastPosition then
			return wep:GetCastPosition()
		end

		local attach = wep:GetAttachment(1)
		if attach then return attach.Pos end
	end

	local attachid = self:LookupAttachment("anim_attachment_RH")
	if attachid ~= 0 then
		return self:GetAttachment(attachid).Pos
	end

	return self:NewEyePos()
end
meta.GetCastPos = meta.GetCastPosition
meta.CastPos = meta.GetCastPosition

function meta:Stun(tim, noeffect)
	if not self:InVehicle() then
		if noeffect then
			if self.Stunned and not self.SilentStunned then
				self:GiveStatus("stun", tim):SetColor(tim, 255, 255, 255)
			else
				self:GiveStatus("stun_noeffect", tim):SetColor(tim, 255, 255, 255)
			end
		else
			if self.SilentStunned then
				self:RemoveStatus("stun_noeffect", true, true)
			end
			self:GiveStatus("stun", tim):SetColor(tim, 255, 255, 255)
		end
	end
end

function meta:CapCriminal(tim)
	self:SetCriminal(math.max(tim, self:GetCriminal()))
end

function meta:SetLongTermMurders(murders)
	self.LongTermMurders = murders
end

function meta:GetLongTermMurders()
	return self.LongTermMurders
end

function meta:SetShortTermMurders(murders)
	local oldcount = self:GetShortTermMurders()
	local wasmurderer = self:IsMurderer()

	self:SetNetworkedInt("stmurders", math.min(murders, 25))

	if oldcount ~= self:GetShortTermMurders() then
		if wasmurderer then
			if not self:IsMurderer() then
				self:SendMessage("You are no longer considered a murderer!~sambient/levels/citadel/strange_talk1.wav", "COLOR_LIMEGREEN") -- TODO: Some sound.
			end
		elseif self:IsMurderer() then
			self:SendMessage("You are now considered a murderer!!~sambient/levels/citadel/strange_talk8.wav", "COLOR_RED")
			if SERVER then
				self:Retribution()
			end
		else
			self:SendMessage("You have ".. MURDERER_THRESHOLD - self:GetShortTermMurders() .." more murder counts before being considered a murderer!", "COLOR_RED")
		end
	end
end

function meta:GetShortTermMurders()
	return self:GetNetworkedInt("stmurders", 0)
end

function meta:AddMurderCount(count)
	count = count or 1

	self:SetShortTermMurders(self:GetShortTermMurders() + count)
	self:SetLongTermMurders(self:GetLongTermMurders() + count)
end

function meta:IsCriminal()
	return CurTime() < self:GetCriminal() or self:IsMurderer()
end

function meta:IsMurderer()
	return self:GetShortTermMurders() >= MURDERER_THRESHOLD
end

function meta:ClearCriminal()
	self:SetCriminal(0)
end

function meta:GetCriminal()
	return self:GetNetworkedFloat("crimtime", 0)
end

local colTempCrim = Color(255, 255, 255, 255)
function meta:GetNameColor(viewer)
	if self:IsMonster() then
		if viewer and viewer:IsMonster() then
			local viewerclasstab = viewer:GetMonsterClassTable()
			if viewerclasstab and viewerclasstab.Group == self:GetMonsterClassTable().Group then
				return COLOR_LIMEGREEN
			end

			return COLOR_ORANGE
		end

		return COLOR_RED
	end

	if viewer and viewer ~= MySelf and viewer:IsInGuild() and self:IsInGuild() then
		if viewer:IsInSameGuild(self) then
			return COLOR_LIMEGREEN
		end

		local attitude = viewer:GuildAttitude(self)
		if attitude >= GUILDATTITUDE_ENEMY then
			return COLOR_ORANGE
		elseif attitude <= GUILDATTITUDE_ALLY then
			return COLOR_LIMEGREEN
		elseif attitude <= GUILDATTITUDE_FRIENDLY then
			return COLOR_GREEN
		end
	end

	if self:IsMurderer() then
		return COLOR_RED
	end

	if self:IsCriminal() then
		local crimtime = self:GetCriminal()
		if crimtime - 4 <= CurTime() then
			local delta = (crimtime - CurTime()) / 4
			local negdelta = 1 - delta
			colTempCrim.r = (COLOR_GRAY.r * delta + COLOR_LIGHTBLUE.r * negdelta) --* 0.5
			colTempCrim.g = (COLOR_GRAY.g * delta + COLOR_LIGHTBLUE.g * negdelta) --* 0.5
			colTempCrim.b = (COLOR_GRAY.b * delta + COLOR_LIGHTBLUE.b * negdelta) --* 0.5
			return colTempCrim
		end

		return COLOR_GRAY
	end

	return COLOR_LIGHTBLUE
end

function meta:IsMoving()
	return self:KeyDown(IN_FORWARD) or self:KeyDown(IN_MOVELEFT) or self:KeyDown(IN_MOVERIGHT) or self:KeyDown(IN_BACK) or not self:OnGround() or self:IsSwimming()
end

function meta:CanEnterVehicle()
	return not self:IsFrozen() and self:IsIdle()
end

function meta:CanSwitchWeapon()
	local wep = self:GetActiveWeapon()
	if wep.CanSwitchWeapon and not wep:CanSwitchWeapon(towep) then
		return false
	end

	return true
end

function meta:SetNextAttack(tim)
	self.m_NextAttack = tim
end

function meta:GetNextAttack()
	return self.m_NextAttack
end

function meta:AirBrake(z)
	if not self:OnGround() then
		local curvel = self:GetVelocity()
		self:SetLocalVelocity(Vector(curvel.x * 0.2, curvel.y * 0.2, z or (curvel.z * 0.2)))

		return true
	end
end

function meta:TraceLine(distance, mask)
	local start = self:NewEyePos()
	local filter = ents.FindByClass("projectile_*")
	filter[#filter + 1] = self
	return util.TraceLine({start = start, endpos = start + self:GetAimVector() * distance, filter = filter, mask = mask})
end

function meta:TraceHull(distance, mask, radius)
	local vradius = Vector(radius, radius, radius)
	local start = self:NewEyePos()
	local filter = ents.FindByClass("projectile_*")
	filter[#filter + 1] = self
	return util.TraceHull({start = start, endpos = start + self:GetAimVector() * distance, filter = filter, mask = mask, mins = vradius * -1, maxs = vradius})
end

function meta:ProjectileGuideTrace(projectile)
	return self:TraceHull(10240, MASK_SOLID, 4)
	--return self:TraceHull(projectile:GetPos():Distance(self:EyePos()) + projectile:GetVelocity():Length() + 64, MASK_SOLID, 4)
end

function meta:MultipleTraceHull(distance, mask, radius)
	mask = mask or MASK_SOLID
	radius = radius or 8

	local start = self:NewEyePos()
	local endpos = start + self:GetAimVector() * distance
	local maxs = Vector(radius, radius, radius)
	local mins = maxs * -1

	local filter = ents.FindByClass("projectile_*")
	filter[#filter + 1] = self

	local tab = {}
	tab.HitResults = {}
	tab.Entities = {}

	while true do
		local tr = util.TraceHull({start = start, endpos = endpos, filter = filter, mask = mask, mins = mins, maxs = maxs})
		if not tr.Hit then break end
		if tr.HitWorld then
			tab.HitWorldResult = tr
			tab.HitWorld = true
			break
		end

		local hitent = tr.Entity
		if hitent:IsValid() then
			--if hitent:IsCharacter() then
			--[[if hitent:IsInteractable() then
				table.insert(filter, hitent)
			end]]

			tab.HitResults[hitent] = tr

			table.insert(tab.Entities, hitent)
			table.insert(filter, hitent)
		end
	end

	return tab
end

function meta:GetSpellTarget()
	local status = self.status_threadoffate
	return status and status:IsValid() and status:GetTarget():IsValid() and status:GetTarget() or self
end

function meta:RPGAccountFile()
	return string.format("rpgaccounts/%s/%s.txt", self:SteamID64():sub(-2), self:SteamID64())
end

function meta:AddFrozenPhysicsObject(ent, phys)
end

function meta:UnfreezePhysicsObjects(ent, phys)
	return 0
end

function meta:SetNoSkillUps(onoff)
	self.m_NoSkillUps = onoff
end
meta.SetSkillLocked = meta.SetNoSkillUps

function meta:GetNoSkillUps()
	return self.m_NoSkillUps or self:IsMonster()
end
meta.IsSkillLocked = meta.GetNoSkillUps

function meta:GetMana()
	return math.Clamp(self.Mana + self.ManaRegenerate * (CurTime() - self.ManaBase), 0, self.MaxMana)
end

--[[function meta:GetStamina()
	return math.min(self.MaxStamina, self.Stamina + self.StaminaRegenerate * (CurTime() - self.StaminaBase))
end]]

meta.GetTeamID = meta.Team

function meta:CanHolster()
	return self:CanSwitchWeapon()
end

function meta:UseSkill(skillid, difficulty, failed)
	if self:IsSkillLocked() then return false end

	return gamemode.Call("PlayerUseSkill", self, skillid, difficulty, failed)
end

function meta:SkillUp(skillid, difficulty)
	return gamemode.Call("PlayerSkillUp", self, skillid, difficulty)
end

function meta:HasSkill(skillid)
	return gamemode.Call("PlayerHasSkill", self, skillid)
end

function meta:SetupDefaultSkills(update)
	self.Skills = self.Skills or {}

	for skillid, skilltab in ipairs(SKILLS) do
		if not self.Skills[skillid] then
			self:SetSkill(skillid, skilltab.Default or 0)
		end
	end

	if update then
		self:UpdateSkills()
	end
end

function meta:SetAllSkills(amount, noupdate)
	for i, skillid in pairs(SKILLS) do
		self:SetSkill(skillid, amount)
	end

	if not noupdate then
		self:UpdateSkills()
	end
end

function meta:RPGName(viewer)
	if self:IsMonster() then
		if viewer and viewer:IsMonster() and viewer:GetMonsterClassTable().Group == self:GetMonsterClassTable().Group then
			return self:Name()
		end

		return util.AOrAn(self:GetMonsterClassTable().Name)
	end

	return self:Name()
end

function meta:NoParseName(viewer)
	return "<noparse>"..self:Name().."</noparse>"
end

function meta:RPGNoParseName(viewer)
	return "<noparse>"..self:RPGName().."</noparse>"
end

function meta:TotalSkill()
	local amount = 0

	for i in pairs(SKILLS) do
		amount = amount + self:GetSkill(i)
	end

	return amount
end

function meta:TotalSkillGroup(groupid)
	local amount = 0

	for i in pairs(SKILLS) do
		if SKILLS[i].Group == groupid then
			amount = amount + self:GetSkill(i)
		end
	end

	return amount
end

function meta:GetHostileSkillUpDifficulty(pl)
	if pl:IsMonster() then
		return (pl:GetMonsterClassTable().Rank or 1) * SKILLS_RMAX * 3
	else
		return (pl:TotalSkill() + 50 - self:TotalSkill()) * SKILLS_RMAX
	end
end

function meta:AddSkill(skillid, amount, noupdate)
	self:SetSkill(skillid, math.min(self:GetSkill(skillid) + amount, SKILLS_MAX), noupdate)
end

function meta:GetSkill(skillid)
	if self:IsMonster() then
		local skills = self:GetMonsterClassTable().Skills
		if skills then
			return skills[skillid] or 0
		end

		return 0
	end

	return (self.Skills or self)[skillid] or 0
end

function meta:GetSkillMultiplier(skillid)
	return self:GetSkill(skillid) * SKILLS_RMAX
end

function meta:GetSkillDamageMultiplier(skillid)
	return 0.75 + self:GetSkillMultiplier(skillid) * 0.25
end

function meta:GetStrengthDamageMultiplier()
	return 0.6 + self:GetSkillMultiplier(SKILL_STRENGTH) * 0.4
end

--[[function meta:GetLumberjackingDamageMultiplier()
	return 0.8 + self:GetSkillMultiplier(SKILL_LUMBERJACKING) * 0.2
end]]

function meta:HasSkill(skillid)
	return 0 < self:GetSkill(skillid)
end

meta["OnSkillChanged"..tostring(SKILL_STRENGTH)] = function(self, amount)
	self:SetMaxHealth(GAMEMODE:GetMaxHealth(self:GetSkill(SKILL_VITALITY), amount))
end

meta["OnSkillChanged"..tostring(SKILL_VITALITY)] = function(self, amount)
	self:SetMaxHealth(GAMEMODE:GetMaxHealth(amount, self:GetSkill(SKILL_STRENGTH)))
end

meta["OnSkillChanged"..tostring(SKILL_DEXTERITY)] = function(self, amount)
	--self:SetMaxStamina(GAMEMODE:GetMaxStamina(amount), GAMEMODE:GetStaminaRegeneration(amount))
	self:ResetSpeed(amount)
	self:ResetJumpPower(amount)
end

meta["OnSkillChanged"..tostring(SKILL_INTELLIGENCE)] = function(self, amount)
	self:SetMaxMana(GAMEMODE:GetMaxMana(amount), GAMEMODE:GetManaRegeneration(amount))
end

function meta:OnSkillChanged(skillid, amount)
	local callback = self["OnSkillChanged"..tostring(skillid)]
	if callback then
		amount = amount or self:GetSkill(skillid)
		callback(self, amount)
	end
end

function meta:SetSpeed(speed)
	self:SetMaxSpeed(speed)
	self:SetWalkSpeed(speed)
	self:SetRunSpeed(speed)
end

local function nocollidetimer(self, timername)
	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			return
		end
	end

	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	timer.Destroy(timername)
end

function meta:TemporaryNoCollide(force)
	if self:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER and not force then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local timername = "TemporaryNoCollide"..self:UniqueID()
			timer.Create(timername, 0, 0, function() nocollidetimer(self, timername) end)

			return
		end
	end
end

function meta:ResetSpeed(skill)
	if self:IsGhost() then
		self:SetSpeed(300)
	else
		stat.Start(self:CallMonsterFunction("GetSpeed", skill) or GAMEMODE:GetPlayerSpeed(skill or self:GetSkill(SKILL_DEXTERITY)))
			self:StatusWeaponHook0("ResetSpeed")
		self:SetSpeed(stat.Get())
	end
end

function meta:ResetJumpPower(skill)
	stat.Start(self:CallMonsterFunction("GetJumpPower", skill) or GAMEMODE:GetPlayerJumpPower(skill or self:GetSkill(SKILL_DEXTERITY)))
		self:StatusWeaponHook0("ResetJumpPower")
	self:SetJumpPower(stat.Get())
end

--[[function meta:GetMaxStamina()
	return self.MaxStamina or 0
end]]

function meta:GetMaxMana()
	return self.MaxMana or 0
end

-- Try not to use the vararg (...) version of these, varargs are slow in lua.

function meta:StatusHook(func, ...)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, ...)
			end
		end
	end
end

function meta:StatusHook0(func)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent)
			end
		end
	end
end

function meta:StatusHook1(func, a)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a)
			end
		end
	end
end

function meta:StatusHook2(func, a, b)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b)
			end
		end
	end
end

function meta:StatusHook3(func, a, b, c)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b, c)
			end
		end
	end
end

function meta:StatusHook4(func, a, b, c, d)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b, c, d)
			end
		end
	end
end

function meta:StatusWeaponHook(func, ...)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, ...)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep, ...)
	end
end

function meta:StatusWeaponHook0(func)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep)
	end
end

function meta:StatusWeaponHook1(func, a)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep, a)
	end
end

function meta:StatusWeaponHook2(func, a, b)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep, a, b)
	end
end

function meta:StatusWeaponHook3(func, a, b, c)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b, c)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep, a, b, c)
	end
end

function meta:StatusWeaponHook4(func, a, b, c, d)
	for _, ent in pairs(ents.FindByClass("status*")) do
		if ent:GetOwner() == self then
			if ent[func] then
				ent[func](ent, a, b, c, d)
			end
		end
	end

	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[func] then
		wep[func](wep, a, b, c, d)
	end
end
