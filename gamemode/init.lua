AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_boneanimlib.lua")
AddCSLuaFile("cl_postprocess.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_talk.lua")
AddCSLuaFile("cl_floaties.lua")

AddCSLuaFile("obj_entity_extend.lua")
AddCSLuaFile("obj_entity_extend_cl.lua")
AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_player_extend_cl.lua")
AddCSLuaFile("obj_npc_extend.lua")
AddCSLuaFile("obj_weapon_extend.lua")
AddCSLuaFile("obj_item.lua")

AddCSLuaFile("sh_soundset.lua")

AddCSLuaFile("cl_notice.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("cl_dermaskin.lua")
AddCSLuaFile("sh_util.lua")
AddCSLuaFile("sh_metallurgy.lua")
AddCSLuaFile("sh_alchemy.lua")
AddCSLuaFile("sh_animations.lua")
AddCSLuaFile("sh_colors.lua")
AddCSLuaFile("sh_stats.lua")
AddCSLuaFile("sh_items.lua")
AddCSLuaFile("sh_items_datastructure.lua")
AddCSLuaFile("sh_zones.lua")
AddCSLuaFile("sh_spells.lua")
AddCSLuaFile("sh_voicesets.lua")
AddCSLuaFile("sh_guilds.lua")
AddCSLuaFile("sh_flora.lua")
--AddCSLuaFile("sh_playerrigs.lua")
AddCSLuaFile("sh_convo.lua")
AddCSLuaFile("cl_convo.lua")
AddCSLuaFile("sh_monsters.lua")

AddCSLuaFile("cl_animeditor.lua")

AddCSLuaFile("vgui/dpersistframe.lua")
AddCSLuaFile("vgui/dmodelpanel2.lua")
AddCSLuaFile("vgui/pskills.lua")
AddCSLuaFile("vgui/pcontainer.lua")
AddCSLuaFile("vgui/photbar.lua")
AddCSLuaFile("vgui/progressbar.lua")
AddCSLuaFile("vgui/dvitals.lua")
AddCSLuaFile("vgui/pitem.lua")

AddCSLuaFile("sh_hack.lua")

GM.MapEditorPrefix = "noxiousrpg"

include("sv_uniqueid.lua")

include("shared.lua")
include("obj_entity_extend_sv.lua")
include("obj_player_extend_sv.lua")
include("mapeditor.lua")
include("boneanimlib.lua")
include("sv_util.lua")
include("sv_spells.lua")
include("sv_convo.lua")
include("sv_talk.lua")
include("sv_alchemy.lua")

if file.Exists("gamemodes/noxiousrpg/gamemode/maps/"..game.GetMap()..".lua", "GAME") then
	MsgN("Executing map profile...")
	include("maps/"..game.GetMap()..".lua")
	MsgN("Done.")
end

concommand.Add("rpg_testmode_setskill", function(pl, command, arguments)
	if not GAMEMODE.TestMode or not pl:IsValid() or not pl:IsConnected() or not pl:Alive() or #arguments < 2 then return end

	local skillname = string.lower(table.concat(arguments, " ", 1, #arguments - 1))
	for skillid, skilltab in pairs(SKILLS) do
		if string.lower(skilltab.Name) == skillname and not skilltab.Unsettable then
			local amount = math.max(0, math.min(SKILLS_MAX, math.ceil((tonumber(arguments[#arguments]) or 0) * 10) * 0.1))
			pl:SetSkill(skillid, amount)
			pl:PrintMessage(HUD_PRINTTALK, skilltab.Name.." set to "..amount)
			return
		end
	end
end)

concommand.Add("_rpg_setviewoffsetsync", function(pl, command, arguments)
	local viewoffset = tonumber(arguments[1])
	if not viewoffset then return end
	local thirdperson = tonumber(arguments[2]) == 1

	pl.ViewOffset = math.Clamp(viewoffset, -22, 22)
	pl.ThirdPerson = thirdperson
end)

concommand.Add("cnc", function(pl, command, arguments)
	hook.Call("ContextScreenClick", GAMEMODE, Vector(tonumber(arguments[3]) or 0, tonumber(arguments[4]) or 0, tonumber(arguments[5]) or 0), tonumber(arguments[2]) or 0, tonumber(arguments[1]) == 1, pl, Vector(tonumber(arguments[6]) or 0, tonumber(arguments[7]) or 0, tonumber(arguments[8]) or 0))
end)

function GM:OnWeatherChanged(weatherid, previousid)
	for _, ent in pairs(ents.GetAll()) do
		if ent.OnWeatherChanged then
			pcall(ent.OnWeatherChanged, ent, weatherid, previousid)
		end
	end
end

function GM:SetWeather(weatherid)
	self.PreviousWeather = self:GetWeather()
	self.CurrentWeather = weatherid

	gamemode.Call("OnWeatherChanged", weatherid, self.PreviousWeather)

	gmod.BroadcastLua("GAMEMODE:SetWeather("..tostring(weatherid)..", "..tostring(self.PreviousWeather)..")")
end

function GM:AllowPlayerPickup(pl, ent)
	return false
end

function GM:EntityTakeDamage(ent, dmginfo)
	if ent:IsWeapon() or ent.m_IsStatus then return end -- Weapons and status entities only process damage for their owners.

	local attacker, inflictor = dmginfo:GetAttacker(), dmginfo:GetInflictor()

	if attacker == inflictor and attacker:IsProjectile() and dmginfo:GetDamageType() == DMG_CRUSH then -- Fixes projectiles doing physics-based damage.
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
		return
	end

	local wl = ent:WaterLevel()
	if wl > 0 then
		if dmginfo:GetDamageType() == DMGTYPE_ENERGY then
			dmginfo:SetDamage(dmginfo:GetDamage() * (1 + wl * 0.0333))
		elseif dmginfo:GetDamageType() == DMGTYPE_FIRE then
			dmginfo:SetDamage(dmginfo:GetDamage() * (1 - wl * 0.0333))
		end
	end

	zone.ProcessDamage(ent, dmginfo)

	if ent.ProcessDamage then
		ent:ProcessDamage(dmginfo)
	end
end

function GM:EntityShouldPersist(ent)
	return ent.LockedDown or ent.Persist or PERSIST[ent:GetClass()] or ent.IsPersistent and ent:IsPersistent() or ent:GetItem() and ent:GetItem().Persist
end

function GM:UpdateZone(dataname, plorpls)
	if not plorpls then plorpls = player.GetAll() end

	local zone = GetAllZones()[dataname]
	if zone then
		local data = Serialize(zone)
		if type(plorpls) == "table" then
			for _, pl in pairs(player.GetAll()) do
				pl:SendLongString(LONGSTRING_UPDATEZONE, data)
			end
		else
			plorpls:SendLongString(LONGSTRING_UPDATEZONE, data)
		end
	end
end

function GM:UpdateAllZones(plorpls)
	if not plorpls then plorpls = player.GetAll() end

	local data = Serialize(GetAllZones())
	if type(plorpls) == "table" then
		for _, pl in pairs(plorpls) do
			pl:SendLongString(LONGSTRING_UPDATEALLZONES, data)
		end
	else
		plorpls:SendLongString(LONGSTRING_UPDATEALLZONES, data)
	end
end

function GM:SaveWorld()
	for _, pl in pairs(player.GetAll()) do
		self:SaveAccount(pl)
	end

	if self.WorldLoading then return end

	PrintMessage(HUD_PRINTTALK, "[world save]")

	local curtime = CurTime()

	local tosave = {}
	tosave.Entities = {}

	for _, ent in pairs(ents.GetAll()) do
		if ent:IsValid() and gamemode.Call("EntityShouldPersist", ent) then
			local tab = {}
			if not ent.OnSave or not ent:OnSave(tab) then
				tab[1] = ent:GetClass()
				tab[2] = ent:GetPos()
				tab[3] = ent:GetAngles()
				local mdl = ent:GetModel()
				if mdl ~= "models/error.mdl" then
					tab[4] = mdl
				end
				tab[5] = ent:GetMaterial()
				tab[6] = ent:GetSkin()
				tab[7] = curtime - (ent.Created or 0)
				tab[8] = ent:GetCollisionGroup()
				tab[9] = ent:GetSolid()
				tab[10] = ent.LockedDown
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					tab[11] = phys:GetVelocity()
					tab[12] = phys:GetAngleVelocity()
					tab[13] = phys:IsMoveable()
					tab[14] = phys:GetMass()
					tab[15] = phys:GetMaterial()
				end
				tab[16] = ent:GetItem()
				local decay = ent:GetDecay()
				if decay then
					tab[17] = decay - curtime
				end
				tab[18] = ent.SpawnerUID
			end
			if ent.OnSaved then ent:OnSaved(tab) end
			tosave.Entities[#tosave.Entities + 1] = tab
		end
	end

	gamemode.Call("PostSaveWorld", tosave)

	file.Write("noxiousrpg_world_"..game.GetMap()..".txt", Serialize(tosave))

	gamemode.Call("PostSaveWorldFinished")
end
GM.WorldSave = GM.SaveWorld

function GM:PostSaveWorld(savetab)
end

function GM:PostSaveWorldFinished()
end

function GM:EntitiesLoaded()
	for _, ent in pairs(ents.GetAll()) do
		if ent.PostEntitiesLoaded then
			pcall(ent.PostEntitiesLoaded, ent)
		end
	end
end

local function LoadEntities(tab)
	local enttab = tab[1]
	if not enttab then
		timer.Remove("LoadEntities")
		PrintMessage(HUD_PRINTTALK, "[world load complete]")
		gamemode.Call("EntitiesLoaded")
		GAMEMODE.WorldLoading = nil
		return
	end
	table.remove(tab, 1)

	local class = enttab[1]
	if class and scripted_ents.GetStored(class) then
		local ent = ents.Create(class)
		if ent:IsValid() then
			local pos = enttab[2]
			local ang = enttab[3]
			local mdl = enttab[4]
			local mat = enttab[5]
			local skin = enttab[6]
			--local lifetime = enttab[7]
			local collisiongroup = enttab[8]
			local solid = enttab[9]
			local vel = enttab[10]
			local lockeddown = enttab[11]
			local angvel = enttab[12]
			local moveable = enttab[13]
			local mass = enttab[14]
			local physmat = enttab[15]
			local item = enttab[16]
			local decaytime = enttab[17]
			local spawneruid = enttab[18]

			if not ent.OnLoad or not ent:OnLoad(enttab) then
				ent:SetPos(pos)
				ent:SetAngles(ang)
				if ent:GetModel() ~= mdl and mdl ~= "models/error.mdl" then
					ent:SetModel(mdl)
				end
				ent:Spawn()
				ent.LockedDown = lockeddown
				if ent:GetMaterial() ~= mat then
					ent:SetMaterial(mat)
				end
				if ent:GetSkin() ~= skin then
					ent:SetSkin(skin)
				end
				if ent:GetCollisionGroup() ~= collisiongroup then
					ent:SetCollisionGroup(collisiongroup)
				end
				if ent:GetSolid() ~= solid then
					ent:SetSolid(solid)
				end
				if item then
					ent:SetItem(item)
				end
				if vel then
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:EnableMotion(moveable)
						if moveable then
							if physmat and physmat ~= "" and phys:GetMaterial() ~= physmat then
								phys:SetMaterial(physmat)
							end
							phys:SetMass(mass or 1)
							phys:Wake()
							phys:SetVelocityInstantaneous(vel)
							phys:AddAngleVelocity(angvel)
						end
					end
				end
				if decaytime then
					ent:Decay(decaytime)
				end
				if spawneruid then
					ent.SpawnerUID = spawneruid
				end
			end
			if ent.OnLoaded then ent:OnLoaded(enttab) end
		end
	end
end

local function LoadEntitiesPCall(stuff)
	local ok, err = pcall(LoadEntities, stuff.Entities)
	if err then
		ErrorNoHalt("Error loading saved entity: "..tostring(err))
	end
end

-- Return true to not do explosion or whatever. data can be altered.
function GM:ProjectileCollide(ent, data)
	local hitent = data.HitEntity
	if hitent and hitent:IsValid() and hitent.HitWithProjectile then return hitent:HitWithProjectile(ent, data) end
end

function GM:LoadWorld()
	if file.Exists("noxiousrpg_world_"..game.GetMap()..".txt", "DATA") then
		PrintMessage(HUD_PRINTTALK, "[world load]")

		local stuff = Deserialize(file.Read("noxiousrpg_world_"..game.GetMap()..".txt", "DATA"), ITEM_DESERIALIZE_ENV)

		if stuff.Entities then
			timer.Create("LoadEntities", WORLDSAVE_ENTITYLOADRATE, 0, function() LoadEntitiesPCall(stuff) end)
			self.WorldLoading = true
		end

		local runstrings = stuff.RunStrings
		if runstrings then
			for i, str in ipairs(runstrings) do
				RunString(str)
			end
		end

		gamemode.Call("PostLoadWorld", stuff)
	end

	gamemode.Call("PostLoadWorldFinished")
end
GM.WorldLoad = GM.LoadWorld

function GM:PostLoadWorld(savetab)
end

function GM:PostLoadWorldFinished()
end

function GM:OnKnockedDown(pl)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.OnKnockedDown then
		wep:OnKnockedDown(pl)
	end
end

function GM:PlayerFootstep(pl, vPos, iFoot, strSoundName, fVolume, pFilter)
end

if not gmod.BroadcastLua then
	function gmod.BroadcastLua(lua)
		for _, pl in pairs(player.GetAll()) do
			pl:SendLua(lua)
		end
	end
end

Material = Material or function() end
Color = Color or function() end

function GM:AddResources()
	--[[ MISSING
	resource.AddFile("resource/fonts/knigqst.ttf")

	resource.AddFile("materials/refract_ring.vmt")
	resource.AddFile("materials/vgui/health2.vmt")
	resource.AddFile("materials/vgui/mana2.vmt")

	resource.AddFile("materials/spacebuild/lwmetal1nc1.vmt")
	resource.AddFile("models/slyfo/walllong.mdl")
	resource.AddFile("models/slyfo/walllonggate.mdl")
	resource.AddFile("models/slyfo/wallshort.mdl")
	resource.AddFile("models/slyfo/wallshortgate.mdl")

	resource.AddFile("materials/noxctf/bulleticon.vmt")
	resource.AddFile("materials/noxctf/sprite_nova.vmt")
	resource.AddFile("materials/noxctf/sprite_smoke.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray1.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray2.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray3.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray4.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray5.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray6.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray7.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray8.vmt")
	resource.AddFile("materials/noxctf/spellselection.vmt")

	for _, filename in pairs(file.Find("materials/spellicons/*.vmt", true)) do
		resource.AddFile("materials/spellicons/"..filename)
	end]]

	--[[
	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/sound/rpgsounds/*.wav", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/sound/rpgsounds/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/sound/rpgsounds/*.mp3", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/sound/rpgsounds/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/sound/nox/*.wav", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/sound/nox/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/sound/nox/*.mp3", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/sound/nox/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/materials/mixerman3d/weapons/*.*", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/materials/mixerman3d/weapons/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/models/mixerman3d/weapons/*.mdl", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/models/mixerman3d/weapons/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/models/peanut/*.mdl", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/models/peanut/"..filename)
	end

	for _, filename in pairs(file.Find("gamemodes/noxiousrpg/content/materials/peanut/*.*", "GAME")) do
		resource.AddFile("gamemodes/noxiousrpg/content/materials/peanut/"..filename)
	end

	resource.AddFile("models/nox_sword_short_v001.mdl")
	resource.AddFile("models/w_nox_short_sword.mdl")
	resource.AddFile("materials/models/wp_sword_short/wp_sword_short.vmt")
	resource.AddFile("materials/models/wp_sword_short/wp_sword_short.vtf")
	resource.AddFile("materials/models/wp_sword_short/wp_sword_short_normal.vtf")

	-- Gibs
	resource.AddFile("models/Gibs/brain.mdl")
	resource.AddFile("models/Gibs/gibhead.mdl")
	resource.AddFile("models/Gibs/heart.mdl")
	resource.AddFile("models/Gibs/hgibs_jaw.mdl")
	resource.AddFile("models/Gibs/leg.mdl")
	resource.AddFile("models/Gibs/pgib_p5.mdl")
	resource.AddFile("models/Gibs/pgib_p4.mdl")
	resource.AddFile("models/Gibs/pgib_p3.mdl")
	resource.AddFile("models/Gibs/pgib_p2.mdl")
	resource.AddFile("models/Gibs/pgib_p1.mdl")
	resource.AddFile("models/Gibs/rgib_p5.mdl")
	resource.AddFile("models/Gibs/rgib_p4.mdl")
	resource.AddFile("models/Gibs/rgib_p2.mdl")
	for _, filename in pairs(file.Find("materials/models/gibs/*.*", true)) do
		resource.AddFile("materials/models/gibs/"..filename)
	end

	-- Particle manifests and particles.
	resource.AddFile("particles/particles_rpg_0001.txt")

	resource.AddFile("particles/voidspiral.pcf")
	]]
end

function GM:Initialize()
	timer.Remove("HostnameThink")

	RunConsoleCommand("sv_gravity", 600)

	VOTEMAPLOCKED = true

	file.CreateDir("rpgaccounts")
	for i=0, 99 do
		file.CreateDir(string.format("rpgaccounts/%02d", i))
	end

	gamemode.Call("AddResources")
	gamemode.Call("LoadGuilds")
	gamemode.Call("InitializeSoundSets")
	gamemode.Call("AddNetworkStrings")

	timer.Create("WorldSave", WORLDSAVE_INTERVAL, 0, function() gamemode.Call("SaveWorld") end)
end

function GM:AddNetworkStrings()
	util.AddNetworkString("rpg_playerspawn")

	util.AddNetworkString("rpg_mana")
	util.AddNetworkString("rpg_stamina")
	util.AddNetworkString("rpg_skill")
	util.AddNetworkString("rpg_skills")
	util.AddNetworkString("rpg_convo_upd")
	util.AddNetworkString("rpg_floatie")
end

function GM:InitPostEntity()
	gamemode.Call("CreateDummyEntities")

	for _, ent in pairs(ents.FindByClass("item_*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("game_player_equip")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("weapon_*")) do
		ent:Remove()
	end

	gamemode.Call("LoadMapEditorFile")
	gamemode.Call("LoadWorld")
end

function GM:OnDamagedByExplosion(pl)
end

function GM:CreateDummyEntities()
	local vVec0 = Vector(0, 0, 0)
	for _, name in pairs(file.Find("gamemodes/noxiousrpg/entities/entities/dummy_*", "GAME")) do
		local ent = ents.Create(name)
		if ent:IsValid() then
			ent:SetPos(vVec0)
			ent:Spawn()
			_G[string.upper(name)] = ent
		end
	end
end

function GM:PlayerSwitchFlashlight(pl, switchon)
	return false
end

function GM:PlayerSelectSpawn(pl)
	return pl
end

function GM:Think()
	local fCurTime = CurTime()
	local fNextTick = fCurTime + 1

	for _, pl in pairs(player.GetAll()) do
		if fCurTime >= pl.m_NextSecondTick then
			pl.m_NextSecondTick = fNextTick
			pl:SecondTick()
		end

		pl:Think()
	end
end

function GM:OnNPCKilled(ent, attacker, inflictor)
end

function GM:PlayerNoClip(pl, on)
	if pl:IsAdmin() then
		if on then
			NDB.LogAction("[Admin CMD] <"..pl:SteamID().."> "..pl:Name().." TURNED ON NOCLIP")
		else
			NDB.LogAction("[Admin CMD] <"..pl:SteamID().."> "..pl:Name().." TURNED OFF NOCLIP")
		end
		return true
	end

	return false
end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
	return false
end

function GM:PhysgunDrop(ply, ent)
end

function GM:CanPlayerEnterVehicle(pl, veh, role)
	return true
end

function GM:CanExitVehicle(veh, pl)
	if pl and pl:IsValid() then
		pl:ExitVehicle()
	end

	return true
end

function GM:PlayerEnteredVehicle(pl, veh, role)
end

function GM:PhysgunPickup(pl, ent)
	return pl:IsSuperAdmin()
end

function GM:PlayerCanPickupWeapon(pl, wep)
	return pl.AllowWeaponPickup
end

function GM:PlayerDeathThink(pl)
	if pl.NextSpawnTime and pl.NextSpawnTime <= CurTime() then
		pl:CreatePlayerCorpse()
		pl:Spawn()
	end
end

function GM:PlayerUse(pl, ent)
	return true
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerHurt(pl, attacker, healthremaining, damage)
	pl:PlayPainSound(damage)
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	pl:RemoveStatus("overridemodel", false, true)

	pl:SoftFreeze(true) -- Fixes 'flying' while dead.

	if pl:IsOnFire() then
		pl:Extinguish()
	end

	local fCurTime = CurTime()

	pl.NextSpawnTime = fCurTime + 7
	pl.LastDeath = fCurTime

	if pl:IsGhost() then return end

	if not attacker:IsPlayer() then
		local lastattacker, lastattacked = pl:GetLastAttacker()
		if lastattacker:IsValid() and lastattacker:IsPlayer() and fCurTime <= lastattacked + LASTATTACKERTIME then
			attacker = lastattacker
		end
	end

	local inflictor = dmginfo:GetInflictor()

	if attacker:IsValid() then
		local owner = attacker:GetOwner()
		if owner:IsCharacter() then
			attacker = owner
		end
	end

	pl:CreateRagdoll()
	pl:PlayDeathSound()

	pl:RemoveAllStatus(true, true)

	gamemode.Call("PlayerDeath2", pl, inflictor, attacker)

	pl:DropEverything()
end

function GM:ShowHelp(pl)
end

function GM:ShowTeam(pl)
	if pl:Alive() and (not pl:IsMonster() or pl:ImplicitCallMonsterFunction("CanSeeSkills")) then
		pl:ToggleSkills()
	end
end

function GM:ShowSpare1(pl)
	pl:SendLua("GAMEMODE:ToggleContext()")
end

function GM:ShowSpare2(pl)
	if pl:Alive() and (not pl:IsMonster() or pl:ImplicitCallMonsterFunction("CanUseInventory")) then
		pl:ToggleInventory()
	end
end

function GM:PlayerDeath(Victim, Inflictor, Attacker)
end

function GM:PlayerDeath2(Victim, Inflictor, Attacker)
	Victim:StripAmmo()

	if Inflictor and Inflictor == Attacker and Inflictor:IsCharacter() then
		Inflictor = Inflictor:GetActiveWeapon()
		if not Inflictor:IsValid() then Inflictor = Attacker end
	end

	local owner = Attacker:GetOwner()
	if owner:IsPlayer() then
		Attacker = owner
	end

	local inf
	if Inflictor.DisplayClass then
		inf = Inflictor.DisplayClass
	else
		inf = Inflictor:GetClass()
	end

	if Attacker == Victim then
		Victim:SendMessage("You killed yourself!", "COLOR_RED")
	elseif Attacker:IsPlayer() then
		if Victim:IsMonster() or Attacker:IsMonster() then
			Attacker:SendMessage("You killed "..Victim:RPGName(Attacker).."!~s"..SOUND_KILL_MONSTER)
			Victim:SendMessage("You were killed by "..Attacker:RPGName(Victim).."!~s"..SOUND_KILLED_MONSTER, "COLOR_RED")
		elseif Attacker:IsInSameGuild(Victim) then
			Attacker:SendMessage("You killed guild mate "..Victim:RPGName(Attacker).."!~s"..SOUND_KILL_FRIENDLYGUILD)
			Victim:SendMessage("You were killed by guild mate "..Attacker:RPGName(Victim).."!~s"..SOUND_KILLED_FRIENDLYGUILD, "COLOR_RED")
		elseif Victim:IsCriminal() then
			Attacker:SendMessage("You killed "..Victim:RPGName(Attacker).."!~s"..SOUND_KILL)
			Victim:SendMessage("You were killed by "..Attacker:RPGName(Victim).."!~s"..SOUND_KILLED, "COLOR_RED")
		else
			Attacker:SendMessage("You murdered "..Victim:RPGName(Attacker).."!~s"..SOUND_MURDER, "COLOR_RED")
			Victim:SendMessage("You were murdered by "..Attacker:RPGName(Victim).."!~s"..SOUND_MURDERED, "COLOR_RED")

			Attacker:AddMurderCount()
			Attacker:CapCriminal(CurTime() + CRIMINAL_KILL)
		end
	else
		Victim:SendMessage("You were killed by #"..Attacker:GetClass().."!", "COLOR_RED")
	end
end

function GM:PlayerLoadout(pl)
end

function GM:CanPlayerSuicide(pl)
	return pl:Alive()
end

function GM:PlayerHeal(pl, caster, amount)
	pl:SetHealth(math.min(pl:GetMaxHealth(), pl:Health() + math.ceil(amount)))
	caster:BeneficialAction(pl)
end

concommand.Add("PostPlayerInitialSpawn", function(sender, command, arguments)
	if not sender.PostPlayerInitialSpawn then
		sender.PostPlayerInitialSpawn = true

		gamemode.Call("PlayerReady", sender)
	end
end)

function GM:DelayFeed(pl)
	if pl:IsValid() then
		pl:UpdateSkills()
		pl:UpdateInventory()

		for _, p in pairs(player.GetAll()) do
			if p:IsMonster() then
				p:UpdateMonsterClass(pl)
			end
		end

		UpdateAllActiveGuilds(pl)
	end
end

function GM:PlayerReady(pl)
	if pl:IsValid() then
		timer.Simple(1, function() gamemode.Call("DelayFeed", pl) end)
	end
end

function GM:InitialVariables(pl)
	pl.InitialSpawned = CurTime()
	pl.LastInfo = {}
	pl.LastDeath = 0
	pl:SetNextAttack(0)
	pl:ClearLastAttacker()
	pl.NextPainSound = 0

	pl.ManaRegenerate = 0
	pl.MaxMana = 0
	pl.ManaBase = 0
	--[[pl.StaminaRegenerate = 0
	pl.MaxStamina = 0
	pl.StaminaBase = 0]]

	pl.m_NextSecondTick = 0
	pl.ViewOffset = 22

	pl:SprintDisable()
	pl:SetCanWalk(false)
	pl:SetCanZoom(false)

	gamemode.Call("InitialQuery", pl)
end

function GM:PlayerDisconnected(pl)
	if pl:IsValid() then
		pl:GuildNoLongerPlaying()
		pl:CallMonsterFunction("PlayerDisconnected")

		self:SaveAccount(pl)

		pl:RemoveAllProjectiles()

		PrintMessage(HUD_PRINTTALK, pl:NoParseName().." <defc=255,0,0>has left the area. The player population is now ".. #player.GetAll() - 1 ..".")
	end
end

function GM:SaveAccount(pl)
	if not pl:GetContainer() then return end -- Probably didnt load if this isnt created

	local savetab = {}

	pl:InsertRPGData(savetab)

	file.Write(pl:RPGAccountFile(), Serialize(savetab))

	pl:PrintMessage(HUD_PRINTCONSOLE, "Your character has been saved.")
end

function GM:LoadAccount(pl)
	if not IsValid(pl) then return end

	local file_name = pl:RPGAccountFile()

	if file.Exists(file_name, "DATA") then
		table.Merge(pl:GetTable(), Deserialize(file.Read(file_name, "DATA"), ITEM_DESERIALIZE_ENV))
	end

	pl:PrintMessage(HUD_PRINTCONSOLE, "Your character has been loaded.")
end

function GM:SetupPlayerDefaults(pl)
	pl.Mana = pl.Mana or 0
	pl.ManaRegenerate = pl.ManaRegenerate or 0
	pl.MaxMana = pl.MaxMana or 0

	pl.LongTermMurders = pl.LongTermMurders or 0

	--[[pl.Stamina = pl.Stamina or 0
	pl.StaminaRegenerate = pl.StaminaRegenerate or 0
	pl.MaxStamina = pl.MaxStamina or 0]]

	pl.m_CarryOverRegeneration = pl.m_CarryOverRegeneration or 0

	pl:SetupDefaultSkills()
	pl:SetupPlayerInventory()
end

function GM:PlayerInitialSpawn(pl)
	self:InitialVariables(pl)
	self:LoadAccount(pl)

	PrintMessage(HUD_PRINTTALK, pl:NoParseName().." <defc=20,120,255>has entered the area. The player population is now "..#player.GetAll()..".")

	self:SetupPlayerDefaults(pl)
	self:PlayerInitialSpawnBasedOn(pl, nil, true)
end

function GM:GiveStartingGear(pl)
	if not pl.FirstJoin then
		pl.FirstJoin = true

		local sword = Item(nil, "weapon_sword_peasant")
		sword.Bound = true
		sword.Starter = true
		pl:AddItem(sword)
	end
end

function GM:PlayerInitialSpawnBasedOn(pl, tab, isfirstspawn)
	tab = tab or pl

	--tab.Map

	if tab.RPGIsMonster or pl:IsMonster() then
		pl:GuildNoLongerPlaying()
		pl:SetTeam(TEAM_MONSTER)
		pl:SetMonsterClass(tab.MonsterClass or 1)
		pl:SetGhost(false)
		if isfirstspawn then
			timer.Simple(0.1, function() pl:UpdateMonsterClass() end)
		end
	else
		pl:SetTeam(TEAM_HUMAN)

		if tab.IsDead then
			pl:SetGhost(true)
		else
			self:GiveStartingGear(pl)

			pl:EquipAllByUIDs(tab.EquippedUIDs, true, true)
		end

		pl:RefreshGuild()
	end

	if tab.Position then
		pl:SetPos(tab.Position)
	end
	if tab.Angles then
		pl:SetAngles(tab.Angles)
	end
	if tab.Velocity then
		pl:SetLocalVelocity(tab.Velocity)
	end
	if tab.Health and type(tab.Health) == 'number' then
		pl:SetHealth(tab.Health)
	end
	--[[if tab.Stamina then
		pl:SetStamina(tab.Stamina)
	end]]
	if tab.Mana then
		pl:SetMana(tab.Mana)
	end

	if not pl:IsMonster() then
		pl.Banks = pl.Banks or tab.Banks or {}
	end

	if tab.ShortTermMurders then
		pl:SetShortTermMurders(tab.ShortTermMurders)
	end
	if tab.LongTermMurders then
		pl:SetLongTermMurders(tab.LongTermMurders)
	end
	pl.MurderTimer = tab.MurderTimer or 0

	pl:TemporaryNoCollide()
end

function GM:PlayerCastedSpell(pl, spelltab, target, attacker)
	--[[if spelltab.SkillRequirements and (spelltab.SkillUpOnUse or (spelltab.SkillUpOnTarget and (target or attacker))) then
		for skillid, amount in pairs(spelltab.SkillRequirements) do
			hook.Call("PlayerUseSkill", GAMEMODE, pl, skillid, amount * SKILLS_RMAX)
		end
	end]]

	pl:CallMonsterFunction("PlayerCastedSpell", spelltab, target, attacker)
end

function GM:PlayerUseSkill(pl, skillid, difficulty, failed)
	if not pl:Alive() then return end

	if SKILLS[skillid].Group ~= SKILLGROUP_MINOR then return end

	local current = pl:GetSkill(skillid)
	if current >= SKILLS_MAX then return end

	if failed then difficulty = difficulty * SKILLS_FAILUREMULTIPLIER end

	if current <= math.Rand(0, SKILLS_MAX * difficulty) then
		pl:SkillUp(skillid, difficulty)
	end

	--[[if SKILLS[skillid].Supplements then
		for subskillid, subdifficulty in pairs(SKILLS[skillid].Supplements) do
			hook.Call("PlayerUseSkill", GAMEMODE, pl, subskillid, difficulty * subdifficulty)
		end
	end]]
end

function GM:PlayerUsedOffensiveSpell(pl, spelltab, projectile, hitentity)
	--[[if spelltab.SkillRequirements and gamemode.Call("PlayerShouldSkillUp", pl, hitentity) then
		for skillid, amount in pairs(spelltab.SkillRequirements) do
			hook.Call("PlayerUseSkill", GAMEMODE, pl, skillid, (amount * SKILLS_RMAX + pl:GetHostileSkillUpDifficulty(pl)) / 2)
		end
	end]]
end

function GM:PlayerSkillUp(pl, skillid, difficulty)
	--[[local skillgroup = SKILLS[skillid].Group
	local curskill = pl:GetSkill(skillid)
	local room = math.huge
	if skillgroup and SKILLGROUPMAX[skillgroup] then
		local total = pl:TotalSkillGroup(skillgroup)
		room = math.max(0, SKILLGROUPMAX[skillgroup] - total)
		if room == 0 then return end
	end

	pl:SetSkill(skillid, math.min(SKILLS_MAX, curskill + math.min(room, self:GetSkillInterval(curskill))))
	pl:SendMessage(string.format("Your %s skill has increased to %.1f!", SKILLS[skillid].Name, pl.Skills[skillid]), "COLOR_LIMEGREEN", true)]]
end

function GM:OnEnterZone(zoneent, ent)
	ent:SetZone(zoneent.DataName)

	if ent:IsPlayer() and ent:Alive() then
		ent:SendMessage(string.format("You have entered %s.~s%s", tostring(zoneent.DisplayName), tostring(zoneent.EnterSound)), nil, true)
		if zoneent.Ruleset ~= RULESET_DEFAULT then
			local rulestr = zone.RulesetNames[zoneent.Ruleset]
			if rulestr then
				ent:SendMessage("This is "..util.AOrAn(rulestr).." zone."..(zoneent.Ruleset >= RULESET_PROTECTED and ent:IsMurderer() and " Leave immediately or face retribution!" or ""), nil, true)
			end
		end

		if ent:IsMurderer() then
			ent:Retribution()
		end

		ent:CallMonsterFunction("OnEnterZone", zoneent)
	end
end

function GM:OnLeaveZone(zoneent, ent)
	if ent.m_Zone == zoneent.DataName then
		ent:ClearZone()

		if ent:IsPlayer() and ent:Alive() then
			ent:SendMessage(string.format("You have left %s.~s%s", tostring(zoneent.DisplayName), tostring(zoneent.ExitSound)), nil, true)
			if zoneent.Ruleset >= RULESET_PROTECTED then
				ent:SendMessage("You have left a protected area.", nil, true)
			end

			ent:Retribution()

			ent:CallMonsterFunction("OnExitZone", zoneent)
		end
	end

	if ent:IsPlayer() then
		ent:TemporaryNoCollide()
	end
end

function GM:InitialQuery(pl)
end

function GM:PlayerSpawn(pl)
	pl:SoftFreeze(false)

	pl.SpawnTime = CurTime()
	pl.NextSpell = 0
	pl:ClearLastAttacker()
	pl:ShouldDropWeapon(false)

	if pl.ChangedGravity then
		pl:SetGravity(1)
		pl.ChangedGravity = nil
	end

	if pl:IsMonster() then
		if not pl:ImplicitCallMonsterFunction("PlayerSpawn") then
			pl:ResetData(pl:GetMonsterClassTable())
		end
	else
		pl:ResetData()

		for skillid in pairs(SKILLS) do
			gamemode.Call("PlayerSkillChanged", pl, skillid, pl:GetSkill(skillid))
		end

		pl:RefreshPlayerModel()
		pl:RefreshVoiceSet()

		if not pl:IsGhost() and not pl:GetActiveWeapon():IsValid() then
			pl:Give("weapon_hands")
		end
	end

	pl:SetHealth(math.min(pl:Health(), pl:GetMaxHealth()))

	net.Start("rpg_playerspawn")
	net.WriteEntity(pl)
	net.Broadcast()
end

function GM:PlayerUseWeapon(pl, item, onlyputon, silent)
	local swepclass = item.SWEP
	if not swepclass then return false end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.CanHolster and not wep:CanHolster() then return false end

		if wep:GetItem() == item then
			if not onlyputon then
				pl:StripWeapons()
				pl:Give("weapon_hands")
				if not silent then
					pl:SendMessage("You unequip "..item:GetDisplayName()..".", nil, true)
				end
			end

			return true
		end
	end

	pl:StripWeapons()
	pl:Give(swepclass)
	pl:SelectWeapon(swepclass)

	local newwep = pl:GetWeapon(swepclass)
	if newwep and newwep:IsValid() then
		newwep:SetItem(item)

		if not silent then
			pl:SendMessage("You equip "..item:GetDisplayName()..".", nil, true)
		end

		return true
	end

	return false
end

function GM:PlayerUseWearable(pl, item, onlyputon, silent)
	if item.WearableSlot and item.WearableSlot ~= WEARABLE_SLOT_WEAPON then
		local current = pl:GetWearable(item.WearableSlot, true)
		if current and current:IsValid() then
			if current:GetItem() == item then
				if not onlyputon then
					current:Remove()
					if current:GetItem().WearableSlot == WEARABLE_SLOT_BODY then pl:RefreshPlayerModel() end
					if not silent then
						pl:SendMessage("You unequip "..item:GetDisplayName()..".", nil, true)
					end

					return true
				end
			else
				current:Remove()
			end
		end

		local status = pl:GiveStatus(item._D)
		if status and status:IsValid() then
			status:SetItem(item)

			if item.WearableSlot == WEARABLE_SLOT_BODY then pl:RefreshPlayerModel() end

			if not silent then
				pl:SendMessage("You equip "..item:GetDisplayName()..".", nil, true)
			end

			return true
		end
	end

	return false
end

function GM:PlayerDropWeapon(pl, item)
	if item then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep:GetItem() == item then
			if wep.CanDrop and not wep:CanDrop() then return false end

			wep:Remove()

			return true
		end
	end

	return false
end

function GM:PlayerDropWearable(pl, item)
	if item then
		for _, status in pairs(ents.FindByClass("status_*")) do
			if status:GetOwner() == pl and status:GetItem() == item then
				if status.CanDrop and not status:CanDrop() then return false end

				status:Remove()

				return true
			end
		end
	end

	return false
end

function GM:WeaponEquip(weapon)
end

function GM:OnPhysgunReload(weapon, pl)
end

concommand.Add("rpg_test_printmyinventory_server", function(sender, command, arguments)
	print(sender:Name().." inventory")
	PrintTable(sender:GetContainer())
end)

concommand.Add("rpg_test_printmyskills_server", function(sender, command, arguments)
	print(sender:Name().." skills")
	PrintTable(sender.Skills)
end)

concommand.Add("rpg_pickupitem", function(sender, command, arguments)
	if sender:IsMonster() then return end

	local id = tonumber(arguments[1])
	if not id then return end
	local ent = Entity(id)
	if not IsValid(ent) then return end

	local item = ent:GetItem()
	if not item then return end

	if item:IsTransferableBy(sender, sender:GetContainer()) and sender:AddItem(item) then
		local displayname = item:GetDisplayName()
		sender:Thought("You pick up "..displayname..".")
		PrintMessageToVisibleRadius(HUD_PRINTTALK, "> You notice "..sender:NoParseName().." pick up "..displayname..".", ent:NearestPoint(sender:EyePos()), RADIUS_GENERICACTIONMESSAGE, sender)
	else
		sender:Thought("You can't pick up "..item:GetDisplayName()..".")
	end
end)

concommand.Add("rpg_interact", function(sender, command, arguments)
	local id = tonumber(arguments[1])
	if not id then return end

	local item = Items[id]
	if item then
		sender:InteractItem(item, table.concat(arguments, " ", 2))
	end
end)

-- Player can bind this to use either an item's DataName (any item with that type) or a UID (a specific item).
concommand.Add("rpg_useitem", function(sender, command, arguments)
	print(table.concat(arguments, " "))
	local item = sender:GetItemByUIDOrDataName(table.concat(arguments, " "))
	if item then
		sender:UseItem(item)
	end
end)

concommand.Add("rpg_transferitem", function(sender, command, arguments)
	local itemid = tonumber(arguments[1])
	if not itemid then return end
	local contid = tonumber(arguments[2])
	if not contid then return end

	local container = Items[contid]
	local item = Items[itemid]
	if item and container then
		sender:TransferItem(item, container, tonumber(arguments[3]), tonumber(arguments[4]))
	end
end)

concommand.Add("rpg_moveitem", function(sender, command, arguments)
	local id = tonumber(arguments[1])
	if not id then return end

	local item = Items[id]
	if item then
		sender:MoveItem(item, tonumber(arguments[2]) or 0, tonumber(arguments[3]) or 0)
	end
end)

function PrintMessageToRadius(messagetype, message, pos, radius, exclude)
	for _, pl in pairs(ents.GetPlayersInRadius(pos, radius, exclude)) do
		pl:PrintMessage(messagetype, message)
	end
end

function PrintMessageToVisibleRadius(messagetype, message, pos, radius, exclude)
	for _, pl in pairs(ents.GetPlayersInVisibleRadius(pos, radius, exclude)) do
		pl:PrintMessage(messagetype, message)
	end
end

concommand.Add("rpg_dropitem", function(sender, command, arguments)
	local id = tonumber(arguments[1])
	if not id then return end

	local item = Items[id]
	if item then
		sender:DropItem(item, math.ceil(tonumber(arguments[2]) or 1))
	end
end)

concommand.Add("rpg_requestinventory", function(sender, command, arguments)
	if sender:IsMonster() or not sender:Alive() then return end

	local index = tonumber(arguments[1])
	if not index then return end
	local ent = Entity(index)
	if IsValid(ent) then
		local container = ent:GetContainer()
		if container and container:IsViewableBy(sender) then
			container:Sync(sender)
		end
	end
end)

concommand.Add("rpg_requestitem", function(sender, command, arguments)
	local id = tonumber(arguments[1])
	if not id then return end

	local item = Items[id]
	if item and item:IsViewableBy(sender) then
		item:Sync(sender)
	end
end)
