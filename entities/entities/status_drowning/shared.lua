ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:SetStartTime(time)
	self:SetDTFloat(0, time)
end

function ENT:GetStartTime()
	return self:GetDTFloat(0)
end

function ENT:IsDrowning()
	local owner = self:GetOwner()
	if owner:IsValid() then
		return CurTime() >= self:GetStartTime() + owner:GetDrowningThreshold()
	end

	return false
end
