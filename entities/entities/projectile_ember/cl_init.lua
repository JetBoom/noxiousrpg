include("shared.lua")

ENT.RenderBoundsNumber = 128

function ENT:ProjectileInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.Seed = math.Rand(0, 10)

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.72, math.max(100 - self:GetSkillLevel() * 0.2, 80) + math.sin(CurTime()))
	self.Emitter:SetPos(self:GetPos())

	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/fireballwhoosh.wav", 75 + self:GetSkillLevel() * 0.05, math.max(60, math.Rand(95, 105) - self:GetSkillLevel() * 0.2))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local pos = self:GetPos()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 180
			dlight.b = 0
			dlight.Brightness = 2 + self:GetSkillLevel() * SKILLS_RMAX
			dlight.Size = 100
			dlight.Decay = 300
			dlight.DieTime = CurTime() + 1
		end
	end

	local rt = RealTime() + self.Seed

	render.SetMaterial(matGlow)
	local size = 10 + 0.1 * self:GetSkillLevel()
	local size1, size2 = math.abs(math.sin(rt * 12)) * size + size, math.abs(math.cos(rt * 12)) * size + size
	render.DrawSprite(pos, size2, size1, COLOR_ORANGE)
	render.DrawSprite(pos, size1, size2, COLOR_WHITE)

	local emitter = self.Emitter
	local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand():GetNormalized() * math.Rand(2, 6))
	particle:SetDieTime(math.Rand(0.2, 0.4))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(50)
	particle:SetStartSize(size * 0.25)
	particle:SetEndSize(2)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(255, 220, 100)

	particle = emitter:Add("effects/muzzleflash2", pos)
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(0.6, 1) * size)
	particle:SetDieTime(math.Rand(0.4, 0.6))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(60)
	particle:SetStartSize(size * 0.5)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-0.8, 0.8))
	particle:SetColor(255, 200, 0)
	particle:SetAirResistance(10)
end
