AddCSLuaFile("shared.lua")

SWEP.Base = "weapon__base_monster"

SWEP.DamageType = DMG_SLASH
SWEP.BaseDamage = 9

SWEP.MeleeRange = 42
SWEP.MeleeRadius = 12
SWEP.MeleeSwingTime = 0.5
SWEP.MeleeRecoveryDelay = 0.2

SWEP.SwingSpeedMultiplier = 0.4

SWEP.SwingSound = Sound("NPC_Antlion.MeleeAttackSingle")
SWEP.MissSound = Sound("Zombie.AttackMiss")
SWEP.HitSound = Sound("NPC_Antlion.MeleeAttack")
SWEP.HitGuardSound = Sound("rpgsounds/skin.wav")
SWEP.IdleSoundDelay = 2.5
