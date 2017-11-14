include("shared.lua")

-- TODO

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	GenericSprite(owner:LocalToWorld(owner:OBBCenter()))
end

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBoundsNumber(72)
end
