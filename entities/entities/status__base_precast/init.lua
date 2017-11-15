AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.CastTime = 1
ENT.PrecastKey = IN_ATTACK

function ENT:Initialize()
	self:DrawShadow(false)

	self:PrecastInitialize()
end

function ENT:OwnerHitByMelee(attacker, attackerwep, damage, damagetype, hitdata, ...)
	self:Remove() -- TODO: Check if the spell can be interuppted. Call OnInterrupt function from the spell table if there is one.
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Precast = self

	stat.Start(self.SpellData.CastTime)
		pPlayer:StatusWeaponHook0("AlterCastTime")
	self.FinishCastTime = CurTime() + stat.End()

	pPlayer:ResetJumpPower()

	self:PrecastPlayerSet(pPlayer, bExists)
end

function ENT:PrecastPlayerSet(pPlayer, bExists)
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner.Precast == self then
		owner.Precast = nil
	end

	if owner:IsValid() then
		owner:ResetJumpPower()
	end

	self:PrecastOnRemove()
end

function ENT:Think()
	if self.Finished then return end

	local owner = self:GetOwner()
	if owner:IsValid() and not owner:KeyPressed(IN_ATTACK2) then
		if self.FinishCastTime <= CurTime() and not owner:KeyDown(self.PrecastKey) then
			self.Finished = true
			CastSpell(owner, self.SpellData)
		end
	else
		self:Remove()
		return
	end

	self:PrecastThink()

	self:NextThink(CurTime())
	return true
end

function ENT:PrecastThink()
end
