SPELL.Name = "Sacrifice"
SPELL.Description = "Converts the caster's life force in to mana."
SPELL.CastTime = 0.75
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 0
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 10}
SPELL.UsesTarget = true

SPELL.HealthDrain = 15
SPELL.HealthDrainPerSkillLevel = 5 * SKILLS_RMAX
SPELL.ManaRatio = 1.25

if SERVER then
	function SPELL:OnCasted(pl, target)
		local curhealth = pl:Health()
		if curhealth <= 1 then return true end

		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)

		local todrain = math.min(curhealth - 1, math.ceil(self.HealthDrain + skill * self.HealthDrainPerSkillLevel))
		local togive = todrain * self.ManaRatio

		local effectdata = EffectData()
			effectdata:SetOrigin(target:LocalToWorld(target:OBBCenter()))
			effectdata:SetStart(pl:EyePos())
			effectdata:SetEntity(target)
			effectdata:SetScale(todrain)
			effectdata:SetRadius(togive)
			effectdata:SetMagnitude(skill)
		util.Effect("hit_sacrifice", effectdata, true, true)

		pl:HelpfulAction(target)

		pl:SetHealth(curhealth - todrain)
		target:SetMana(target:GetMana() + togive)
	end
end

PRECAST.Base = "status_precast_mystic01"
PRECAST.PrimaryColor = Color(220, 25, 255)
