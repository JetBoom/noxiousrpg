AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/zombie/classic.mdl")

	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_CUSTOM)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self:SetSequence("slump_b")
end

function ENT:OnSave(tab)
	tab.PlayerUID = self:GetPlayerUID()
end

function ENT:OnLoaded(tab)
	if tab.PlayerUID then
		self:SetPlayerUID(tab.PlayerUID)
	end
end
