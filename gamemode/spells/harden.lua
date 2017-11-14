SPELL.Name = "Harden"
SPELL.Description = "Increases overall defense against physical damage or nullifies Soften."
SPELL.CastTime = 2
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 30}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.Duration = 30
SPELL.DurationPerSkillLevel = 10 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		pl:BeneficialAction(target)

		if IsValid(target:GetStatus("status_soften")) then
			target:RemoveStatus("status_soften")
			target:ThoughtAndFloatie("Soften nullified!", COLID_LIMEGREEN, pl)
		else
			target:GiveStatus("harden", self.Duration + self.DurationPerSkillLevel * pl:GetSkill(self.Skill))
			target:ThoughtAndFloatie("Physical defense up!", COLID_LIMEGREEN, pl)
		end
	end
end

RegisterPrecast("mystic01")
