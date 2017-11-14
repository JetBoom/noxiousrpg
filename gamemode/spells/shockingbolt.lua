SPELL.Name = "Shocking Bolt"
SPELL.Description = "Ionize and discharge a bolt of electricity."
SPELL.CastTime = 1.5
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 30}
SPELL.PrecastStatus = "precast_"..SPELLNAME

SPELL.ProjectileDamage = 20
SPELL.ProjectileDamagePerSkill = 0.05
SPELL.ProjectileRadius = 48
SPELL.ProjectileRadiusPerSkill = 0.16
SPELL.ProjectileForce = 100
SPELL.ProjectileForcePerSkill = 0
SPELL.ProjectileSpeed = 1000

if SERVER then
	function SPELL:OnCasted(pl, target)
		if target and not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local ent = ents.Create("projectile_shockingbolt")
		if ent:IsValid() then
			ent:SetPos(pl:EyePos())
			ent:SetAngles(pl:EyeAngles())
			ent:SetOwner(pl)
			ent:Spawn()
			ent:SetSkillLevel(pl:GetSkill(self.Skill))
			pl:GlobalHook("PlayerCreatedSpellProjectile", ent, self)

			if target then
				ent:Launch(ent:GetHeadingTo(target))
			else
				ent:Launch(pl:GetAimVector())
			end
			pl:GlobalHook("PlayerLaunchedSpellProjectile", ent, self)
		end
	end
end

RegisterPrecast("air02")
