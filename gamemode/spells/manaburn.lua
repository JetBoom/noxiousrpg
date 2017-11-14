SPELL.Name = "Mana Burn"
SPELL.Description = "Causes the target to use extra mana when using magic."
SPELL.CastTime = 2
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 25}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.Duration = 30
SPELL.DurationPerSkillLevel = 10 * SKILLS_RMAX

-- TODO
if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)
		target:GiveStatus("manaburn", self.Duration + self.DurationPerSkillLevel * pl:GetSkill(self.Skill))
		target:ThoughtAndFloatie("Mana burned!", COLID_RED, pl)
	end
end

RegisterPrecast("mystic01")
