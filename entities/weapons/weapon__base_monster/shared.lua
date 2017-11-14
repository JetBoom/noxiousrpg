AddCSLuaFile("shared.lua")

STATE_MONSTER_NEUTRAL = 0
STATE_MONSTER_SWING = 1
STATE_MONSTER_SWINGING = STATE_MONSTER_SWING

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.IsMonsterWeapon = true

SWEP.NextIdleSound = 0


SWEP.DamageType = DMG_SLASH
SWEP.BaseDamage = 10

SWEP.MeleeRange = 48
SWEP.MeleeRadius = 16
SWEP.MeleeSwingTime = 0.5
SWEP.MeleeRecoveryDelay = 0.1

SWEP.SwingSound = Sound("NPC_Antlion.MeleeAttackSingle")
SWEP.MissSound = Sound("Zombie.AttackMiss")
SWEP.HitSound = Sound("Zombie.AttackHit")
SWEP.HitGuardSound = Sound("rpgsounds/skin.wav")
SWEP.IdleSoundDelay = 2

SWEP.HitResetOnKnockedDown = true
SWEP.HitResetOnHitByMelee = true

SWEP.SwingSpeedMultiplier = 0.5

function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

function SWEP:PrimaryAttack()
	if not self.Owner:IsIdle() or self.OnlyAttackOnGround and not self.Owner:OnGround() then return end

	self:StartSwing(STATE_MONSTER_SWING, self.MeleeSwingTime)
end

function SWEP:SecondaryAttack()
	self:Reload()
end

function SWEP:Reload()
	if self.NextIdleSound <= CurTime() then
		self.NextIdleSound = CurTime() + self.IdleSoundDelay
		self.Owner:PlayVoiceGroup(VOICEGROUP_IDLE)
	end
end

function SWEP:Think()
	if self:GetState() == STATE_MONSTER_SWING then
		if CurTime() >= self:GetStateEndTime() then
			self.Owner:MeleeAttack(self, self:GetState())

			self:SetStateEndTime(0)
			self:SetState(STATE_MONSTER_NEUTRAL)
		end

		self:NextThink(CurTime())
		return true
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return self:CanHolster()
end

function SWEP:CanHolster()
	return self.Owner:IsIdle()
end

function SWEP:SwingStarted(state)
	self.Owner:PlayVoiceGroup(VOICEGROUP_ATTACK)
end

function SWEP:StartSwing(state, enddelay)
	if not state then return end
	self:SetState(state)

	if state == STATE_MONSTER_SWING then
		self:CastSpellEnchantments(SPELLENCHANT_EFFECT_ONSWING)

		if not self:SwingStarted(state) then
			if self.SwingSound then
				self:EmitSound(self.SwingSound)
			end

			self:SendWeaponAnim(ACT_VM_MISSCENTER)

			self.Owner:DoAttackEvent()
		end
	end

	self:SetStateEndTime(CurTime() + (enddelay or 0))
	self:SetNextPrimaryAttack(self:GetStateEndTime() + self.MeleeRecoveryDelay)

	self:NextThink(CurTime())
end

function SWEP:GetBaseMeleeDamage(state)
	local damage = self.BaseDamage

	local item = self:GetItem()
	if item then
		damage = item.BaseDamage or damage

		if item.MeleeDamageMultiplier then
			damage = damage * item.MeleeDamageMultiplier
		end
	end

	return damage
end

function SWEP:GetBaseMeleeDamageType(state)
	return DMGTYPE_SLASHING
end

function SWEP:PlayerKnockedDown(status, exists, dietime)
	if self.HitResetOnKnockedDown then
		self:HitReset()
	end
end

function SWEP:OwnerHitByMelee(attacker, attackerwep, damage, damagetype, hitdata, ...)
	if self.HitResetOnHitByMelee then
		self:HitReset()
	end
end

function SWEP:HitReset()
	self:SetStateEndTime(0)
	self:SetState(STATE_MONSTER_NEUTRAL)
	self:SetNextPrimaryAttack(CurTime() + self.MeleeRecoveryDelay)
end

function SWEP:ResetJumpPower()
	if self.OnlyAttackOnGround and self:GetState() == STATE_MONSTER_SWING then
		stat.Set(0)
	end
end

function SWEP:Move(move)
	if self:GetState() == STATE_MONSTER_SWING then
		move:SetSideSpeed(move:GetSideSpeed() * self.SwingSpeedMultiplier)
		move:SetForwardSpeed(move:GetForwardSpeed() * self.SwingSpeedMultiplier)
	end
end

function SWEP:IsIdle()
	return self:GetState() == STATE_MONSTER_NEUTRAL and self:GetNextPrimaryAttack() <= CurTime()
end

function SWEP:MeleeHit(ent, damage, damagetype, hitdata, state)
	if ent:IsCharacter() then
		if self.HitSound then
			self:EmitSound(self.HitSound)
		end

		if SERVER then
			ent:BloodSpray(ent:NearestPoint(self.Owner:EyePos()), damage, self.Owner:GetForward(), damage * 10)
		end
	end

	ent:ThrowFromPosition(self.Owner:GetPos(), damage * 5)
end

function SWEP:OnHitWorld(damage, damagetype, hitdata, state)
	local snd = self.HitWorldSound or self.HitSound
	if snd then
		self:EmitSound(snd)
	end
end

function SWEP:OnHitGuard(ent, entwep, damage, damagetype, hitdata, state)
	if self.HitGuardSound then
		self:EmitSound(self.HitGuardSound)
	end
end

function SWEP:OnMeleeMiss(damage, damagetype, state)
	if self.MissSound then
		self:EmitSound(self.MissSound)
	end
end

function SWEP:SetState(state)
	self:SetDTInt(0, state)
	self.Owner:ResetJumpPower()
end

function SWEP:GetState()
	return self:GetDTInt(0)
end

function SWEP:SetStateEndTime(time)
	self:SetDTFloat(0, time)
end

function SWEP:GetStateEndTime()
	return self:GetDTFloat(0)
end

--[[function SWEP:GetDirection()
	return DIRECTION_DOWN
end]]
