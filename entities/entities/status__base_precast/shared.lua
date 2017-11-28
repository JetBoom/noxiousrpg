ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:SetCastTime(time)
	self:SetDTFloat(0, time)
end

function ENT:GetCastTime()
	return self:GetDTFloat(0)
end

function ENT:SetCastFinishTime(time)
	self:SetDTFloat(1, time)
end

function ENT:GetCastFinishTime(time)
	self:GetDTFloat(1)
end

function ENT:SetSkillLevel(skill)
	self:SetDTFloat(1, skill)
end

function ENT:GetSkillLevel()
	return self:GetDTFloat(1)
end

function ENT:GetCastPercent()
	local spelldata = self.SpellData
	if spelldata.CastTime and spelldata.CastTime > 0 then
		return 1 - math.Clamp((self:GetCastFinishTime() - self:GetCastTime()) / spelldata.CastTime, 0, 1)
	end

	return 1
end

function ENT:PrecastInitialize()
end

function ENT:PrecastOnRemove()
end

--[[function ENT:ResetJumpPower()
	if not self:IsRemoving() then
		stat.Mul(0.75)
	end
end]]
