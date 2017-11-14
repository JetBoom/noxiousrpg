AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Base = "projectile_base"
ENT.Type = "anim"

ENT.CollisionRadius = 4

ENT.MagicShieldReflect = true
ENT.DamageType = DMGTYPE_VOID
ENT.ExplosionEffect = "explosion_manablast"

ENT.SpellData = SPELL_MANABLAST
