AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:OnInitialize()
	if self.Model then
		self:SetModel(self.Model)
	else
		self:SetNoDraw(true)
	end
end

function ENT:PlayerSet(pPlayer, bExists)
end

function ENT:Think()
end
