SPELL.Name = "Soften"
SPELL.Description = "Decreases overall defense against physical damage or nullifies Harden."
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
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)

		if IsValid(target:GetStatus("status_harden")) then
			target:RemoveStatus("status_harden")
			target:ThoughtAndFloatie("Harden nullified!", COLID_RED, pl)
		else
			target:GiveStatus("soften", self.Duration + self.DurationPerSkillLevel * pl:GetSkill(self.Skill))
			target:ThoughtAndFloatie("Physical defense down!", COLID_RED, pl)
		end
	end
end

RegisterPrecast("mystic01")
