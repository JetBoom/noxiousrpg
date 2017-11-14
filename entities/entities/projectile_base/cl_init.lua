include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(self.ShouldDrawShadow)
	self:SetCollisionGroup(self.CollisionGroup)
	if self.RenderBoundsNumber then
		self:SetRenderBoundsNumber(self.RenderBoundsNumber)
	end

	self:ProjectileInitialize()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), 32, 32, COLOR_WHITE)
end
