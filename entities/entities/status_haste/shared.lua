ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:GetSkillLevel()
	return self:GetDTFloat(0)
end

function ENT:SetSkillLevel(skill)
	self:SetDTFloat(0, skill)
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:ResetSpeed()
	end
end

function ENT:ResetSpeed()
	if not self:IsRemoving() then
		stat.Add(SPELL_HASTE.Bonus + SPELL_HASTE.BonusPerSkill * self:GetSkillLevel())
	end
end
