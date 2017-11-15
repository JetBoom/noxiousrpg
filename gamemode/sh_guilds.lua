-- This needs to work across multiple servers accessing the same data! Load, do the changes, then save.

-- TODO: Get rid of numeric indexes. Only index UIDs

local guilds = {}

function NewGuildUID()
	local i = TEAM_HUMAN + 1

	while guilds[i] do
		i = i + 1
	end

	return i
end

function GetAllGuilds()
	return guilds
end

function UpdateAllActiveGuilds(pl)
	local allplayers = player.GetAll()
	local activeguilds = {}

	for _, p in pairs(allplayers) do
		local id = p:GetGuildID()
		if id then
			activeguilds[id] = guilds[id]
		end
	end

	local str = Serialize(activeguilds)

	if not pl then
		for _, e in pairs(allplayers) do
			e:SendLongString(LONGSTRING_UPDATEALLGUILDS, str)
		end
		return
	end

	pl:SendLongString(LONGSTRING_UPDATEALLGUILDS, str)
end

function UpdateAllGuilds(pl)
	local str = Serialize(guilds)

	if pl then
		pl:SendLongString(LONGSTRING_UPDATEALLGUILDS, str)
	else
		for _, e in pairs(player.GetAll()) do
			e:SendLongString(LONGSTRING_UPDATEALLGUILDS, str)
		end
	end
end

function UpdateGuild(uid, pl)
	if not guilds[uid] then return end

	local str = uid.."§"..Serialize(guilds[uid])

	if pl then
		pl:SendLongString(LONGSTRING_UPDATEGUILD, str)
	else
		for _, e in pairs(player.GetAll()) do
			e:SendLongString(LONGSTRING_UPDATEGUILD, str)
		end
	end
end

function NewGuild(name, owneruid)
	gamemode.Call("LoadGuilds", true)

	local tab = {}

	tab.Name = name
	tab.Owner = owneruid
	tab.Members = 0
	tab.UID = NewGuildUID()
	tab.Attitudes = {}

	guilds[tab.UID] = tab

	GAMEMODE:RegisterGuild(tab.UID)

	gamemode.Call("OnGuildCreated", name, owneruid, tab.UID)

	return tab
end

function DisbandGuild(id)
	gamemode.Call("LoadGuilds", true)

	if not guilds[id] or guilds[id].Permanent then return end

	gamemode.Call("OnGuildRemoved", id)

	table.remove(guilds, id)
end

function GetPlayersInGuild(id)
	local tab = {}

	if guilds[id] then
		for _, pl in pairs(player.GetAll()) do
			if pl:GetGuildID() == id then
				table.insert(tab, pl)
			end
		end
	end

	return tab
end

function GuildIsAlly(fromid, toid)
	return GuildAttitude(fromid, toid) <= GUILDATTITUDE_ALLY
end

function GuildIsFriendly(fromid, toid)
	return GuildAttitude(fromid, toid) <= GUILDATTITUDE_FRIENDLY
end

function GuildIsEnemy(fromid, toid)
	return GuildAttitude(fromid, toid) >= GUILDATTITUDE_ENEMY
end

function GuildAttitude(fromid, toid)
	local guildfrom = guilds[fromid]
	local guildto = guilds[toid]
	if guildfrom and guildto then
		return math.max(guildfrom.Attitudes[toid] or GUILDATTITUDE_DEFAULT, guildto.Attitudes[fromid] or GUILDATTITUDE_DEFAULT)
	end

	return GUILDATTITUDE_DEFAULT
end

function SetGuildAttitude(fromid, toid, attitude)
	local guildfrom = guilds[fromid]
	if guildfrom and guilds[toid] then
		guildfrom.Attitudes[toid] = attitude

		UpdateGuild(fromid)
	end
end

function GM:OnGuildRemoved(uid)
	for _, pl in pairs(player.GetAll()) do
		if pl.RPGGuildUID == uid then
			pl:RemoveGuild()
		end
	end

	UpdateAllActiveGuilds()

	gamemode.Call("SaveGuilds")
end

function GM:OnGuildCreated(name, owneruid, uid)
	for _, pl in pairs(player.GetAll()) do
		if pl:UniqueID() == owneruid then
			if not pl:IsInGuild() then
				pl:JoinGuild(uid)
			end
			break
		end
	end

	UpdateGuild(uid)

	gamemode.Call("SaveGuilds")
end

local colGeneric = Color(20, 120, 255, 255)
function GM:RegisterGuild(id)
	local guild = guilds[id]
	if not guild then return end

	team.SetUp(TEAM_HUMAN + id, guild.Name, colGeneric)
end

if SERVER then
	function GM:SaveGuilds()
		file.Write("noxiousrpg_guilds.txt", Serialize(guilds))
	end

	function GM:LoadGuilds(noupdate)
		local cont = file.Read("noxiousrpg_guilds.txt")
		if not cont then return end

		guilds = Deserialize(cont)

		for i in pairs(guilds) do
			self:RegisterGuild(i)
		end

		if not noupdate then
			UpdateAllActiveGuilds()
		end
	end

	function PrintGuildMessage(id, messagetype, message)
		for _, pl in pairs(GetPlayersInGuild(id)) do
			pl:PrintMessage(messagetype, message)
		end
	end
end

if CLIENT then
	NDB.AddContentsCallback(LONGSTRING_UPDATEGUILD, function(contents)
		local id, str = string.match(contents, "(%d+)§(.+)")
		id = tonumber(id)
		if not id or not str then return end

		guilds[id] = Deserialize(str)

		GAMEMODE:RegisterGuild(id)
	end)

	NDB.AddContentsCallback(LONGSTRING_UPDATEALLGUILDS, function(contents)
		local newguilds = Deserialize(contents)

		if newguilds then
			guilds = newguilds
			for i in pairs(guilds) do
				GAMEMODE:RegisterGuild(i)
			end
		end
	end)
end
