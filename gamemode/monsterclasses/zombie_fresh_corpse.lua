CLASS.Name = "fresh corpse"
CLASS.Description = "The result of dark magic or other unholy doings. This abomination knows no fear, no pain, and will relentlessly attack any living beings."
CLASS.Index = 2

CLASS.Group = MONSTERGROUP_EVIL_UNDEAD

CLASS.Rank = 20

CLASS.Model = "models/zombie/classic.mdl"

CLASS.Health = 75
--[[CLASS.Stamina = 100
CLASS.StaminaRegenerate = 20]]
CLASS.Mana = 10
CLASS.ManaRegenerate = 0.1

CLASS.Speed = 180
CLASS.JumpPower = 200

CLASS.SWEP = "weapon_fresh_corpse"

CLASS.PainSound = Sound("Zombie.Pain")
CLASS.DeathSound = Sound("Zombie.Pain")
CLASS.IdleSound = Sound("Zombie.Idle")
CLASS.AttackSound = Sound("Zombie.Attack")
CLASS.TalkSound = Sound("Zombie.Idle")

function CLASS:GetSpeed(pl, skill)
	return self.Speed
end

function CLASS:GetJumpPower(pl, skill)
	return self.JumpPower
end

function CLASS:KnockDown(pl, status)
	return true
end

function CLASS:EndKnockDown(pl, status)
	return true
end

function CLASS:KnockDownShouldDraw(pl, status)
	return true
end

function CLASS:PlayerSpawn(pl)
	if SERVER then
		pl:Give(self.SWEP)
		pl:SelectWeapon(self.SWEP)
	end

	pl:SetModel(self.Model)
end

function CLASS:AlterFallDamage(pl, damage, fallspeed)
	return damage * 0.5
end

function CLASS:PlayPainSound(pl, damage, frac)
	pl:EmitSound(self.PainSound)
	pl.NextPainSound = CurTime() + SoundDuration(self.PainSound) - 0.1

	return true
end

function CLASS:PlayVoiceGroup(pl, group)
	if group == VOICEGROUP_IDLE then
		pl:EmitSound(self.IdleSound)
	elseif group == VOICEGROUP_ATTACK then
		pl:EmitSound(self.AttackSound)
	elseif group == VOICEGROUP_TALK then
		pl:EmitSound(self.TalkSound)
	end

	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound(self.DeathSound)

	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume)
	if iFoot == 0 then
		if 0.85 < math.sin(RealTime() * 2) then
			pl:EmitSound("Zombie.ScuffLeft")
		else
			pl:EmitSound("Zombie.FootstepLeft")
		end
	else
		if math.sin(RealTime() * 2) < -0.85 then
			pl:EmitSound("Zombie.ScuffRight")
		else
			pl:EmitSound("Zombie.FootstepRight")
		end
	end

	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2D() <= 0.5 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.IsMoaning and wep:IsMoaning() then
			pl.CalcIdeal = ACT_IDLE_ON_FIRE
		else
			pl.CalcIdeal = ACT_IDLE
		end
	else
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.IsMoaning and wep:IsMoaning() then
			pl.CalcIdeal = ACT_WALK_ON_FIRE
		else
			pl.CalcSeqOverride = math.ceil((CurTime() + pl:EntIndex()) * 0.25 % 3) -- This is because it keeps using different sequences if you use ACT_WALK.
		end
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1)
		return ACT_INVALID
	end
end
