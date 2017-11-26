SPELL.Name = "Energy Ward"
SPELL.Description = "Magical orbs provide slight protection against electric damage."
SPELL.CastTime = 1
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 15
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 1}
SPELL.UsesTarget = true

SPELL.Duration = 45
SPELL.DurationPerSkillLevel = 15 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)
		pl:BeneficialAction(target)
		target:GiveStatus("energyward", self.Duration + self.DurationPerSkillLevel * skill):CapSkillLevel(skill)
		target:ThoughtAndFloatie("Energy defense up!", COLID_LIMEGREEN, pl)
	end
end

PRECAST.Base = "status_precast_air02"

scripted_ents.Register({Base = "status__base_protectorbs", Type = "anim", DamageMultipliers = {[DMGTYPE_ENERGY] = 0.75}, GlowColor1 = Color(255, 255, 255), GlowColor2 = Color(255, 255, 255)}, "status_energyward")
