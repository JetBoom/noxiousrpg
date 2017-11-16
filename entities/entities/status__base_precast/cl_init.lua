include("shared.lua")

ENT.BaseSoundPitch = 100
ENT.SoundPitchOffset = 50

function ENT:GetCastSoundPitch()
	return self.BaseSoundPitch + self:GetCastPercent() * self.SoundPitchOffset + math.sin(RealTime())
end

function ENT:OnInitialize()
	self:SetRenderBoundsNumber(92)
	self.Created = CurTime()
	self:GetOwner().Precast = self

	self:PrecastInitialize()
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner.Precast == self then
		owner.Precast = nil
	end

	self:PrecastOnRemove()
end
