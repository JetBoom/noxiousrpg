ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:GetState()
	return self:GetDTInt(0)
end

function ENT:SetState(state)
	self:SetDTInt(0, state)
end

function ENT:GetEndTime()
	return self:GetDTFloat(0)
end

function ENT:SetEndTime(endtime)
	self:SetDTFloat(0, endtime)
	self.DieTime = endtime
end

function ENT:GetWallFreeze()
	return self:GetDTFloat(1)
end

function ENT:SetWallFreeze(freeze)
	self:SetDTFloat(1, freeze)
end

function ENT:ResetJumpPower()
	if self:GetOwner().KnockedDown then
		stat.Set(0)
	end
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if self.Created ~= CurTime() then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.7)
	end
end
