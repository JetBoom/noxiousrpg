include("shared.lua")

function ENT:OnInitialize()
	self:SetRenderBoundsNumber(72)
	self.Seed = math.Rand(0, 10)
end

function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end
end
