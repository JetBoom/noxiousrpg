include("shared.lua")

ENT.RenderBoundsNumber = 128

function ENT:ProjectileInitialize()
	self.Created = CurTime()
end

local vec0 = Vector(0,0,0)
local matBlur = Material("trails/tube")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local vel = self:GetVelocity()
	if vec0 ~= vel then
		self:SetAngles(vel:Angle())
	end

	local pos = self:GetPos()
	local siz = (8 + self:GetSkillLevel()) * math.Rand(0.06, 0.1)

	self:SetMaterial("models/shiny")
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, siz, siz, color_white)
	render.SetMaterial(matBlur)
	render.DrawBeam(pos, pos + math.min(0.25, CurTime() - self.Created) * -192 * vel:Normalize(), 1, 1, 0)

	self:DrawModel()
end
