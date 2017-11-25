function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1
	local skill = data:GetMagnitude()
	local magnitude = skill * SKILLS_RMAX

	util.Decal("Scorch", pos + normal, pos - normal)

	WorldSound("ambient/explosions/explode_7.wav", pos, math.min(100, 75 + magnitude * 5), math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particle/smokestack", pos)
	particle:SetVelocity(normal * 100)
	particle:SetDieTime(math.Rand(2.4, 3))
	particle:SetStartAlpha(220)
	particle:SetEndAlpha(0)
	particle:SetStartSize(24)
	particle:SetEndSize(200)
	particle:SetColor(30, 20, 20)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetAirResistance(300)

	local firesize = 20 + magnitude * 12
	local force = 350 + magnitude * 250

	for i=1, 16 + magnitude * 10 do
		local heading = normal + VectorRand()
		heading:Normalize()
		local vel = math.Rand(0.25, 1) * force * heading

		local particle = emitter:Add("particle/smokestack", pos + heading * 8)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(1.4, 2.6))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(12, 16))
		particle:SetColor(30, 20, 20)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(500)

		particle = emitter:Add("effects/fire_cloud1", pos + heading)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.9, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(firesize)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetAirResistance(180)
	end
	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 180
			dlight.b = 0
			dlight.Brightness = 5 + skill * SKILLS_RMAX * 2
			dlight.Size = 260
			dlight.Decay = 500
			dlight.DieTime = CurTime() + 1
		end
	end

	ExplosiveEffect(pos, SPELL_FIREBALL.ProjectileRadius + SPELL_FIREBALL.ProjectileRadiusPerSkill * skill, SPELL_FIREBALL.ProjectileDamage + SPELL_FIREBALL.ProjectileDamagePerSkill * skill, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
