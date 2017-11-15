CLASS.Name = "charger bug"
CLASS.Description = "Charger bugs are extremely territorial hive creatures. The drones will fight for their hive, territory, or food even if it means certain death."
CLASS.Index = 1

CLASS.Group = MONSTERGROUP_CHARGERBUG

CLASS.Rank = 1

CLASS.Model = "models/antlion.mdl"

CLASS.Health = 40
--[[CLASS.Stamina = 75
CLASS.StaminaRegenerate = 10]]
CLASS.Mana = 10
CLASS.ManaRegenerate = 1

CLASS.Speed = 225
CLASS.JumpPower = 200

CLASS.SWEP = "weapon_chargerbug"

CLASS.Scale = 0.5
CLASS.RScale = 1 / CLASS.Scale
CLASS.ModelScale = CLASS.Scale

CLASS.NoFallDamage = true

CLASS.HullMin = Vector(-14, -14, 0)
CLASS.HullMax = Vector(14, 14, 26)
CLASS.HullDuckMin = CLASS.HullMin
CLASS.HullDuckMax = CLASS.HullMax
CLASS.ViewOffset = Vector(0, 0, 12)
CLASS.ViewOffsetDucked = CLASS.ViewOffset
CLASS.StepSize = 12
CLASS.CrouchedWalkSpeed = 1
CLASS.Mass = 30

CLASS.AttackSound = Sound("NPC_Antlion.MeleeAttackSingle")
CLASS.PainSound = Sound("NPC_Antlion.Pain")
CLASS.DeathSound = Sound("NPC_Antlion.Pain")
CLASS.IdleSound = Sound("NPC_Antlion.Idle")
CLASS.TalkSound = Sound("NPC_Antlion.Idle")

if CLIENT then
	function CLASS:Think(pl)
		pl:SetModelScale(self.ModelScale, 0)
	end
end

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

--[[function CLASS:KnockDownWallSlam(pl, status, tr)
	return true
end]]

function CLASS:KnockDownShouldDraw(pl, status)
	return true
end

function CLASS:Move(pl, mv)
	if pl:Crouching() and pl:OnGround() then
		mv:SetSideSpeed(mv:GetSideSpeed() * 0.6)
		mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.6)
	end
end

function CLASS:HandleCreateRagdoll(pl, attacker, dmginfo)
	pl:Gib()
	return true
end

function CLASS:Gib(pl, dmginfo)
	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking, amount)
	return amount * self.Scale
end

function CLASS:PlayerSpawn(pl)
	if SERVER then
		pl:Give(self.SWEP)
		pl:SelectWeapon(self.SWEP)
	end

	pl:SetModel(self.Model)
end

function CLASS:OnPlayerHitGround(pl, inwater, hitfloater, fallspeed)
	return true
end

function CLASS:AlterFallDamage(pl, damage, fallspeed)
	return 0
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
	if not (pl:Crouching() and pl:OnGround()) then
		pl:EmitSound("NPC_Antlion.Footstep")
	end

	return true
end

function CLASS:KnockedDown(pl, status, exists)
	pl.m_bFirstFlippedFrame = true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl.KnockedDown then
		pl.CalcSeqOverride = 9 -- Flipped over.

		if pl.m_bFirstFlippedFrame then
			pl.m_bFirstFlippedFrame = false
			pl:AnimRestartMainSequence()
		end
	elseif pl:OnGround() then
		if velocity:Length2D() <= 0.5 then
			pl.CalcSeqOverride = 3 -- Idle, has multiple ACTs
		elseif pl:Crouching() then
			pl.CalcIdeal = ACT_WALK
		else
			pl.CalcIdeal = ACT_RUN
		end
	elseif pl:IsSwimming() then
		pl.CalcSeqOverride = 31 -- Drown
	else
		pl.CalcIdeal = ACT_RUN_AGITATED
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
