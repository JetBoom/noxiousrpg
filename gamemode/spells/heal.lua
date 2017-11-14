SPELL.Name = "Heal"
SPELL.Description = "Heals for a small amount."
SPELL.CastTime = 1.25
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 10
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 15}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.Health = 8
SPELL.HealthPerSkillLevel = 2 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		target = target or pl
		if not gamemode.Call("PlayerCanHelp", pl, target) then return true end

		local skill = pl:GetSkill(self.Skill)
		local health = self.Health + self.HealthPerSkillLevel * skill

		local effectdata = EffectData()
			effectdata:SetOrigin(target:LocalToWorld(target:OBBCenter()))
			effectdata:SetStart(pl:EyePos())
			effectdata:SetEntity(target)
			effectdata:SetScale(health)
			effectdata:SetMagnitude(skill)
		util.Effect("hit_heal", effectdata, true, true)

		gamemode.Call("PlayerHeal", target, pl, health)
	end
end

RegisterPrecast("mystic01", {["PrimaryColor"] = Color(50, 255, 50)})
