include("shared.lua")

function ENT:OnInitialize()
	local owner = self:GetOwner()
	owner.m_PlayerGhost = self

	self.m_Delay = CurTime() + 0.1
	self.Think = self.DelayedInitialize
end

function ENT:DelayedInitialize()
	if CurTime() >= self.m_Delay then
		self.m_Delay = nil
		self.Think = self._Think

		local owner = self:GetOwner()
		if owner:IsValid() and owner == MySelf then
			self.AmbientSound = CreateSound(owner, "ambient/levels/citadel/citadel_hub_ambience1.mp3")
			owner:SetDSP(16, true) --owner:SetDSP(56, true)
		end
	end
end

function ENT:_Think()
	if self.AmbientSound then
		self.AmbientSound:PlayEx(0.5, 100 + math.sin(RealTime()))
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() and owner.m_PlayerGhost == self then
		owner.m_PlayerGhost = nil
	end

	if self.AmbientSound then
		self.AmbientSound:Stop()
	end
end

function ENT:SetPublicVisible(onoff)
	self:SetDTBool(0, onoff)
end
