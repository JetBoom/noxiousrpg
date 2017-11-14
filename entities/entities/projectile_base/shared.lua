ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.ShouldDrawShadow = false

ENT.CollisionRadius = 2
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.ExplodesInWater = true

ENT.Mass = 2
ENT.Gravity = false
ENT.Drag = false

ENT.DamageType = DMGTYPE_VOID

function ENT:ProjectileInitialize()
end

function ENT:ShouldDispatchExplosionEffect(vHitPos, vHitNormal, eHitEntity, vOurOldVelocity)
	return true
end

function ENT:SetProjectileDamage(fAmount)
	self:SetDTInt(3, fAmount)
end

function ENT:GetProjectileDamage()
	return self:GetDTInt(3)
end

function ENT:SetProjectileRadius(fAmount)
	self:SetDTFloat(0, fAmount)
end

function ENT:GetProjectileRadius()
	return self:GetDTFloat(0)
end

function ENT:SetProjectileForce(fAmount)
	self:SetDTFloat(1, fAmount)
end

function ENT:GetProjectileForce()
	return self:GetDTFloat(1)
end

function ENT:SetProjectileSpeed(fAmount)
	self:SetDTFloat(2, fAmount)
end

function ENT:GetProjectileSpeed()
	return self:GetDTFloat(2)
end

function ENT:SetProjectileHeading(vHeading)
	--self.ProjectileHeading = vHeading
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetVelocityInstantaneous(vHeading * self:GetProjectileSpeed())
	end
end

function ENT:GetProjectileHeading()
	return self:GetVelocity():Normalize()
end

function ENT:SetSkillLevel(fSkill)
	self:SetDTFloat(3, fSkill)
	self:SetupSkillLevel(fSkill)
end

function ENT:GetSkillLevel()
	return self:GetDTFloat(3)
end

function ENT:SetupDefaults()
	local data = self.SpellData or self
	if data.ProjectileSpeed then
		self:SetProjectileSpeed(data.ProjectileSpeed)
	end
	if data.ProjectileDamage then
		self:SetProjectileDamage(data.ProjectileDamage)
	end
	if data.ProjectileRadius then
		self:SetProjectileRadius(data.ProjectileRadius)
	end
	if data.ProjectileForce then
		self:SetProjectileForce(data.ProjectileForce)
	end
end

function ENT:SetupSkillLevel(fSkill)
	fSkill = fSkill or self:GetSkillLevel()

	local data = self.SpellData or self
	self:SetProjectileSpeed((data.ProjectileSpeed or 0) + (data.ProjectileSpeedPerSkill or 0) * fSkill)
	self:SetProjectileRadius((data.ProjectileRadius or 0) + (data.ProjectileRadiusPerSkill or 0) * fSkill)
	self:SetProjectileDamage((data.ProjectileDamage or 0) + (data.ProjectileDamagePerSkill or 0) * fSkill)
	self:SetProjectileForce((data.ProjectileForce or 0) + (data.ProjectileForcePerSkill or 0) * fSkill)
end
