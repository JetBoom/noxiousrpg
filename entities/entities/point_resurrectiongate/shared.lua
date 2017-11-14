ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.CollisionBoundsMin = Vector(-32, -32, 0)
ENT.CollisionBoundsMax = Vector(32, 32, 128)

function ENT:IsPersistent()
	return true
end

function ENT:SetChaos(onoff)
	self:SetDTBool(0, onoff)
end

function ENT:GetChaos()
	return self:GetDTBool(0)
end
ENT.IsChaos = ENT.GetChaos
