AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:OnInitialize()
	self:SetModel(self.Model)
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.WeaponStatus = self
end

function ENT:Think()
end
