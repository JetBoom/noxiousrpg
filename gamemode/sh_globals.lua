PLAYER_HULL_MIN_DEFAULT = Vector(-16, -16, 0)
PLAYER_HULL_MAX_DEFAULT = Vector(16, 16, 72)
PLAYER_HULL_MIN = PLAYER_HULL_MIN_DEFAULT
PLAYER_HULL_MAX = PLAYER_HULL_MAX_DEFAULT
PLAYER_HULL_DUCKED_MIN_DEFAULT = Vector(-16, -16, 0)
PLAYER_HULL_DUCKED_MAX_DEFAULT = Vector(16, 16, 48)
PLAYER_HULL_DUCKED_MIN = PLAYER_HULL_DUCKED_MIN_DEFAULT
PLAYER_HULL_DUCKED_MAX = PLAYER_HULL_DUCKED_MAX_DEFAULT
PLAYER_STEPSIZE_DEFAULT = 18
PLAYER_STEPSIZE = PLAYER_STEPSIZE_DEFAULT
PLAYER_VIEWOFFSET_DEFAULT = Vector(0, 0, 64)
PLAYER_VIEWOFFSET_DUCKED_DEFAULT = Vector(0, 0, 42)
PLAYER_VIEWOFFSET = PLAYER_VIEWOFFSET_DEFAULT
PLAYER_VIEWOFFSET_DUCKED = PLAYER_VIEWOFFSET_DUCKED_DEFAULT
PLAYER_JUMPPOWER_DEFAULT = 180
PLAYER_JUMPPOWER = PLAYER_JUMPPOWER_DEFAULT
PLAYER_STEP_SIZE_DEFAULT = 18
PLAYER_STEP_SIZE = PLAYER_STEP_SIZE_DEFAULT
PLAYER_MASS = 80
PLAYER_MASS = PLAYER_MASS_DEFAULT
PLAYER_MODELSCALE_DEFAULT = 1
PLAYER_MODELSCALE = PLAYER_MODELSCALE_DEFAULT

DMGTYPE_GENERIC = DMG_GENERIC
DMGTYPE_CUTTING = DMG_SLASH
DMGTYPE_IMPACT = DMG_CRUSH
DMGTYPE_PIERCING = DMG_BULLET
DMGTYPE_ARCANE = DMG_DIRECT
DMGTYPE_FIRE = DMG_BURN
DMGTYPE_SHOCK = DMG_SHOCK
DMGTYPE_COLD = DMG_DROWN
DMGTYPE_POISON = DMG_ACID

DAMAGETYPES = {
[DMGTYPE_GENERIC] = "Generic",
[DMGTYPE_CUTTING] = "Cutting",
[DMGTYPE_PIERCING] = "Piercing",
[DMGTYPE_IMPACT] = "Impact",
[DMGTYPE_ARCANE] = "Arcane",
[DMGTYPE_FIRE] = "Fire",
[DMGTYPE_SHOCK] = "Shock",
[DMGTYPE_COLD] = "Cold",
[DMGTYPE_POISON] = "Poison"
}
DMGTYPES = DAMAGETYPES

DMGTYPE_SLASHING = DMGTYPE_CUTTING
DMGTYPE_WIND = DMGTYPE_ENERGY
DMGTYPE_BLUDGEONING = DMGTYPE_IMPACT
DMGTYPE_BASHING = DMGTYPE_BLUDGEONING
DMGTYPE_ENERGY = DMGTYPE_SHOCK
DMGTYPE_LIGHTNING = DMGTYPE_ENERGY
DMGTYPE_ELECTRIC = DMGTYPE_LIGHTNING
DMGTYPE_ICE = DMGTYPE_COLD
DMGTYPE_WATER = DMGTYPE_COLD
DMGTYPE_AIR = DMGTYPE_ENERGY
DMGTYPE_WIND = DMGTYPE_AIR
DMGTYPE_VOID = DMGTYPE_ARCANE
DMGTYPE_BULLET = DMGTYPE_PIERCING
DMGTYPE_PIERCE = DMGTYPE_PIERCING

--[[STAMINA_DAMAGE = {
[DMGTYPE_GENERIC] = 1,
[DMGTYPE_CUTTING] = 1,
[DMGTYPE_IMPACT] = 1.5,
[DMGTYPE_ARCANE] = 1,
[DMGTYPE_FIRE] = 1.5,
[DMGTYPE_ENERGY] = 2,
[DMGTYPE_COLD] = 2
}

STAMINA_ABSORPTION = {
[DMGTYPE_GENERIC] = 0.25,
[DMGTYPE_CUTTING] = 0.4,
[DMGTYPE_IMPACT] = 0.6,
[DMGTYPE_ARCANE] = 0.5,
[DMGTYPE_FIRE] = 0.4,
[DMGTYPE_ENERGY] = 0.5,
[DMGTYPE_COLD] = 0.5
}]]

