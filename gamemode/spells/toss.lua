SPELL.Name = "Toss"
SPELL.Description = "Modifies the velocity of an object to toss it from the caster."
SPELL.CastTime = 1.5
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 30}
SPELL.UsesTarget = true

SPELL.EffectForce = 700
SPELL.EffectForcePerSkill = 2

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local origin = pl:EyePos()
		local hitpos = target:NearestPoint(origin)

		local skill = pl:GetSkill(self.Skill)
		local force = self.EffectForce + self.EffectForcePerSkill * skill

		local effectdata = EffectData()
			effectdata:SetOrigin(hitpos)
			effectdata:SetStart(origin)
			effectdata:SetEntity(target)
			effectdata:SetScale(force)
			effectdata:SetMagnitude(skill)
			effectdata:SetNormal((hitpos - origin):GetNormalized())
		util.Effect("hit_toss", effectdata, true, true)

		pl:HarmfulAction(target)
		local plpos = pl:GetCastPos()
		local tpos = target:GetPos()
		plpos.z = tpos.z - math.min(tpos:Distance(pl:GetPos()) * 0.2, 32)
		target:ThrowFromPosition(plpos, force)
	end
end

PRECAST.Base = "status_precast_air01"
