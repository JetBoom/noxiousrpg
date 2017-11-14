include("shared.lua")

ENT.BaseSoundPitch = 100
ENT.SoundPitchOffset = 50

function ENT:PrecastInitialize()
	self.AmbientSound = CreateSound(self, "nox/energyhum1.wav")
	self:SetRenderBoundsNumber(64)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.8, self:GetCastSoundPitch())
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local skill = self:GetSkillLevel()
		local ang = owner:GetAngles()
		local up = ang:Up()
		ang:RotateAroundAxis(up, math.Rand(0, 360))

		local pos = owner:GetPos() + up * 8

		if DYNAMICLIGHTING then
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.Pos = pos
				dlight.r = 220
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 1 + skill * SKILLS_RMAX * 0.3
				dlight.Size = 100
				dlight.Decay = 400
				dlight.DieTime = CurTime() + 1
			end
		end

		local particle = self.Emitter:Add("particle/smokestack", pos)
		particle:SetVelocity((skill + 64) * ang:Forward() + owner:GetVelocity())
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4 + skill * 0.025)
		particle:SetEndSize(0)
		particle:SetDieTime(0.75)
		particle:SetGravity(up * 128)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1) * skill)
	end
end

function ENT:PrecastOnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end