MURDERER_THRESHOLD = 5

CORPSE_ITEMCLASS = "container_corpse"
CORPSE_ENTCLASS = "item_"..CORPSE_ITEMCLASS

WORLDSAVE_INTERVAL = 300
WORLDSAVE_ENTITYLOADRATE = 0.025

COLOR_THINK = Color(10, 255, 10)
COLOR_THINK_TEXT = "<defc="..COLOR_THINK.r..","..COLOR_THINK.g..","..COLOR_THINK.b..">"

TALK_RADIUS = 1536
CONVERSATION_RADIUS = 512
CONVO_RADIUS = CONVERSATION_RADIUS

--TALK_FADEOUT_START = 0.5 -- TODO: Start to miss letters if too far away. Rate is based on distance.

TIME_DILIATION = 8
TIME_SECOND = 1 / TIME_DILIATION
TIME_MINUTE = TIME_SECOND * 60
TIME_HOUR = TIME_MINUTE * 60
TIME_DAY = TIME_HOUR * 24
TIME_WEEK = TIME_DAY * 7
TIME_MONTH = TIME_DAY * 30
TIME_SEASON = TIME_MONTH * 4
TIME_YEAR = TIME_MONTH * 12

LASTATTACKERTIME = 5

FORCE_KNOCKDOWN = 256
FORCE_KNOCKDOWN_NOGETUP = 300

SUNTIME_DAWN = 0.23
SUNTIME_NOON = 0.5
SUNTIME_DUSK = 0.75

GIB_DECAYTIME = 60

ITEM_ONUSE_NOTHING = 0
ITEM_ONUSE_DECREMENT = 1
ITEM_ONUSE_DESTROY = 2

ITEM_ONSMELT_NOTHING = 0
ITEM_ONSMELT_DESTROY = 1
ITEM_ONSMELT_DESTROYALL = 2

ITEM_DECAYTIME = 600

ITEM_DROPDELAY = 0.25

ITEM_MAXSTACK_DEFAULT = 1

ITEM_USABLEDISTANCE = 92

HOTBAR_CELLCOUNT = 6

HOTBAR_CELLTYPE_ITEM = 0
HOTBAR_CELLTYPE_ITEMDATANAME = 1
HOTBAR_CELLTYPE_SPELL = 2
HOTBAR_CELLTYPE_CONSOLECOMMAND = 3
HOTBAR_CELLTYPE_CONCOMMAND = HOTBAR_CELLTYPE_CONSOLECOMMAND

LETTER_RANK_D = 1
LETTER_RANK_C = 2
LETTER_RANK_B = 3
LETTER_RANK_A = 4
LETTER_RANK_S = 5
LETTER_RANK_SS = 6
LETTER_RANK_SSS = 7

LETTER_RANKS = {
	[LETTER_RANK_D] = "D",
	[LETTER_RANK_C] = "C",
	[LETTER_RANK_B] = "B",
	[LETTER_RANK_A] = "A",
	[LETTER_RANK_S] = "S",
	[LETTER_RANK_SS] = "SS",
	[LETTER_RANK_SSS] = "SSS"
}

LETTER_RANK_POWERS = {
	[LETTER_RANK_D] = 0.1,
	[LETTER_RANK_C] = 0.2,
	[LETTER_RANK_B] = 0.3,
	[LETTER_RANK_A] = 0.4,
	[LETTER_RANK_S] = 0.5,
	[LETTER_RANK_SS] = 0.75,
	[LETTER_RANK_SSS] = 1
}

ENCHANT_TYPE_FOOL = 1
ENCHANT_TYPE_MAGICIAN = 2
ENCHANT_TYPE_PRIESTESS = 3
ENCHANT_TYPE_EMPRESS = 4
ENCHANT_TYPE_EMPEROR = 5
ENCHANT_TYPE_HIEROPHANT = 6
ENCHANT_TYPE_LOVERS = 7
ENCHANT_TYPE_CHARIOT = 8
ENCHANT_TYPE_STRENGTH = 9
ENCHANT_TYPE_HERMIT = 10
ENCHANT_TYPE_FORTUNE = 11
ENCHANT_TYPE_JUSTICE = 12
ENCHANT_TYPE_HANGEDMAN = 13
ENCHANT_TYPE_DEATH = 14
ENCHANT_TYPE_TEMPERANCE = 15
ENCHANT_TYPE_DEVIL = 16
ENCHANT_TYPE_TOWER = 17
ENCHANT_TYPE_STAR = 18
ENCHANT_TYPE_MOON = 19
ENCHANT_TYPE_SUN = 20
ENCHANT_TYPE_JUDGEMENT = 21
ENCHANT_TYPE_WORLD = 22

