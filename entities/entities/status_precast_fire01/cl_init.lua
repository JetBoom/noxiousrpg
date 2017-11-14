include("shared.lua")

ENT.BaseSoundPitch = 110
ENT.SoundPitchOffset = 60

function ENT:PrecastInitialize()
	self.Seed = math.Rand(0, 10)
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
	self:SetRenderBoundsNumber(92)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 24)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.7 + self:GetSkillLevel(), self:GetCastSoundPitch())
	self.Emitter:SetPos(self:GetPos())
end

function ENT:PrecastOnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end

local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local ang = Angle(0, 0, 0)

		local up = owner:GetUp()
		ang:RotateAroundAxis(up, (RealTime() + self.Seed) * 420)

		local fwd = ang:Forward()

		local pos = owner:GetPos() + fwd * 32 + up * 8

		if DYNAMICLIGHTING then
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.Pos = pos
				dlight.r = 255
				dlight.g = 220
				dlight.b = 30
				dlight.Brightness = 1.5 + self:GetSkillLevel() * SKILLS_RMAX * 0.5
				dlight.Size = 150
				dlight.Decay = 600
				dlight.DieTime = CurTime() + 1
			end
		end

		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 32, 32, color_white)

		local particle = self.Emitter:Add("effects/fire_embers"..math.random(1,3), pos)
		particle:SetVelocity((25 + self:GetSkillLevel() * 0.25) * fwd)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(10 + self:GetSkillLevel() * 0.05)
		particle:SetEndSize(0)
		particle:SetDieTime(1)
		particle:SetGravity(up * 300)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
	end
end
