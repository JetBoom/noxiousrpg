SPELLS = {}

local function RegisterPrecast()
	PRECAST.SpellData = SPELL

	PRECAST.Type = PRECAST.Type or "anim"
	PRECAST.Base = PRECAST.Base or "status__base_precast"

	scripted_ents.Register(PRECAST, "status_precast_"..SPELLNAME)
end

function RegisterSpell(dataname, spelldata, basedata)
	if basedata then
		spelldata = spelldata or {}
		table.Inherit(spelldata, basedata)
	end
	SPELLS[dataname] = spelldata
	if spelldata.Name then
		SPELLS[spelldata.Name] = spelldata
	end
	_G["SPELL_"..string.upper(dataname)] = spelldata
end

function BaseSpellOnPrecast(self, pl)
	local status = pl:GiveStatus(self.PrecastStatus)
	if status:IsValid() then
		status:SetSkillLevel(pl:GetSkill(self.Skill))
		status:SetCastTime(CurTime())
		if self.CastTime and self.CastTime > 0 then
			status:SetCastFinishTime(CurTime() + self.CastTime)
		end
	end
end

function BaseSpellOnCast(self, pl)
	pl:RemoveStatus(self.PrecastStatus, true, true)
end

function BaseSpellOnFail(self, pl)
	pl:RemoveStatus(self.PrecastStatus, true, true)
end
BaseSpellOnInterrupt = BaseSpellOnFail

for _, filename in pairs(file.Find("noxiousrpg/gamemode/spells/*.lua", "LUA")) do
	SPELL = {}
	PRECAST = {}

	local spellname = string.sub(filename, 1, -5)
	SPELLNAME = spellname

	include("spells/"..filename)
	AddCSLuaFile("spells/"..filename)

	SPELL.DataName = spellname
	SPELL.Name = SPELL.Name or (string.upper(string.sub(spellname, 1, 1))..string.sub(spellname, 2))
	SPELL.Mana = SPELL.Mana or 0
	SPELL.CastTime = SPELL.CastTime or 0
	if SPELL.OnPrecast == nil then
		SPELL.OnPrecast = BaseSpellOnPrecast
	end
	if SPELL.OnCast == nil then
		SPELL.OnCast = BaseSpellOnCast
	end
	if SPELL.OnFail == nil then
		SPELL.OnFail = BaseSpellOnFail
	end
	if SPELL.OnInterrupt == nil then
		SPELL.OnInterrupt = BaseSpellOnInterrupt
	end
	if SPELL.PrecastStatus == nil then
		SPELL.PrecastStatus = "precast_"..SPELLNAME
	end
	SPELL.Skill = SPELL.Skill or SPELL.SkillRequirements and SPELL.SkillRequirements[1] or 0

	RegisterSpell(spellname, SPELL)
	RegisterPrecast()

	SPELLNAME = nil
	SPELL = nil
	PRECAST = nil
end

print(table.Count(SPELLS).." spells from files have been registered.")