ENCHANT_TYPES = {
	[ENCHANT_TYPE_FOOL] = "Fool",
	[ENCHANT_TYPE_MAGICIAN] = "Magician",
	[ENCHANT_TYPE_PRIESTESS] = "Priestess",
	[ENCHANT_TYPE_EMPRESS] = "Empress",
	[ENCHANT_TYPE_EMPEROR] = "Emperor",
	[ENCHANT_TYPE_HIEROPHANT] = "Hierophant",
	[ENCHANT_TYPE_LOVERS] = "Lovers",
	[ENCHANT_TYPE_CHARIOT] = "Chariot",
	[ENCHANT_TYPE_STRENGTH] = "Strength",
	[ENCHANT_TYPE_HERMIT] = "Hermit",
	[ENCHANT_TYPE_FORTUNE] = "Fortune",
	[ENCHANT_TYPE_JUSTICE] = "Justice",
	[ENCHANT_TYPE_HANGEDMAN] = "Hanged Man",
	[ENCHANT_TYPE_DEATH] = "Death",
	[ENCHANT_TYPE_TEMPERANCE] = "Temperance",
	[ENCHANT_TYPE_DEVIL] = "Devil",
	[ENCHANT_TYPE_TOWER] = "Tower",
	[ENCHANT_TYPE_STAR] = "Star",
	[ENCHANT_TYPE_MOON] = "Moon",
	[ENCHANT_TYPE_SUN] = "Sun",
	[ENCHANT_TYPE_JUDGEMENT] = "Judgement",
	[ENCHANT_TYPE_WORLD] = "World"
}

WEARABLE_SLOT_WEAPON = 0
WEARABLE_SLOT_HEAD = 1
WEARABLE_SLOT_BODY = 2
WEARABLE_SLOT_JEWELRY = 3

ENCHANT_RECIPEES = {
	[ENCHANT_TYPE_STRENGTH] = {
		[WEARABLE_SLOT_WEAPON] = {
			{"ProjectileDamageMultiplier", 1.3},
			{"MeleeDamageMultiplier", 1.4}
		},
		[WEARABLE_SLOT_HEAD] = {
			{"ProjectileForceMultiplier", 1.5},
			{"ThrownForceMultiplier", 0.75}
		},
		[WEARABLE_SLOT_BODY] = {
			{"DamageMultiplier", 0.8},
			{"ThrownForceMultiplier", 0.5}
		},
		[WEARABLE_SLOT_JEWELRY] = {
			{"ProjectileDamageMultiplier", 1.2},
			{"MeleeDamageMultiplier", 1.25}
		}
	},
	[ENCHANT_TYPE_HERMIT] = {
		[WEARABLE_SLOT_WEAPON] = {
			{"Blessed"}
		},
		[WEARABLE_SLOT_HEAD] = {
			{"Blessed"}
		},
		[WEARABLE_SLOT_BODY] = {
			{"Blessed"}
		},
		[WEARABLE_SLOT_JEWELRY] = {
			{"Blessed"}
		}
	}
}

