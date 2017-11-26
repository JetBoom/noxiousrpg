SPELL.Name = "Protection"
SPELL.Description = "Reduces the damage of the next attack by 1/2."
SPELL.CastTime = 1
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 50}
SPELL.UsesTarget = true

SPELL.Duration = 10
SPELL.DurationPerSkillLevel = 2.5 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		pl:HelpfulAction(target)

		local skill = pl:GetSkill(self.Skill)
		target:GiveStatus("protection", self.Duration + self.DurationPerSkillLevel * skill):CapSkillLevel(skill)
		target:ThoughtAndFloatie("Protected!", COLID_LIMEGREEN, pl)
	end
end

PRECAST.Base = "status_precast_mystic01"
