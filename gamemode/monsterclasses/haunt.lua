CLASS.Name = "haunt"
CLASS.Description = "Haunts are the result of vengeful spirits unable to leave their body. The haunt is rarely seen outside of catacombs and other dark places."
CLASS.Index = 3

CLASS.Group = MONSTERGROUP_EVIL_UNDEAD

CLASS.Rank = 25

CLASS.Model = "models/player/classic.mdl"

CLASS.Health = 100
--[[CLASS.Stamina = 100
CLASS.StaminaRegenerate = 20]]
CLASS.Mana = 20
CLASS.ManaRegenerate = 1

CLASS.Speed = 220
CLASS.JumpPower = 200

CLASS.SWEP = "weapon_sword_haunt"

CLASS.PainSound = Sound("Zombie.Pain")
CLASS.DeathSound = Sound("Zombie.Pain")
CLASS.IdleSound = Sound("Zombie.Idle")
CLASS.AttackSound = Sound("Zombie.Attack")
CLASS.TalkSound = Sound("Zombie.Idle")
--CLASS.ChainSound = Sound("")

CLASS.Skills = {
[SKILL_BLADES] = 75,
[SKILL_STRENGTH] = 75,
[SKILL_DEXTERITY] = 75
}

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
		pl:EmitSound("Zombie.FootstepLeft")
	else
		pl:EmitSound("Zombie.FootstepRight")
	end

	--[[if CurTime() >= (pl.m_NextHauntChainSound or 0) then
		pl.m_NextHauntChainSound = CurTime() + math.Rand(2, 5)

		if math.random(0, 2) == 0 then
			pl:EmitSound(self.ChainSound)
		end
	end]]

	return true
end