-- return false to not allow and pick a different enchantment. If there's none others then it's not allowed.
-- return anything else to directly set the value. power is the enchanting power (from the rankings).
-- return true or nil (or don't have a callback) to do item[KeyValue] = [2] == nil or ((item[KeyValue] or 0) + ([3] == nil and ([2] * power) or math.Round(math.Rand([2], [3]) * power, 2)))
ENCHANT_CALLBACKS = {
	["Fool"] = function(item, power) end, -- TODO: Wildcard. Picks any any other enchantment with the same power.
	["ProjectileDamageMultiplier"] = function(item, power) return item:IsRanged() end,
	["ProjectileForceMultiplier"] = function(item, power) return item:IsStaff() end,
	["MeleeDamageMultiplier"] = function(item, power) return item:IsMelee() end,
	["Blessed"] = function(item, power) return power >= LETTER_RANK_POWERS[LETTER_RANK_S] end -- The Hermit Arcana can bless items with an S+ rank.
}

BODY_TYPE_NONE = 0
BODY_TYPE_LIGHT = 1
BODY_TYPE_MEDIUM = 2
BODY_TYPE_HEAVY = 3

BODY_TYPE_MODELS = {
	[BODY_TYPE_NONE] = {
	"models/player/Group01/male_01.mdl",
	"models/player/Group01/male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/male_04.mdl",
	"models/player/Group01/male_05.mdl",
	"models/player/Group01/male_06.mdl",
	"models/player/Group01/male_07.mdl",
	"models/player/Group01/male_08.mdl",
	"models/player/Group01/male_09.mdl",
	"models/player/Group01/female_01.mdl",
	"models/player/Group01/female_02.mdl",
	"models/player/Group01/female_03.mdl",
	"models/player/Group01/female_04.mdl",
	"models/player/Group01/female_06.mdl",
	"models/player/Group01/female_07.mdl",
	"models/player/kleiner.mdl",
	"models/player/alyx.mdl",
	"models/player/breen.mdl",
	"models/player/eli.mdl",
	"models/player/gman_high.mdl",
	"models/player/monk.mdl",
	"models/player/mossman.mdl",
	"models/player/odessa.mdl",
	"models/player/magnusson.mdl",
	"models/player/soldier_stripped.mdl"},
	[BODY_TYPE_LIGHT] = {"models/player/Group03/male_01.mdl",
	"models/player/Group03/male_02.mdl",
	"models/player/Group03/male_03.mdl",
	"models/player/Group03/male_04.mdl",
	"models/player/Group03/male_05.mdl",
	"models/player/Group03/male_06.mdl",
	"models/player/Group03/male_07.mdl",
	"models/player/Group03/male_08.mdl",
	"models/player/Group03/male_09.mdl",
	"models/player/Group03/female_01.mdl",
	"models/player/Group03/female_02.mdl",
	"models/player/Group03/female_03.mdl",
	"models/player/Group03/female_04.mdl",
	"models/player/Group03/female_06.mdl",
	"models/player/Group03/female_07.mdl"},
	[BODY_TYPE_MEDIUM] = {"models/player/police.mdl",
	"models/player/barney.mdl"},
	[BODY_TYPE_HEAVY] = {"models/player/combine_soldier.mdl",
	"models/player/combine_soldier_prisonguard.mdl",
	"models/player/combine_super_soldier.mdl"}
}

FOOTSTEP_SETS = {
	[BODY_TYPE_MEDIUM] = {"npc/metropolice/gear1.wav",
		"npc/metropolice/gear2.wav",
		"npc/metropolice/gear3.wav",
		"npc/metropolice/gear4.wav",
		"npc/metropolice/gear5.wav",
		"npc/metropolice/gear6.wav"
	},
	[BODY_TYPE_HEAVY] = {"npc/combine_soldier/gear1.wav",
		"npc/combine_soldier/gear2.wav",
		"npc/combine_soldier/gear3.wav",
		"npc/combine_soldier/gear4.wav",
		"npc/combine_soldier/gear5.wav",
		"npc/combine_soldier/gear6.wav"
	}
}

if CLIENT then
	for id, tab in pairs(BODY_TYPE_MODELS) do
		local toinsert = {}
		for k, v in pairs(tab) do
			table.insert(toinsert, string.Replace(v, "/player", ""))
		end
		for k, v in pairs(toinsert) do
			table.insert(tab, v)
		end
	end
end

HOTBAR_BINDS = {
"slot1",
"slot2",
"slot3",
"slot4",
"slot5",
"slot6",
"slot7",
"slot8",
"slot9",
"slot0"
}
HOTBAR_HASHBINDS = {}
for k, v in pairs(HOTBAR_BINDS) do
	HOTBAR_HASHBINDS[v] = k
end
HOTBAR_HASHBINDS["slot0"] = 0

LONGSTRING_UPDATESKILLS = 101
LONGSTRING_UPDATEALLZONES = 102
LONGSTRING_UPDATEZONE = 103
LONGSTRING_UPDATEALLGUILDS = 104
LONGSTRING_UPDATEGUILD = 105
LONGSTRING_UPDATEITEM = 106

DIRECTION_UP = 0
DIRECTION_LEFT = 1
DIRECTION_DOWN = 2
DIRECTION_RIGHT = 3

POTION_REDRINKTIME = 5

CRIMINAL_INITIAL = 10
CRIMINAL_SUBSEQUENT = 15 -- ADDED on to the criminal's time for every hostile action against an innocent.
CRIMINAL_ATTACKED = 10 -- If the criminal is attacked then their time is set to AT LEAST this many seconds from now.
CRIMINAL_HELPMONSTER = 10
CRIMINAL_HELPCRIMINAL = 10
CRIMINAL_KILL = 90 -- ADDED if the player kills an innocent player.
CRIMINAL_MAXIMUM = 300
CRIMINAL_MAX = CRIMINAL_MAXIMUM

WEATHER_CLEAR = 0
WEATHER_FOG = 1
WEATHER_HEAVYFOG = 2
WEATHER_RAIN = 4
WEATHER_RAINING = WEATHER_RAIN
WEATHER_STORM = 8
WEATHER_DEFAULT = WEATHER_CLEAR

PLAYERCORPSE_DECAY = 600

PERSIST = {}

RULESET_SAFE = 0 -- No hostile actions allowed at all.
RULESET_PROTECTED = 1 -- No hostile actions unless both players are in a guild.
RULESET_OPEN = 2 -- Default ruleset. Standard flagging.
RULESET_FREEFORALL = 3 -- No flagging or criminal actions.
RULESET_ARENA = 4 -- Same as free for all but no dropping of stuff, nearly instant respawn.
RULESET_DUEL = RULESET_ARENA
RULESET_DUNGEON = RULESET_OPEN
RULESET_DEFAULT = RULESET_OPEN

GUILDATTITUDE_ALLY = 0
GUILDATTITUDE_FRIENDLY = 1
GUILDATTITUDE_NEUTRAL = 2
GUILDATTITUDE_ENEMY = 3
GUILDATTITUDE_DEFAULT = GUILDATTITUDE_NEUTRAL

MOUSE_TRACEDISTANCE = 1024

SKILLS_DEFAULT = 0
SKILLS_FAILUREMULTIPLIER = 0.25
SKILLS_MAX = 100
SKILLS_RMAX = 1 / SKILLS_MAX
SKILLS_INTERVAL = 0.1
SKILLS_INCREMENT = SKILLS_INTERVAL
SKILLS_NUMBEROFSTARTINGSKILLS = 3
SKILLS_STARTINGSKILLAMOUNT = 30

SKILL_STRENGTH = 1
SKILL_VITALITY = 2
SKILL_DEXTERITY = 3
SKILL_ENDURANCE = SKILL_DEXTERITY
--SKILL_STAMINA = SKILL_DEXTERITY
SKILL_INTELLIGENCE = 4
SKILL_MANA = SKILL_INTELLIGENCE
SKILL_BLADES = 5
SKILL_SWORDS = SKILL_BLADES
SKILL_SWORDSMANSHIP = SKILL_BLADES
SKILL_POLEARMS = 6
SKILL_POLEARM = SKILL_POLEARMS
SKILL_BLUDGEONING = 7
SKILL_MACING = SKILL_BLUDGEONING
SKILL_MACES = SKILL_BLUDGEONING
SKILL_ARCHERY = 8
SKILL_BOWS = SKILL_ARCHERY
SKILL_BOW = SKILL_BOWS
SKILL_ARCANEMAGIC = 9
SKILL_ENTROPICMAGIC = 10
SKILL_ENTROPY = SKILL_ENTROPICMAGIC
SKILL_AEROMAGIC = 11
SKILL_VOIDMAGIC = 12
SKILL_HEALING = 13
--[[SKILL_LUMBERJACKING = 14
SKILL_CHOPPING = SKILL_LUMBERJACKING
SKILL_MINING = 15
SKILL_ALCHEMY = 16
SKILL_POTIONS = SKILL_ALCHEMY
SKILL_SMITHING = 17
SKILL_BLACKSMITHING = SKILL_SMITHING]]

SKILLGROUP_ATTRIBUTES = 1
SKILLGROUP_MAJOR = 2
SKILLGROUP_MINOR = 3

SKILLGROUPS = {}
SKILLGROUPS[SKILLGROUP_ATTRIBUTES] = "Attributes"
SKILLGROUPS[SKILLGROUP_MAJOR] = "Major"
SKILLGROUPS[SKILLGROUP_MINOR] = "Minor"

SKILLGROUPMAX = {}
SKILLGROUPMAX[SKILLGROUP_ATTRIBUTES] = 300
SKILLGROUPMAX[SKILLGROUP_MAJOR] = 400
SKILLGROUPMAX[SKILLGROUP_MINOR] = 400

SKILLS = {}
SKILLS[SKILL_STRENGTH] = {Name = "Strength", Description = "Determines how much you can carry. Effects archery shooting power, weapon damage, and a small amount of your maximum health.", Default = 20, Group = SKILLGROUP_ATTRIBUTES}
SKILLS[SKILL_VITALITY] = {Name = "Vitality", Description = "Greatly effects maximum health.", Default = 10, Group = SKILLGROUP_ATTRIBUTES}
SKILLS[SKILL_DEXTERITY] = {Name = "Dexterity", Description = "Determines quickness and agility. Effects archery accuracy, movement speed, and jumping ability.", Default = 10, Group = SKILLGROUP_ATTRIBUTES}
SKILLS[SKILL_INTELLIGENCE] = {Name = "Intelligence", Description = "Determines maximum mana and has an effect on things like crafting.", Default = 10, Group = SKILLGROUP_ATTRIBUTES}

SKILLS[SKILL_BLADES] = {Name = "Blade Proficiency", Description = "Skill with bladed weapons such as swords, axes, and other cutting weapons.", Supplements = {[SKILL_STRENGTH] = 0.25, [SKILL_DEXTERITY] = 0.25}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_POLEARMS] = {Name = "Polearm Proficiency", Description = "Skill with polearms such as spears, halberds, and pikes.", Supplements = {[SKILL_STRENGTH] = 0.4, [SKILL_DEXTERITY] = 0.1}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_BLUDGEONING] = {Name = "Mace Proficiency", Description = "Skill with blunt weapons such as hammers and clubs.", Supplements = {[SKILL_STRENGTH] = 0.5}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_ARCHERY] = {Name = "Archery", Description = "Skill with bows and string-drawn weapons. Increases accuracy.", Supplements = {[SKILL_STRENGTH] = 0.3, [SKILL_DEXTERITY] = 0.5}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_HEALING] = {Name = "Healing", Description = "Skill with using bandages, potions and other surgical or magical things used to maintain life.", Supplements = {[SKILL_INTELLIGENCE] = 0.25, [SKILL_DEXTERITY] = 0.2}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_ARCANEMAGIC] = {Name = "Arcane Magic", Description = "Skill with Arcane magic, the magic of suggestive illusion.", Supplements = {[SKILL_INTELLIGENCE] = 0.25}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_ENTROPICMAGIC] = {Name = "Entropic Magic", Description = "Skill with Entropic magic, the magic of manipulating energy.", Supplements = {[SKILL_INTELLIGENCE] = 0.5}, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_AEROMAGIC] = {Name = "Aero Magic", Description = "Skill with Aero magic, the magic of manipulating the natural state, structure, or chemistry of the environment.", Supplements = {[SKILL_INTELLIGENCE] = 0.5}, Group = SKILLGROUP_MAJOR}
SKILLS[SKILL_VOIDMAGIC] = {Name = "Void Magic", Description = "Skill with Void magic, the magic of bending or altering the natural physical laws.", Supplements = {[SKILL_INTELLIGENCE] = 0.5}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MAJOR}

--[[SKILLS[SKILL_LUMBERJACKING] = {Name = "Lumberjacking", Description = "Skill with harvesting wood from trees. Grants a small damage bonus to axes.", Supplements = {[SKILL_STRENGTH] = 0.5}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MINOR}
SKILLS[SKILL_MINING] = {Name = "Mining", Description = "Skill with picks and harvesting ore, gems, minerals, and stone.", Supplements = {[SKILL_STRENGTH] = 0.5}, Default = SKILLS_DEFAULT, Group = SKILLGROUP_MINOR}
SKILLS[SKILL_ALCHEMY] = {Name = "Alchemy", Description = "Knowledge of creating potions from herbs and other ingredients.", Supplements = {[SKILL_INTELLIGENCE] = 0.5}, Default = SKILL_DEFAULT, Group = SKILLGROUP_MINOR}
SKILLS[SKILL_SMITHING] = {Name = "Smithing", Description = "Knowledge of forging weapons, armor and other metal-based constructs.", Supplements = {[SKILL_STRENGTH] = 0.3, [SKILL_DEXTERITY] = 0.3, [SKILL_INTELLIGENCE] = 0.1}, Default = SKILL_DEFAULT, Group = SKILLGROUP_MINOR}]]

SKILLS_NUMBEROFSKILLS = table.Count(SKILLS)

SOUNDSET_MELEE_SHARP_1 = 0
SOUNDSET_MELEE_SHARP_2 = 1
SOUNDSET_MELEE_SHARP_3 = 2
SOUNDSET_MELEE_SHARP_4 = 3
SOUNDSET_MELEE_SHARP_5 = 4

SOUNDSET_MELEE_BLUNT_1 = 5
SOUNDSET_MELEE_BLUNT_2 = 6
SOUNDSET_MELEE_BLUNT_3 = 7
SOUNDSET_MELEE_BLUNT_4 = 8
SOUNDSET_MELEE_BLUNT_5 = 9

SOUNDSET_MELEE_AXE_1 = 10
SOUNDSET_MELEE_AXE_2 = 11
SOUNDSET_MELEE_AXE_3 = 12
SOUNDSET_MELEE_AXE_4 = 13
SOUNDSET_MELEE_AXE_5 = 14

SOUNDSUBSET_MELEE_SWING = 0

SOUNDSUBSET_MELEE_HIT_FLESH = 1
SOUNDSUBSET_MELEE_HIT_STONE = 2
SOUNDSUBSET_MELEE_HIT_WOOD = 3
SOUNDSUBSET_MELEE_HIT_EARTH = 4
SOUNDSUBSET_MELEE_HIT_METAL = 5
SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL = 6
SOUNDSUBSET_MELEE_HIT_GLASS = 7

MAX_ENCHANTMENTS = 3

ITEMDESCRIPTIONS_FUNCTIONS = {
{"Mass", function(panel, itemdata)
	return "Mass: "..((itemdata.Mass or 0) * (itemdata.Amount or 1)).." kg"
end},
{"Crafter", function(panel, itemdata)
	if itemdata.Crafter then
		return EasyLabel(panel, "Crafted by "..tostring(itemdata.Maker))
	end
end},
{"Durability", function(panel, itemdata)
	if itemdata.Durability then
		if itemdata.Durability == -1 then
			return EasyLabel(panel, "Indestructable", nil, COLOR_WHITE)
		end

		return EasyLabel(panel, "Durability - "..itemdata.Durability.."/"..(itemdata.MaxDurability or 100), nil, COLOR_WHITE)
	end
end},
{"Bound", function(panel, itemdata)
	if itemdata.Bound then
		return EasyLabel(panel, "Bound - can't be removed from inventory", nil, COLOR_ORANGE)
	end
end},
{"Blessed", function(panel, itemdata)
	if itemdata.Blessed then
		return EasyLabel(panel, "Blessed - won't be lost on death", nil, COLOR_WHITE)
	end
end},
{"Cursed", function(panel, itemdata)
	if itemdata.Cursed then
		return EasyLabel(panel, "Cursed - will always be lost on death", nil, COLOR_PURPLE)
	end
end},
{"Magic Ammunition", function(panel, itemdata)
	if itemdata.MagicAmmunition then
		return EasyLabel(panel, "Magic Ammunition", nil, COLOR_WHITE)
	end
end},
{"SpellEnchantments", function(panel, itemdata)
	if itemdata.SpellEnchantments and #itemdata.SpellEnchantments > 0 then
		local enchantpanel = vgui.Create("DPanel", panel)

		local y = 0
		local maxw = 16
		for i, enchantment in pairs(itemdata.SpellEnchantments) do
			if enchantment.Spell and SPELLS[enchantment.Spell] then
				local target
				if enchantment.Target and SPELLENCHANT_TARGETS[enchantment.Target] then
					target = SPELLENCHANT_TARGETS[enchantment.Target].." "
				else
					target = ""
				end
				local lab
				if not enchantment.Chance or enchantment.Chance == 100 then
					lab = EasyLabel(enchantpanel, "Casts "..enchantment.Spell.." "..target..GetEffectFlagsAndSeparated(enchantment.Flags), nil, COLOR_LIGHTBLUE)
				else
					lab = EasyLabel(enchantpanel, enchantment.Chance.."% chance to cast "..enchantment.Spell.." "..target..GetEffectFlagsAndSeparated(enchantment.Flags), nil, COLOR_LIGHTBLUE)
				end
				lab:SetPos(0, y)
				y = y + lab:GetTall()
				maxw = math.max(maxw, lab:GetWide())
			end
		end

		enchantpanel:SetSize(maxw, y)
		return enchantpanel
	end
end}
}

for et, name in pairs(ENCHANT_TYPES) do
	table.insert(ITEMDESCRIPTIONS_FUNCTIONS, {name, function(panel, itemdata)
		if itemdata.Enchanted then
			local etab = itemdata.Enchanted[et]
			if etab then
				if etab[2] then
					return EasyLabel(panel, "Rank ".. (LETTER_RANKS[ etab[1] ] or "?") .." "..name.." Arcana enchantment by "..tostring(etab[2]), nil, COLOR_YELLOW)
				else
					return EasyLabel(panel, "Rank ".. (LETTER_RANKS[ etab[1] ] or "?") .." "..name.." Arcana enchantment", nil, COLOR_YELLOW)
				end
			end
		end
	end})
end

for dt, name in pairs(DAMAGETYPES) do
	table.insert(ITEMDESCRIPTIONS_FUNCTIONS, {name, function(panel, itemdata)
		if itemdata.DamageMultipliers then
			local multiplier = itemdata.DamageMultipliers[dt]
			if multiplier and multiplier ~= 0 then
				if multiplier > 1 then
					return EasyLabel(panel, name.." weakness - "..string.ToPercentageMultiplier(multiplier - 1), nil, COLOR_RED)
				else
					return EasyLabel(panel, name.." protection - "..string.ToPercentageMultiplier(multiplier), nil, COLOR_LIMEGREEN)
				end
			end
		end
	end})
end

ITEMDESCRIPTIONS_MEMBERS = {
{"Attack power", "BaseDamage"},
{"Swing duration", "SwingTime"}
}

ITEMDESCRIPTIONS_MULTIPLIER = {
{"Projectile damage", "ProjectileDamageMultiplier"},
{"Projectile radius", "ProjectileRadiusMultiplier"},
{"Projectile force", "ProjectileForceMultiplier"},
{"Projectile speed", "ProjectileSpeedMultiplier"},
{"Melee damage", "MeleeDamageMultiplier"},
{"Draw time", "DrawTimeMultiplier"},
{"Charge speed", "ChargeMultiplier"},
{"Casting recovery time", "CastRecoveryTimeMultiplier"},
{"Casting time", "CastTimeMultiplier"},
{"Damage taken", "DamageMultiplier"},
{"Instability", "ThrownForceMultiplier"},
{"Swing duration", "SwingTimeMultiplier"}
}

SOUND_MURDER = Sound("npc/manhack/grind_flesh1.wav")
SOUND_MURDERED = Sound("npc/antlion_guard/angry2.wav")
SOUND_KILL = Sound("npc/antlion_guard/shove1.wav")
SOUND_KILLED = Sound("ambient/levels/citadel/citadel_hit1_adpcm.wav") --Sound("npc/antlion_guard/shove1.wav")
SOUND_KILL_FRIENDLYGUILD = Sound("npc/antlion_guard/shove1.wav")
SOUND_KILLED_FRIENDLYGUILD = Sound("ambient/levels/citadel/citadel_hit1_adpcm.wav") --Sound("npc/antlion_guard/shove1.wav")
SOUND_KILL_MONSTER = Sound("npc/headcrab/headbite.wav")
SOUND_KILLED_MONSTER = Sound("ambient/levels/citadel/citadel_hit1_adpcm.wav") --Sound("npc/stalker/go_alert2.wav")

SPELLENCHANT_EFFECT_ONSWING = 1
SPELLENCHANT_EFFECT_ONSTRIKE = 2
SPELLENCHANT_EFFECT_ONGUARD = 4
SPELLENCHANT_EFFECT_ONARROWRELEASE = 8
SPELLENCHANT_EFFECT_ONARROWHIT = 16
SPELLENCHANT_EFFECT_ONSTRUCK = 32

SPELLENCHANT_TARGET_SELF = 1
SPELLENCHANT_TARGET_TARGET = 2
SPELLENCHANT_TARGET_ATTACKER = 3

SPELLENCHANT_TARGETS = {}
SPELLENCHANT_TARGETS[SPELLENCHANT_TARGET_SELF] = "on self"
SPELLENCHANT_TARGETS[SPELLENCHANT_TARGET_TARGET] = "on target"
SPELLENCHANT_TARGETS[SPELLENCHANT_TARGET_ATTACKER] = "on attacker"

SPELLENCHANT_EFFECTS = {}
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONSWING] = "when swinging"
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONSTRIKE] = "when striking"
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONGUARD] = "when parrying"
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONARROWRELEASE] = "when shooting an arrow"
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONARROWHIT] = "when an arrow hits"
SPELLENCHANT_EFFECTS[SPELLENCHANT_EFFECT_ONSTRUCK] = "when struck"

RADIUS_GENERICACTIONMESSAGE = 2048

function GenericWearableProcessDamage(self, dmginfo)
	local item = self:GetItem()
	if item then
		if item.DamageMultipliers then
			local dmgtype = dmginfo:GetDamageType()
			if item.DamageMultipliers[dmgtype] then
				dmginfo:SetDamage(dmginfo:GetDamage() * item.DamageMultipliers[dmgtype])
			end
		end
		if item.DamageMultiplier then
			dmginfo:SetDamage(dmginfo:GetDamage() * item.DamageMultiplier)
		end
	end
end

function GenericWearableAlterCastRecoveryTime(self, pl)
	local itemdata = self.ItemData
	if itemdata.CastRecoveryTimeMultiplier then
		stat.Mul(itemdata.CastRecoveryTimeMultiplier)
	end
end

function GenericWearableAlterCastTime(self, pl)
	local itemdata = self.ItemData
	if itemdata.CastTimeMultiplier then
		stat.Mul(itemdata.CastTimeMultiplier)
	end
end

function GenericWearableAlterThrownForce(self, pl)
	local itemdata = self.ItemData
	if itemdata.ThrownForceMultiplier then
		stat.Mul(itemdata.ThrownForceMultiplier)
	end
end
