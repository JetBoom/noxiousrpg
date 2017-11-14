SPELL.Name = "Haste"
SPELL.Description = "Increase the movement speed of a being for a short duration."
--SPELL.ItemRequirements = {["ash"] = 1}
--SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.CastTime = 2
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 40}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.Bonus = 30
SPELL.BonusPerSkill = 0.2

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		pl:BeneficialAction(target)
		target:GiveStatus("haste", 30):CapSkillLevel(pl:GetSkill(self.Skill))
		target:ThoughtAndFloatie("Movement speed up!", COLID_LIMEGREEN, pl)
	end
end

RegisterPrecast("air01")
