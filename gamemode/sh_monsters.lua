MONSTERGROUP_NONE = 1
MONSTERGROUP_CHARGERBUG = 2
MONSTERGROUP_EVIL_UNDEAD = 3

MonsterGroups = {}
MonsterGroups[MONSTERGROUP_NONE] = "Loner"
MonsterGroups[MONSTERGROUP_CHARGERBUG] = "Charger Bugs"
MonsterGroups[MONSTERGROUP_EVIL_UNDEAD] = "Undead"

MonsterClasses = {}
function RegisterMonsterClass(name, tab)
	if tab.Index then
		MonsterClasses[tab.Index] = tab
	else
		table.insert(MonsterClasses, tab)
		tab.Index = #MonsterClasses
	end

	MonsterClasses[name] = tab
end

for i, filename in ipairs(file.Find(GAMEMODEFOLDER.."/gamemode/monsterclasses/*.lua", "LUA")) do
	AddCSLuaFile("monsterclasses/"..filename)

	CLASS = {}
	include("monsterclasses/"..filename)

	if not CLASS.Index then
		ErrorNoHalt("WARNING! CLASS "..filename.." has no 'Index' member! This can cause conflicts!")
	end

	if CLASS.Name then
		RegisterMonsterClass(CLASS.Name, CLASS)
	else
		ErrorNoHalt("ERROR! CLASS "..filename.." has no 'Name' member!")
	end

	CLASS = nil
end
