AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Stunned = self
	pPlayer:EmitSound("nox/stunon.wav")
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		if not self.SilentRemove then
			parent:EmitSound("nox/stunoff.wav")
		end
		if parent.Stunned == self then
			parent.Stunned = nil
		end
	end
end

function ENT:OwnerHitByMelee(attacker, attackerwep, damage, damagetype, hitdata, ...)
	self:Remove()
end
