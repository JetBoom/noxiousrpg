SPELL.Name = "Lightning Strike"
SPELL.Description = "Calls a bolt of lightning, dealing moderate electricity damage to a target."
SPELL.CastTime = 2
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 40}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.EffectDamage = 16
SPELL.EffectDamagePerSkillLevel = 4 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)
		local damage = self.EffectDamage + self.EffectDamagePerSkillLevel * skill

		--[[local effectdata = EffectData()
			effectdata:SetOrigin(target:LocalToWorld(target:OBBCenter()))
			effectdata:SetStart(pl:EyePos())
			effectdata:SetEntity(target)
			effectdata:SetScale(damage)
			effectdata:SetMagnitude(skill)
		util.Effect("hit_lightningstrike", effectdata, true, true)]]

		UTIL_LightningStrike(target, 0.6 + skill * SKILLS_RMAX * 0.4)

		target:TakeSpecialDamage(damage, DMGTYPE_ENERGY, pl, pl)
	end
end

RegisterPrecast("air02")
