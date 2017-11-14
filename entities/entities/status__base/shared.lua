ENT.Type = "anim"
ENT.m_IsStatus = true

function ENT:GetPlayer()
	return self:GetOwner()
end
