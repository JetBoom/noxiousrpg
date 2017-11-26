SPELL.Name = "Fire Ward"
SPELL.Description = "Magical orbs provide slight protection against fire damage."
SPELL.CastTime = 1.25
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 15
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 1}
SPELL.UsesTarget = true

SPELL.EffectDuration = 45
SPELL.EffectDurationPerSkillLevel = 15 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)
		pl:BeneficialAction(target)
		target:GiveStatus("fireward", self.EffectDuration + self.EffectDurationPerSkillLevel * skill):CapSkillLevel(skill)
		target:ThoughtAndFloatie("Fire defense up!", COLID_LIMEGREEN, pl)
	end
end

PRECAST.Base = "status_precast_fire01"

scripted_ents.Register({Base = "status__base_protectorbs", Type = "anim", DamageMultipliers = {[DMGTYPE_FIRE] = 0.75}, GlowColor1 = Color(255, 180, 0), GlowColor2 = Color(255, 255, 0)}, "status_fireward")
