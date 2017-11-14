SPELL.Name = "Cold Ward"
SPELL.Description = "Magical orbs provide slight protection against cold damage."
SPELL.CastTime = 1.25
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 15
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 1}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.Duration = 45
SPELL.DurationPerSkillLevel = 15 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)
		pl:BeneficialAction(target)
		target:GiveStatus("coldward", self.Duration + self.DurationPerSkillLevel * skill):CapSkillLevel(skill)
		target:ThoughtAndFloatie("Cold defense up!", COLID_LIMEGREEN, pl)
	end
end

RegisterPrecast("air01")

if SERVER then
	scripted_ents.Register({Base = "status__base_protectorbs", Type = "anim", DamageMultipliers = {[DMGTYPE_COLD] = 0.75}}, "status_coldward")
end

if CLIENT then
	scripted_ents.Register({Base = "status__base_protectorbs", Type = "anim", DamageMultipliers = {[DMGTYPE_COLD] = 0.75}, GlowColor1 = Color(0, 220, 255), GlowColor2 = Color(255, 255, 255)}, "status_coldward")
end
