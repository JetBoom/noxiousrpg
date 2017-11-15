AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Think()
	local owner = self:GetParent()
	if not owner:IsValid() or not owner:IsCriminal() then
		self:Remove()
		return
	end

	local ct = CurTime()

	if ct >= self:GetStartTime() and ct >= self:GetNextDamageTime() then
		self:SetNextDamageTime(ct + 2)
		UTIL_LightningStrike(owner, nil, nil, COLOR_RED)
		owner:TakeNonLethalDamage(15, DMG_GENERIC, self, self)
	end

	self:NextThink(ct)
	return true
end

function ENT:PlayerSet(pPlayer, bExists)
	if not bExists then
		pPlayer:EmitSound("beams/beamstart5.wav")
	end
end

function ENT:OnRemove()
end
