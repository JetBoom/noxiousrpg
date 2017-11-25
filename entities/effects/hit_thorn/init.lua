function EFFECT:Init(data)
	local dir = data:GetNormal() * -1
	local pos = data:GetOrigin() + dir * 0.5
	local magnitude = data:GetMagnitude() * SKILLS_RMAX

	util.Decal("Impact.Concrete", pos + dir, pos - dir)
	WorldSound("weapons/fx/rics/ric"..math.random(1,5)..".wav", pos, 70 + magnitude * 5, math.Rand(200, 255) - magnitude * 50)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, 16 + magnitude * 16 do
		local heading = VectorRand() + dir
		heading:Normalize()
		local particle = emitter:Add("particles/smokey", pos + heading * 4)
		particle:SetDieTime(math.Rand(0.5, 1.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(math.Rand(5, 9))
		particle:SetVelocity((magnitude * 30 + 30) * heading)
		particle:SetAirResistance(50)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetColor(100, 100, 100)
	end

	local particle = emitter:Add("sprites/glow04_noz", pos)
	particle:SetDieTime(math.Rand(0.3, 0.4))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(16 + magnitude * 8)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(30 + magnitude * 30)

	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 5
			dlight.Size = 32
			dlight.Decay = 128
			dlight.DieTime = CurTime() + 1
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
