if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 60

	function SWEP:DrawWorldModel() self:CheckAnimations() end
	SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Up() * 64, ang
	end
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetDeploySpeed(1.1)
	self:SetWeaponHoldType("normal")

	self:DrawShadow(false)
end

function SWEP:Deploy()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if self:GetActive() and CurTime() >= self:GetLastSwing() + 4 then
		self:SetActive(false)
	end

	self:CheckAnimations()
end

function SWEP:CheckAnimations()
	if self.m_AnimActive ~= self:GetActive() then
		self.m_AnimActive = self:GetActive()
		self:SetWeaponHoldType(self.m_AnimActive and "fist" or "normal")
	end
end

function SWEP:SecondaryAttack()
	--[[if self:CanPrimaryAttack() then
		if self:GetActive() then
			self:SetActive(false)
		else
			self:SetLastSwing(CurTime() + 9999)
			self:SetActive(true)
		end
	end]]
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryFire() <= CurTime() and self.Owner:IsIdle() and not self.Owner:IsGhost()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	if not self:GetActive() then self:SetActive(true) end

	self:SetLastSwing(CurTime())

	local owner = self.Owner

	owner:DoAttackEvent()

	self:EmitSound("npc/vort/claw_swing1.wav")

	owner:LagCompensation(true)

	local tr = owner:TraceHull(48, MASK_SHOT_HULL, 1.5)
	if tr.Hit then
		self:SetNextPrimaryFire(CurTime() + 0.75 - owner:GetSkill(SKILL_DEXTERITY) * SKILLS_RMAX * 0.25)

		local damage = 2 + owner:GetSkill(SKILL_STRENGTH) * 0.02
		local hitent = tr.Entity
		local hitflesh = tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH

		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self.IdleAnimation = CurTime() + self:SequenceDuration()

		if hitflesh then
			self:EmitSound("weapons/crossbow/hitbod"..math.random(1, 2)..".wav")
			self:EmitSound("npc/vort/foot_hit.wav")
			if hitent and hitent:IsValid() and hitent:IsCharacter() then
				hitent:BloodSpray(hitent:NearestPoint(owner:NewEyePos()), damage, owner:GetForward(), damage * 10)
			end
		else
			self:EmitSound("npc/vort/foot_hit.wav")
		end

		util.Decal("Impact.Concrete", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

		if SERVER and hitent:IsValid() then
			if hitent:IsPlayer() and not hitent:IsMonster() and damage >= hitent:Health() then
				if not hitent.FistStunImmunity or CurTime() > hitent.FistStunImmunity then
					hitent:Stun(5)
					hitent:KnockDown(5)
					hitent.FistStunImmunity = CurTime() + 7.5
				end
			else
				hitent:TakeNonLethalDamage(damage, DMGTYPE_IMPACT, owner, self) --self:GenericMeleeHit(hitent, damage, DMGTYPE_IMPACT, tr)
			end
		end
	else
		self:SetNextPrimaryFire(CurTime() + 1.25 - owner:GetSkill(SKILL_DEXTERITY) * SKILLS_RMAX * 0.5)

		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end

	owner:LagCompensation(false)
end

function SWEP:Move(move)
	if self:GetActive() then
		move:SetForwardSpeed(move:GetForwardSpeed() * 0.75)
		move:SetSideSpeed(move:GetSideSpeed() * 0.75)
	end
end

function SWEP:SetLastSwing(time)
	self:SetDTFloat(0, time)
end

function SWEP:GetLastSwing()
	return self:GetDTFloat(0)
end

function SWEP:SetActive(active)
	self:SetDTBool(0, active)
end

function SWEP:GetActive()
	return self:GetDTBool(0)
end
