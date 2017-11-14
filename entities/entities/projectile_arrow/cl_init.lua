include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

local vec0 = Vector(0, 0, 0)
function ENT:Draw()
	local vel = self:GetVelocity()
	if vel == vec0 then
		self:DrawModel()
	else
		self:SetAngles(vel:Angle())
		self:DrawModel()
	end
end
