-- TODO

SPELL.Name = "Ether Blast"
SPELL.Description = "Fires a blast of ether that generates an enourmous explosion of void energy."
SPELL.CastTime = 3
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 50
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 90}

SPELL.ProjectileDamage = 10
SPELL.ProjectileDamagePerSkill = 0.02
SPELL.ProjectileRadius = 32
SPELL.ProjectileRadiusPerSkill = 0.08
SPELL.ProjectileForce = 100
SPELL.ProjectileForcePerSkill = 0.25
SPELL.ProjectileSpeed = 900

if SERVER then
	function SPELL:OnCasted(pl, target)
		if target and not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local ent = ents.Create("projectile_etherblast")
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

PRECAST.Base = "status_precast_mystic01"
