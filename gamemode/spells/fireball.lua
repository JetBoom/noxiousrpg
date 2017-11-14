SPELL.Name = "Fire Ball"
SPELL.Description = "Concentrates intense heat in to a small ball and launches it."
SPELL.CastTime = 1.5
--SPELL.ItemRequirements = {["ash"] = 1}
SPELL.ItemConsumation = SPELL.ItemRequirements
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_ENTROPICMAGIC] = 30}
SPELL.PrecastStatus = "precast_"..SPELLNAME

SPELL.ProjectileDamage = 20
SPELL.ProjectileDamagePerSkill = 0.04
SPELL.ProjectileRadius = 72
SPELL.ProjectileRadiusPerSkill = 0.24
SPELL.ProjectileForce = 250
SPELL.ProjectileForcePerSkill = 0
SPELL.ProjectileSpeed = 800

SPELL.ProjectileClass = "projectile_fireball"

if SERVER then
	function SPELL:OnCast(pl)
		pl:RemoveStatus(self.PrecastStatus, true, true)
		pl:EmitSound("ambient/fire/gascan_ignite1.wav")
	end

	function SPELL:OnCasted(pl, target)
		pl:LaunchSpellProjectile(self, target)
	end
end

RegisterPrecast("fire01")
