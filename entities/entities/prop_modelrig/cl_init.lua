include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if owner:IsValid() and not (owner:IsPlayer() and (owner:GetRagdollEntity() or owner == LocalPlayer() and not owner:ShouldDrawLocalPlayer())) then
		self:DrawModel()
		-- TODO: Flexing, poseparameters, etc. if they don't already do this.
	end
end