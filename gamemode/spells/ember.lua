SPELL.Name = "Ember"
SPELL.Description = "A fairly weak fire attack spell."
SPELL.CastTime = 1
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 15
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 10}

SPELL.ProjectileDamage = 11
SPELL.ProjectileDamagePerSkill = 0.02
SPELL.ProjectileRadius = 32
SPELL.ProjectileRadiusPerSkill = 0.12
SPELL.ProjectileForce = 200
SPELL.ProjectileSpeed = 900

if SERVER then
	function SPELL:OnCast(pl)
		pl:EmitSound("ambient/fire/gascan_ignite1.wav")
	end

	function SPELL:OnCasted(pl, target)
		if target and not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local ent = ents.Create("projectile_ember")
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

PRECAST.Base = "status_precast_fire01"
