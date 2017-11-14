AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Base = "projectile_base"
ENT.Type = "anim"

ENT.Model = "models/Weapons/w_bullet.mdl"

ENT.CollisionRadius = 1

ENT.MagicShieldReflect = true
ENT.DamageType = DMGTYPE_VOID
ENT.ExplosionEffect = "hit_thorn"
ENT.ExplodesInWater = false

ENT.SpellData = SPELL_THORN

if SERVER then
	function ENT:ProjectileInitialize()
		self:EmitSound("nox/airburst.wav")
	end
end
