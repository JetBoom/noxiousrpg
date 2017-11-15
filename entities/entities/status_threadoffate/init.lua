AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	--pPlayer:EmitSound("nox/stunon.wav")
end

function ENT:OnRemove()
	local target = self:GetTarget()
	if target:IsValid() then
		target:EmitSound("nox/tagoff.wav")
	end
end
