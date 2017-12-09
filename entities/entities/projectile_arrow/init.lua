AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:ProjectileInitialize()
	self:SetUseType(SIMPLE_USE)
	self:EmitSound("nox/arrow_flying0"..math.random(1, 2)..".wav")

	self.SpriteTrail = util.SpriteTrail(self, 0, Color(230, 230, 230, 255), false, 4, 0.5, 0.5, 0.1, "trails/laser.vmt")
end

function ENT:Use(activator, caller)
	if self.Stuck and not self.Removing and activator:IsPlayer() and activator:AddItem("arrow", 1, true) then
		self.DeathTime = 0
		self.Removing = true
	end
end

function ENT:OnHitWorld(vHitPos, vHitNormal, vOurOldVelocity)
	self:OnHit(GetWorldEntity(), self:GetProjectileDamage(), vHitPos, vHitNormal, vOurOldVelocity)
end

function ENT:OnHit(eHitEntity, fDamage, vHitPos, vHitNormal, vOurOldVelocity)
	util.Decal("Impact.Concrete", vHitPos + vHitNormal, vHitPos - vHitNormal)

	local nostick

	local owner = self:GetOwner()

	if eHitEntity and eHitEntity:IsValid() then
		if eHitEntity:IsCharacter() then
			nostick = true
			eHitEntity:EmitSound("rpgsounds/impact_flesh"..math.random(1, 2)..".wav")

			--[[if owner:IsValid() and owner:IsPlayer() and gamemode.Call("PlayerShouldSkillUp", owner, eHitEntity) then
				gamemode.Call("PlayerUseSkill", owner, SKILL_ARCHERY, eHitEntity:GetMaxHealth() * SKILLS_RMAX)
			end]]
		end

		eHitEntity:TakeSpecialDamage(self.ProjectileDamage * 0.1 + self.ProjectileDamage * math.min(2.9, vOurOldVelocity:Length() * 0.001), DMGTYPE_CUTTING, owner, self, vHitPos)

		local bow = self.Bow
		if bow and bow:IsValid() then
			bow:CastSpellEnchantments(SPELLENCHANT_EFFECT_ONARROWHIT,  eHitEntity)
		end
	end

	self:GetPhysicsObject():EnableCollisions(false)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	if not nostick then
		self.Stuck = true
		self.DeathTime = CurTime() + 15
		self:EmitSound("physics/metal/sawblade_stick"..math.random(1, 3)..".wav", 72, math.random(150, 190))
		self:GetPhysicsObject():EnableMotion(false)
		self:SetPos(vHitPos + vHitNormal * 0.5)
		self:SetAngles(vOurOldVelocity:Angle())
	end

	return true
end

resource.AddFile("models/mixerman3d/other/arrow.mdl")
resource.AddFile("materials/mixerman3d/other/metal_galv.vmt")
resource.AddFile("materials/mixerman3d/other/metal_galv.vtf")
resource.AddFile("materials/mixerman3d/other/metal_galv2.vmt")
resource.AddFile("materials/mixerman3d/other/metal_galv2.vtf")
resource.AddFile("materials/mixerman3d/other/skate_deck.vmt")
resource.AddFile("materials/mixerman3d/other/skate_deck.vtf")
resource.AddFile("materials/mixerman3d/other/skate_misc.vmt")
resource.AddFile("materials/mixerman3d/other/skate_misc.vtf")
