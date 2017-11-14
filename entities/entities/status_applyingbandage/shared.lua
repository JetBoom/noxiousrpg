ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:ResetSpeed()
	if not self:IsRemoving() then
		stat.Mul(0.75)
	end
end

function ENT:GetSkillLevel()
	return self:GetDTFloat(3)
end

function ENT:SetEndTime(tim)
	self:SetDTFloat(2, tim)
end

function ENT:GetEndTime()
	return self:GetDTFloat(2)
end

function ENT:SetHealTarget(ent)
	self:SetDTEntity(0, ent)
end

function ENT:GetHealTarget()
	return self:GetDTEntity(0)
end
