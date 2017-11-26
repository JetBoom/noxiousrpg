SPELL.Name = "Mana Shield"
SPELL.Description = "A mystic shield converts health damage to mana damage. The caster's natural mana regeneration is severely reduced or negated."
SPELL.CastTime = 1
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 10
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 40}

SPELL.Duration = 50
SPELL.DurationPerSkillLevel = SKILLS_RMAX * 10

if SERVER then
	function SPELL:OnCasted(pl)
		local skill = pl:GetSkill(self.Skill)
		pl:GiveStatus("manashield", self.Duration + self.DurationPerSkillLevel * skill):CapSkillLevel(skill)
		pl:ThoughtAndFloatie("Mana Shielded!", COLID_RED, pl)
	end
end

PRECAST.Base = "status_precast_mystic01"
