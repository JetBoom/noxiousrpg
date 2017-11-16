include("shared.lua")

function ENT:OnInitialize()
	self:SetRenderBoundsNumber(72)

	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.7, 75 + (5 - math.Clamp(self:GetStartTime() - CurTime(), 0, 5)) * 10)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end
end
