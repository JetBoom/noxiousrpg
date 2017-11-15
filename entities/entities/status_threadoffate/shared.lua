ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetTarget(ent)
	self:SetDTEntity(0, ent)
	ent:EmitSound("nox/tagon.wav")
end

function ENT:GetTarget()
	return self:GetDTEntity(0)
end

function ENT:SetEndTime(time)
	self:SetDTFloat(1, time)
	self.DieTime = time
end

function ENT:GetEndTime()
	return self:GetDTFloat(0)
end

