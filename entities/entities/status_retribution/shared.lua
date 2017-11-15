ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetStartTime(time)
	self:SetDTFloat(0, time)
end

function ENT:GetStartTime()
	return self:GetDTFloat(0)
end

function ENT:SetNextDamageTime(time)
	self:SetDTFloat(1, time)
end

function ENT:GetNextDamageTime()
	return self:GetDTFloat(1)
end