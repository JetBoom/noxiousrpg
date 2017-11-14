function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1
	local skill = data:GetMagnitude()
	local magnitude = skill * SKILLS_RMAX

	util.Decal("FadingScorch", pos + normal, pos - normal)

	WorldSound("ambient/explosions/explode_9.wav", pos, math.min(100, 75 + magnitude * 5), math.Rand(115, 130))

	local additional = normal * 100

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particle/smokestack", pos)
	particle:SetVelocity(additional)
	particle:SetDieTime(math.Rand(2.1, 2.5))
	particle:SetStartAlpha(254)
	particle:SetEndAlpha(0)
	particle:SetStartSize(16)
	particle:SetEndSize(64)
	particle:SetColor(30, 20, 20)
	particle:SetRoll(math.Rand(0, 359))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetAirResistance(300)

	local firesize = 8 + magnitude * 8
	local force = 300 + magnitude * 200

	for i=1, 8 + magnitude * 8 do
		local heading = (normal + VectorRand()):Normalize()
		local vel = force * heading

		local particle = emitter:Add("particle/smokestack", pos + heading * 8)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.7, 1.6))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(12, 16))
		particle:SetColor(30, 20, 20)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(600)

		particle = emitter:Add("effects/fire_cloud1", pos + heading)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.5, 0.75))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(firesize)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetAirResistance(300)
	end
	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 180
			dlight.b = 0
			dlight.Brightness = 4 + skill * SKILLS_RMAX * 1.5
			dlight.Size = 160
			dlight.Decay = 400
			dlight.DieTime = CurTime() + 1
		end
	end

	ExplosiveEffect(pos, SPELL_EMBER.ProjectileRadius + SPELL_EMBER.ProjectileRadiusPerSkill * skill, SPELL_EMBER.ProjectileDamage + SPELL_EMBER.ProjectileDamagePerSkill * skill, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
