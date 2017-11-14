include("shared.lua")

ENT.BaseSoundPitch = 100
ENT.SoundPitchOffset = 50

ENT.PrimaryColor = Color(255, 255, 255, 255)
ENT.SecondaryColor = Color(40, 200, 255, 255)
ENT.AmbientSoundName = Sound("nox/energyhum1.wav")

function ENT:InitializeRandomPosition(i, lifetime)
	local owner = self:GetOwner()
	if owner:IsValid() then
		local mins, maxs = owner:OBBMins(), owner:OBBMaxs()

		self.SpritePositions[i] = Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z))
		self.SpriteLifeTimes[i] = lifetime
		self.SpriteDieTimes[i] = RealTime() + lifetime
	end
end

function ENT:PrecastInitialize()
	self.AmbientSound = CreateSound(self, self.AmbientSoundName)
	self:SetRenderBoundsNumber(92)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.SpritePositions = {}
	self.SpriteLifeTimes = {}
	self.SpriteDieTimes = {}

	for i=1, math.random(8, 12) + self:GetSkillLevel() * 0.05 do
		self:InitializeRandomPosition(i, math.Rand(0.5, 2))
	end
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.8, self:GetCastSoundPitch())
	self.Emitter:SetPos(self:GetPos())
end

function ENT:PrecastOnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end

local matGlow = Material("effects/yellowflare")
local colGlow = Color(255, 255, 255, 255)
function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local skill = self:GetSkillLevel()

		local colGlow = self.PrimaryColor

		if DYNAMICLIGHTING then
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.Pos = owner:GetPos() + owner:GetUp() * 8
				dlight.r = colGlow.r
				dlight.g = colGlow.g
				dlight.b = colGlow.b
				dlight.Brightness = 1 + skill * 0.003
				dlight.Size = 150
				dlight.Decay = 600
				dlight.DieTime = CurTime() + 1
			end
		end

		render.SetMaterial(matGlow)
		local realtime = RealTime()
		for i, pos in ipairs(self.SpritePositions) do
			if self.SpriteDieTimes[i] <= realtime then
				self:InitializeRandomPosition(i, math.Rand(0.6, 1))
			else
				local magnitude = (self.SpriteDieTimes[i] - realtime) / self.SpriteLifeTimes[i]

				colGlow.a = magnitude * 127.5
				self.SecondaryColor.a = colGlow.a

				local size = (0.5 - math.abs(0.5 - magnitude)) * 2
				render.DrawSprite(owner:LocalToWorld(pos), size * 12, size * 32, colGlow)
				render.DrawSprite(owner:LocalToWorld(pos), size * 6, size * 16, self.SecondaryColor)
			end
		end
	end
end
