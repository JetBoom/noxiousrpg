ENT.Type = "anim"

ENT.MaxMineHealth = 200

ENT.NumBits = 4

function ENT:IsPersistent()
	return true
end

function ENT:SetMineHealth(health)
	self:SetDTFloat(0, health)
end

function ENT:GetMineHealth()
	return self:GetDTFloat(0)
end
