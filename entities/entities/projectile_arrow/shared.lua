ENT.Base = "projectile_base"
ENT.Type = "anim"

ENT.Model = "models/mixerman3d/other/arrow.mdl"

ENT.CollisionRadius = 1

ENT.MagicShieldReflect = true
ENT.DamageType = DMGTYPE_CUTTING
ENT.ExplosionEffect = "hit_arrow"
ENT.ExplodesInWater = false

ENT.IsBowProjectile = true

ENT.ProjectileSpeed = 2000
ENT.ProjectileDamage = 10

ENT.Mass = false
ENT.Gravity = true
ENT.Buoyancy = 0.2

ENT.ShouldDrawShadow = true

function ENT:GetCharge()
	return self:GetDTFloat(2)
end

function ENT:SetCharge(charge)
	self:SetDTFloat(2, charge)
end

function ENT:SetProjectileSpeed(fAmount)
end

function ENT:GetProjectileSpeed()
	return (0.1 + self:GetCharge() * 0.9) * (0.5 + self:GetSkillLevel() * SKILLS_RMAX * 0.5) * self.ProjectileSpeed
end

util.PrecacheModel("models/mixerman3d/other/arrow.mdl")
util.PrecacheSound("physics/metal/sawblade_stick1.wav")
util.PrecacheSound("physics/metal/sawblade_stick2.wav")
util.PrecacheSound("physics/metal/sawblade_stick3.wav")
util.PrecacheSound("weapons/crossbow/hitbod1.wav")
util.PrecacheSound("weapons/crossbow/hitbod2.wav")
