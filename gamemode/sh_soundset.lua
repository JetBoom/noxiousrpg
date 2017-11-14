do
	local meta = FindMetaTable("Entity")
	if meta then
		function meta:EmitSoundSet(set, subset, volume, pitch)
			soundset.Play(self, set, subset, volume, pitch)
		end
	end
end

local math = math
local table = table
local Sound = Sound

local matTypes = {
	[MAT_ANTLION] = SOUNDSUBSET_MELEE_HIT_FLESH,
	[MAT_BLOODYFLESH] = SOUNDSUBSET_MELEE_HIT_FLESH,
	[MAT_CONCRETE] = SOUNDSUBSET_MELEE_HIT_STONE,
	[MAT_DIRT] = SOUNDSUBSET_MELEE_HIT_EARTH,
	[MAT_FLESH] = SOUNDSUBSET_MELEE_HIT_FLESH,
	[MAT_GRATE] = SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL,
	[MAT_ALIENFLESH] = SOUNDSUBSET_MELEE_HIT_FLESH,
	[MAT_PLASTIC] = SOUNDSUBSET_MELEE_HIT_STONE,
	[MAT_METAL] = SOUNDSUBSET_MELEE_HIT_METAL,
	[MAT_SAND] = SOUNDSUBSET_MELEE_HIT_EARTH,
	[MAT_FOLIAGE] = SOUNDSUBSET_MELEE_HIT_EARTH,
	[MAT_COMPUTER] = SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL,
	[MAT_SLOSH] = SOUNDSUBSET_MELEE_HIT_EARTH,
	[MAT_TILE] = SOUNDSUBSET_MELEE_HIT_STONE,
	[MAT_VENT] = SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL,
	[MAT_WOOD] = SOUNDSUBSET_MELEE_HIT_WOOD,
	[MAT_GLASS] = SOUNDSUBSET_MELEE_HIT_GLASS
}

module("soundset")

local SoundSets = {}

function Add(set, subset, snd)
	SoundSets[set] = SoundSets[set] or {}
	SoundSets[set][subset] = SoundSets[set][subset] or {}

	table.insert(SoundSets[set][subset], Sound(snd))
end

function Get(set, subset)
	local tab = SoundSets[set]
	if tab then
		local subtab = SoundSets[set][subset]
		if subtab then
			return subtab[math.random(1, #subtab)]
		end
	end

	return ""
end

function Clear(set, subset)
	if subset then
		if SoundSets[set] then
			SoundSets[set][subset] = nil
		end
	else
		SoundSets[set] = nil
	end
end

function GetMaterialSubSet(mat)
	return matTypes[mat] or SOUNDSUBSET_MELEE_HIT_STONE
end

function Play(ent, set, subset, volume, pitch)
	ent:EmitSound(Get(set, subset), volume, pitch)
end
