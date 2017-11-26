zone = {}

local zones = {}

function GetAllZones()
	return zones
end
AllZones = GetAllZones

--[[
RULESET_SAFE -- No hostile or beneficial actions allowed at all.
RULESET_PROTECTED -- No hostile or beneficial actions between players that are not both in a guild.
RULESET_OPEN -- Default ruleset. Standard flagging.
RULESET_FREEFORALL -- Open but with no flagging.
RULESET_ARENA -- Same as free for all but no dropping of stuff and dying is artificial.
]]

zone.RulesetNames = {
	[RULESET_SAFE] = "safe",
	[RULESET_PROTECTED] = "protected",
	[RULESET_OPEN] = "open",
	[RULESET_FREEFORALL] = "free-for-all",
	[RULESET_ARENA] = "arena"
}

function zone.ProcessDamage(ent, dmginfo)
	local zonedata = zones[ent:GetZone()]
	if zonedata then
		if zonedata.Weather == WEATHER_SNOW then
			if dmginfo:GetDamageType() == DMGTYPE_COLD then
				dmginfo:SetDamage(dmginfo:GetDamage() * 1.1)
			elseif dmginfo:GetDamageType() == DMGTYPE_FIRE then
				dmginfo:SetDamage(dmginfo:GetDamage() * 0.9)
			end
		end
	end
end

function zone.CanDoHostileAction(from, to)
	if not to:Alive() then return false end

	if from == to then return true end

	local minruleset = math.min(zones[from:GetZone()].Ruleset, zones[to:GetZone()].Ruleset)

	-- Completely safe; absolutely no damage even from and to monsters.
	if minruleset == RULESET_SAFE then
		return false
	end

	-- Monsters can always damage or be damaged.
	if from:IsMonster() or to:IsMonster() then return true end

	-- OLD:
	-- Warring guilds can attack each other.
	--[[if minruleset == RULESET_PROTECTED then
		return to:IsInGuild() and from:IsInGuild() and to:IsGuildEnemy(from)
	end]]

	-- People can always attack each other.
	-- If you perform a criminal action in protected territory then you inact divine retribution.
	-- This is on a timer of let's say 10 seconds by default.
	-- Every time you perform a criminal action the timer goes down early by 5 seconds or so.
	-- Murderers and monsters will inact retribution on a timer of 5 seconds simply by being in the zone (check on both adding a murder count and entering the zone).
	return true
end

function zone.CanDoBeneficialAction(from, to)
	--if not to:Alive() then return false end

	if from == to then return true end

	local minruleset = math.min(zones[from:GetZone()].Ruleset, zones[to:GetZone()].Ruleset)

	-- If we're in a completely safe area.
	if minruleset == RULESET_SAFE then
		return false
	end

	if from:IsMonster() or to:IsMonster() then return true end

	-- A person in a guild can only be helped by enemies (misfires) or people in the same guild.
	if minruleset == RULESET_PROTECTED then
		return to:IsInGuild() and from:IsInGuild() and (to:IsInSameGuild(from) or to:IsGuildEnemy(from))
		--[[local frominguild = from:IsInGuild()
		local toinguild = to:IsInGuild()
		if frominguild then return toinguild end
		if toinguild then return frominguild end]]
	end

	return true
end
zone.CanDoHelpfulAction = zone.CanDoBeneficialAction

function zone.GetAllInZone(dataname)
	return zone.GetClassInZone(dataname, "*")
end

function zone.GetPlayersInZone(dataname)
	return zone.GetClassInZone(dataname, "player")
end

function zone.GetNPCsInZone(dataname)
	return zone.GetClassInZone(dataname, "npc_*")
end

function zone.GetItemsInZone(dataname)
	return zone.GetClassInZone(dataname, "item_*")
end

--[[function zone.GetAllHumanSpawns(dataname)
	return zone.GetClassInZone(dataname, "point_rpghumanspawnpoint")
end

function zone.GetAllMonsterSpawns(dataname, monsterclass, monstergroup)
	return zone.GetClassInZone(dataname, "point_rpgmonsterspawnpoint")
end

function zone.GetBestHumanSpawn(dataname)
	local tab = zone.GetAllHumanSpawns(dataname)
	if #tab == 0 then return end

	local potential = {}
	for _, spawnpoint in pairs(tab) do
		local invalid
		for _, ent in ents.FindInBox(ent:GetPos() + Vector(-24, -24, 0), ent:GetPos() + Vector(24, 24, 72)) do
			if ent:IsPlayer() then
				invalid = true
				break
			end
		end
		if not invalid then
			potential[#potential + 1] = spawnpoint
		end
	end

	if #potential == 0 then return tab[math.random(1, #tab)] end

	return potential[math.random(1, #potential)]
end

function zone.GetBestMonsterSpawn(dataname, monsterclass, monstergroup)
	local tab = zone.GetAllMonsterSpawns(dataname, monsterclass, monstergroup)
	if #tab == 0 then return end

	local potential = {}
	for _, spawnpoint in pairs(tab) do
		local invalid
		for _, ent in ents.FindInBox(ent:GetPos() + Vector(-24, -24, 0), ent:GetPos() + Vector(24, 24, 72)) do
			if ent:IsPlayer() then
				invalid = true
				break
			end
		end
		if not invalid then
			potential[#potential + 1] = spawnpoint
		end
	end

	if #potential == 0 then return tab[math.random(1, #tab)] end

	return potential[math.random(1, #potential)]
end]]

function zone.GetClassInZone(dataname, class)
	local tab = {}

	for _, ent in pairs(ents.FindByClass(class)) do
		if ent:GetZone() == dataname then
			tab[#tab + 1] = ent
		end
	end

	return tab
end

if SERVER then
	function zone.CreateZone(dataname, displayname, pos, radius, mins, maxs, ruleset, entersound, exitsound, guildid)
		if zones[dataname] then
			ErrorNoHalt("Zone "..tostring(dataname).." already exists!")
			return false
		end

		local ent = ents.Create("point_rpgzone")
		if ent:IsValid() then
			ent.Initializing = true
			ent:SetDataName(dataname)
			ent:SetPosition(pos)
			if mins and maxs then
				ent:SetMins(mins)
				ent:SetMaxs(maxs)
			elseif radius then
				ent:SetRadius(radius)
			end
			if ruleset then
				ent:SetRuleset(ruleset)
			end
			if guild then
				ent:SetGuild(guildid)
			end
			ent:SetEnterSound(entersound)
			ent:SetExitSound(exitsound)
			ent:SetDisplayName(displayname)
			ent.Initializing = nil
			ent:Spawn()

			ent:Fire("registerzone", "", 0)

			return ent
		end
	end

	hook.Add("PlayerReady", "PlayerReady_UpdateAllZones", function(pl)
		gamemode.Call("UpdateAllZones", pl)
	end)

	hook.Add("InitPostEntity", "InitPostEntity_AddUnknownZone", function()
		local ent = zone.CreateZone("0", "Unknown", Vector(31000, 31000, 31000), 1, nil, nil, RULESET_DEFAULT)
		if ent then
			ent.Persist = false
		end
	end)
end
