AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.LifeTime = 10

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			local tr = owner:ProjectileGuideTrace(self)
			local targetpos = not tr.HitWorld and tr.HitPos or tr.HitPos + tr.HitNormal * 16
			local aHeading = self:GetVelocity():Angle()
			self:SetAngles(aHeading)
			local fRotationRate = FrameTime() * 25
			local aDiff = self:WorldToLocalAngles((targetpos - self:GetPos()):Angle())
			aHeading:RotateAroundAxis(aHeading:Up(), math.Clamp(aDiff.yaw, -1, 1) * fRotationRate)
			aHeading:RotateAroundAxis(aHeading:Right(), math.Clamp(aDiff.pitch, -1, 1) * -fRotationRate)
			self:SetProjectileHeading(aHeading:Forward())
		end
	end

	self.BaseClass.Think(self)

	self:NextThink(CurTime())
	return true
end

function ENT:OnHit(eHitEntity, fDamage, vHitPos, vHitNormal, vOurOldVelocity)
	local owner = self:GetOwner()
	if owner:IsValid() and eHitEntity:IsValid() and eHitEntity:IsPlayer() then
		local status = owner:GiveStatus("threadoffate")
		if status:IsValid() then
			local spelltab = SPELLS.threadoffate
			if spelltab then
				owner:SetMana(math.min(owner:GetMana() + spelltab.Mana, owner:GetMaxMana()))
			end

			status:SetTarget(eHitEntity)
			status:SetEndTime(CurTime() + 5)
		end
	end

	return true
end
