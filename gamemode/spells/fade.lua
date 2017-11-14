SPELL.Name = "Fade"
SPELL.Description = "Bends light in such a way that the caster becomes like a shadow. The caster becomes much harder to identify and may even become partially invisible in darker areas."
SPELL.CastTime = 3
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 40
SPELL.SkillRequirements = {[SKILL_ARCANEMAGIC] = 40}
SPELL.PrecastStatus = "precast_"..SPELLNAME

SPELL.Duration = 90
SPELL.DurationPerSkillLevel = SKILLS_RMAX * 30

if SERVER then
	function SPELL:OnCasted(pl)
		local skill = pl:GetSkill(self.Skill)
		pl:GiveStatus("fade", self.Duration + self.DurationPerSkillLevel * skill):CapSkillLevel(skill)
		pl:ThoughtAndFloatie("Faded", COLID_LIMEGREEN, pl)
	end
end

RegisterPrecast("mystic01")
