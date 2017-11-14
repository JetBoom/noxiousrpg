include("shared.lua")

util.PrecacheSound("WeaponDissolve.Charge")

function ENT:ProjectileInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "WeaponDissolve.Charge")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.7, 100 + math.sin(RealTime()))
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
			dlight.r = 220
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 2 + self:GetSkillLevel() * SKILLS_RMAX
			dlight.Size = 300
			dlight.Decay = 1200
			dlight.DieTime = CurTime() + 1
		end
	end

	local size1 = math.sin(RealTime() * 35) * 33 + 64
	local size2 = math.cos(RealTime() * 38) * 21 + 64
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size1, size1, COLOR_CYAN)
	render.DrawSprite(pos, size2, size2, color_white)

	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand():Normalize() * math.Rand(2, 6))
		particle:SetDieTime(math.Rand(0.3, 0.5))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(8, 10))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(50, 100, 255)

		particle = emitter:Add("effects/spark", pos)
		particle:SetVelocity(VectorRand():Normalize() * math.Rand(16, 32))
		particle:SetDieTime(math.Rand(0.6, 0.8))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(12, 15))
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.8, 1.8))
		particle:SetColor(50, 100, 255)
		particle:SetAirResistance(10)
	end
end

local EFFECT = {}
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1
	local skill = data:GetMagnitude()
	local magnitude = skill * SKILLS_RMAX

	util.Decal("FadingScorch", pos + normal, pos - normal)

	WorldSound("ambient/levels/labs/electric_explosion1.wav", pos, math.min(100, 75 + magnitude * 5), math.Rand(90, 100))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, math.random(40, 60) + 30 * magnitude do
		local heading = VectorRand():Normalize()

		local particle = emitter:Add("effects/spark", pos + heading * 8)
		particle:SetVelocity(heading * 500)
		particle:SetDieTime(math.Rand(0.5, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(4, 5))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(250)
	end

	for i=1, math.random(8, 12) + 6 * magnitude do
		local particle = emitter:Add("particles/flamelet"..math.random(1, 5), pos + (math.Rand(32, 48) + magnitude * 8) * VectorRand():Normalize())
		particle:SetDieTime(1)
		particle:SetStartAlpha(math.Rand(230, 250))
		particle:SetStartSize(20 * math.Rand(4, 6))
		particle:SetEndSize(math.Rand(2, 3))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(100, 250))
		particle:SetColor(20, math.Rand(80, 120), math.Rand(200, 255))
	end

	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 220
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 5 + magnitude * 2
			dlight.Size = 375
			dlight.Decay = 850
			dlight.DieTime = CurTime() + 1
		end
	end

	ExplosiveEffect(pos, SPELL_SHOCKINGBOLT.ProjectileRadius + SPELL_SHOCKINGBOLT.ProjectileRadiusPerSkill * skill, SPELL_SHOCKINGBOLT.ProjectileDamage + SPELL_SHOCKINGBOLT.ProjectileDamagePerSkill * skill, DMGTYPE_SHOCK)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
effects.Register(EFFECT, "explosion_shockingbolt")
