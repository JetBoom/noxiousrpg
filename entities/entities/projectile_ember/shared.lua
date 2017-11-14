AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Base = "projectile_base"
ENT.Type = "anim"

ENT.CollisionRadius = 2
ENT.MagicShieldReflect = true
ENT.DamageType = DMGTYPE_FIRE
ENT.ExplosionEffect = "explosion_ember"

ENT.SpellData = SPELL_EMBER
