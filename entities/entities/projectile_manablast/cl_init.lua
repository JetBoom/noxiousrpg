include("shared.lua")

util.PrecacheSound("nox/energyhum3.wav")

function ENT:ProjectileInitialize()
	self.AmbientSound = CreateSound(self, "nox/energyhum3.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.7, 100 + math.sin(RealTime()))
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local function GetRefraction()
	return 0.75 + math.abs(math.sin(CurTime() * 5)) * math.pi * 0.25
end

local matRefract = Material("refract_ring")
local matRing = Material("effects/select_ring")
function ENT:DrawTranslucent()
	local pos = self:GetPos()

	local damage = self:GetProjectileDamage()
	local radius = self:GetProjectileRadius()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = damage * 0.1
			dlight.Size = radius
			dlight.Decay = radius * 4
			dlight.DieTime = CurTime() + 1
		end
	end

	local basesize = 16 + radius
	local size1 = basesize + math.sin(RealTime() * 35) * 12
	local size2 = basesize + math.cos(RealTime() * 38) * 8
	render.SetMaterial(matRing)
	render.DrawSprite(pos, size1, size1, color_white)
	render.DrawSprite(pos, size2, size2, color_white)

	matRefract:SetMaterialFloat("$refractamount", GetRefraction())
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, basesize, basesize, color_white)
end

local EFFECT = {}
EFFECT.LifeTime = 0.5
function EFFECT:Init(data)

	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1
	local damage = data:GetMagnitude()
	local radius = data:GetRadius()
	local force = data:GetScale()

	self.Pos = pos + normal
	self.Damage = damage
	self.Radius = radius
	self.Force = force
	self.Normal = normal
	self.DieTime = CurTime() + self.LifeTime

	WorldSound("weapons/physcannon/energy_sing_explosion2.wav", pos, math.min(100, 70 + damage * 4), math.Rand(120, 130))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local eyeangles = EyeAngles()
	local eyeforward = eyeangles:Forward()

	for i=1, math.random(40, 60) + 30 * damage do
		eyeangles:RotateAroundAxis(eyeforward, math.Rand(0, 360))
		local heading = VectorRand():GetNormalized()
		local particle = emitter:Add("effects/spark", pos + heading * 8)
		particle:SetVelocity((400 + force) * heading)
		particle:SetDieTime(math.Rand(0.5, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(0.3, 0.5) * damage)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(250)
	end

	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = damage * 0.1
			dlight.Size = radius * 1.5
			dlight.Decay = radius * 6
			dlight.DieTime = CurTime() + 1
		end
	end

	ExplosiveEffect(pos, radius, force, DMGTYPE_VOID)
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

function EFFECT:Render()
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	local basesize = 16 + self.Radius
	basesize = basesize + basesize ^ (1.5 - delta)

	local pos = self.Pos
	matRefract:SetMaterialFloat("$refractamount", GetRefraction() * delta)
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, basesize, basesize, color_white)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)
end
effects.Register(EFFECT, "explosion_manablast")
