util.PrecacheSound("physics/flesh/flesh_bloody_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard2.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard3.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard4.wav")

local function CollideCallbackSmall(particle, hitpos, hitnormal)
	particle:SetDieTime(0)
	if math.random(1, 3) == 3 then
		WorldSound("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
		util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
	end
end

local function CollideCallback(oldparticle, hitpos, hitnormal)
	oldparticle:SetDieTime(0)

	local pos = hitpos + hitnormal

	if math.random(1, 3) == 3 then
		WorldSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav", hitpos, 50, math.random(95, 105))
	end
	util.Decal("Blood", pos, hitpos - hitnormal)

	local nhitnormal = hitnormal * 90
	local scale = oldparticle.bType

	local emitter = ParticleEmitter(pos)
		for i=1, math.random(-4, 4) do
			local particle
			if scale == 4 then
				particle = emitter:Add("sprites/glow04_noz", pos)
			else
				particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(1,8), pos)
				particle:SetLighting(true)
			end
			particle:SetVelocity(VectorRand():GetNormalized() * math.random(75, 150) + nhitnormal)
			particle:SetDieTime(3)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(1.5, 2.5))
			particle:SetEndSize(1.5)
			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-25, 25))
			particle:SetAirResistance(5)
			particle:SetBounce(0)
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetCollide(true)
			if scale == 1 then
				particle:SetColor(60, 255, 60)
			elseif scale == 2 then
				particle:SetColor(100, 100, 255)
			elseif scale == 3 then
				particle:SetColor(math.random(100, 255), math.random(100, 255), math.random(100, 255))
			elseif scale == 5 then
				particle:SetColor(5, 5, 5)
			elseif scale == 4 then
				particle:SetColor(255, 255, 255)
			else
				particle:SetColor(255, 0, 0)
			end
			particle:SetCollideCallback(CollideCallbackSmall)
		end
	emitter:Finish()
end

function EFFECT:Init(data)
	local Pos = data:GetOrigin() + Vector(0,0,10)

	local bdye = math.Round(data:GetRadius())
	local dir = data:GetNormal()
	local force = data:GetScale()

	local emitter = ParticleEmitter(Pos)
		for i=1, data:GetMagnitude() do
			local particle
			if bdye == 4 then
				particle = emitter:Add("sprites/glow04_noz", Pos + VectorRand() * 8)
			else
				particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(1,8), Pos + VectorRand() * 8)
				particle:SetLighting(true)
			end
			particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(force * 0.4, force * 0.7) + Vector(0,0,force * 0.5) + force * math.Rand(0.8, 1.2) * dir)
			particle:SetDieTime(math.Rand(3, 6))
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(200)
			particle:SetStartSize(math.Rand(5, 8))
			particle:SetEndSize(5)
			particle:SetRoll(math.Rand(-20, 20))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetAirResistance(5)
			particle:SetBounce(0)
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetCollide(true)
			if bdye == 1 then
				particle:SetColor(60, 255, 60)
			elseif bdye == 2 then
				particle:SetColor(100, 100, 255)
			elseif bdye == 3 then
				particle:SetColor(math.random(100, 255), math.random(100, 255), math.random(100, 255))
			elseif bdye == 5 then
				particle:SetColor(5, 5, 5)
			elseif bdye == 4 then
				particle:SetColor(255, 255, 255)
			else
				particle:SetColor(255, 0, 0)
			end
			particle:SetCollideCallback(CollideCallback)
			particle.bType = bdye
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
