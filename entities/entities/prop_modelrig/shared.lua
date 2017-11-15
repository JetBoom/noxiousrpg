AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Type = "anim"

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
end
