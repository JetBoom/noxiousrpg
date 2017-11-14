AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.LifeTime = 30

function ENT:Initialize()
	self:DrawShadow(self.ShouldDrawShadow)
	if self.Model then
		self:SetModel(self.Model)
		if self.CollisionRadius then
			self:PhysicsInitSphere(self.CollisionRadius)
		else
			self:PhysicsInit(SOLID_VPHYSICS)
		end
	else
		self:PhysicsInitSphere(self.CollisionRadius)
	end
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(self.CollisionGroup)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(self.Drag)
		phys:EnableGravity(self.Gravity)
		phys:SetBuoyancyRatio(self.Buoyancy or 0.0001)
		if self.Mass then
			phys:SetMass(self.Mass)
		end
		phys:Wake()
	end

	self.DeathTime = CurTime() + self.LifeTime

	self:SetupDefaults()

	self:ProjectileInitialize()
end

function ENT:Launch(dir)
	self:SetProjectileHeading(dir)
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity, self.PhysicsData.OurOldVelocity)
	elseif self.ExplodesInWater and self:IsInWater() then
		self:Explode()
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:Explode(vHitPos, vHitNormal, eHitEntity, vOurOldVelocity)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)
	vOurOldVelocity = vOurOldVelocity or self:GetVelocity()
	eHitEntity = eHitEntity or NULL

	local fRadius = self:GetProjectileRadius()
	local fDamage = self:GetProjectileDamage()
	local fForce = self:GetProjectileForce()

	if fRadius > 0 then
		if not self.OnExploded or not self:OnExploded(vHitPos, vHitNormal, vHitEntity, vOurOldVelocity) then
			local tDamaged = ExplosiveDamage(owner, self, vHitPos, fRadius, fDamage, fForce, self.DistanceMultiplier, self.DamageMultiplier, self.MinimumDamage, self.DamageType)

			if owner:IsPlayer() then
				local SpellData = self.SpellData
				if SpellData then
					for ent, damage in pairs(tDamaged) do
						gamemode.Call("PlayerUsedOffensiveSpell", owner, SpellData, self, ent)
					end
				end
			end

			local Callback = self.OnExplosionDamagedEntity
			if Callback then
				for ent, damage in pairs(tDamaged) do
					Callback(self, ent, damage, vHitPos, vHitNormal, vOurOldVelocity)
				end
			end
		end
	elseif eHitEntity:IsValid() then
		if not self.OnHit or not self:OnHit(eHitEntity, fDamage, vHitPos, vHitNormal, vOurOldVelocity) then
			eHitEntity:TakeSpecialDamage(fDamage, self.ProjectileDamageType, owner, self)
		end
	elseif self.OnHitWorld then
		self:OnHitWorld(vHitPos, vHitNormal, vOurOldVelocity)
	end

	if self.ExplosionEffect and self:ShouldDispatchExplosionEffect(vHitPos, vHitNormal, eHitEntity, vOurOldVelocity) then
		local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetOrigin(vHitPos)
			effectdata:SetNormal(vHitNormal or Vector(0, 0, 1))
			effectdata:SetMagnitude(fDamage)
			effectdata:SetRadius(fRadius)
			effectdata:SetScale(fForce)
		util.Effect(self.ExplosionEffect, effectdata)
	end

	self:NextThink(CurTime())
end

function ENT:PhysicsCollide(data, phys)
	if gamemode.Call("ProjectileCollide", self, data) then return end

	self.PhysicsData = data

	self:NextThink(CurTime())
end
