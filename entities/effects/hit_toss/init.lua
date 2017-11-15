function EFFECT:Init(data)
	local ent = data:GetEntity()
	local dir = data:GetNormal() * -1
	local pos = data:GetOrigin()
	local frompos = data:GetStart()
	local skill = data:GetMagnitude()
	local force = data:GetScale()

	local magnitude = skill * SKILLS_RMAX

	WorldSound("nox/airburst.wav", pos, 70 + magnitude * 5, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("sprites/glow04_noz", pos)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(32 + magnitude * 10)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(60 + magnitude * 20)

	emitter:Finish()

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(0)
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 5
			dlight.Size = 128
			dlight.Decay = 512
			dlight.DieTime = CurTime() + 1
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
