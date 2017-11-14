include("shared.lua")

ENT.BaseSoundPitch = 100
ENT.SoundPitchOffset = 40

ENT.PrimaryColor = Color(220, 255, 255)
ENT.AmbientSoundName = Sound("nox/energyhum2.wav")

function ENT:PrecastInitialize()
	self.AmbientSound = CreateSound(self, self.AmbientSoundName)
	self:SetRenderBoundsNumber(92)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.Seed = math.Rand(0, 10)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.8, self:GetCastSoundPitch())
	self.Emitter:SetPos(self:GetPos())
end

function ENT:PrecastOnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end

local colBeam = Color(255, 255, 255, 255)
local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local skill = self:GetSkillLevel()

		local ang = owner:GetAngles()
		local up = ang:Up()
		local pos = owner:GetPos() + up * 8

		local r, g, b = self.PrimaryColor.r, self.PrimaryColor.g, self.PrimaryColor.b

		if DYNAMICLIGHTING then
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.Pos = pos
				dlight.r = r
				dlight.g = g
				dlight.b = b
				dlight.Brightness = 1 + skill * SKILLS_RMAX * 0.3
				dlight.Size = 150
				dlight.Decay = 600
				dlight.DieTime = CurTime() + 1
			end
		end

		local vecSave = Vector(0, 0, 0)

		local numbeams = 3 + math.floor(skill * 0.02)
		colBeam.r = r
		colBeam.g = g
		colBeam.b = b

		for x=1, numbeams do
			ang.yaw = math.NormalizeAngle((self.Seed + CurTime()) * -480 + (x / numbeams) * 360)

			local basepos = pos + ang:Forward() * 32

			local particle = self.Emitter:Add("particle/smokestack", basepos)
			particle:SetVelocity(owner:GetVelocity())
			particle:SetStartAlpha(math.Rand(90, 120))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(6, 8) + skill * 0.03)
			particle:SetEndSize(0)
			particle:SetDieTime(math.Rand(0.5, 0.75))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetColor(r, g, b)

			render.SetMaterial(matGlow)
			render.DrawSprite(basepos, 16, 16, color_white)

			render.SetMaterial(matBeam)
			render.StartBeam(16)
			for i=1, 16 do	
				vecSave.z = i * 5
				colBeam.a = 255 - i * 12
				render.AddBeam(pos + ang:Forward() * 32 + vecSave, 32 - i * 2, i * 0.5, colBeam)
				ang:RotateAroundAxis(up, 3 + i)
			end
			render.EndBeam()
		end
	end
end
