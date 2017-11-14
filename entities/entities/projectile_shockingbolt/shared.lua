AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Base = "projectile_base"
ENT.Type = "anim"

ENT.CollisionRadius = 2

ENT.MagicShieldReflect = true
ENT.DamageType = DMGTYPE_ENERGY
ENT.ExplosionEffect = "explosion_shockingbolt"

ENT.SpellData = SPELL_SHOCKINGBOLT
