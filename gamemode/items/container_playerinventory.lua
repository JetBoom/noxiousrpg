ITEM.Base = "container_base"
ITEM.Model = "models/error.mdl"

function ITEM:GetName()
	local owner = self:GetRootEntity()
	if owner:IsValid() and owner:IsPlayer() then
		return "inventory of "..owner:RPGName()
	end

	return "inventory"
end

function ITEM:GetMassCapacity()
	local owner = self:GetEntity()
	if owner:IsValid() and owner:IsPlayer() then
		return 100 + math.floor(owner:GetSkill(SKILL_STRENGTH) * 0.5)
	end
end
