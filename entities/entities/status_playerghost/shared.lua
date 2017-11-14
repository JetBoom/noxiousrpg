ENT.Type = "anim"
ENT.Base = "status__base"

ENT.NoRemoveOnDeath = true

function ENT:GetPublicVisible()
	return self:GetDTBool(0)
end
ENT.IsPublicVisible = ENT.GetPublicVisible
