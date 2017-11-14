ITEM.DecayTime = GIB_DECAYTIME
ITEM.PhysMaterial = "flesh"

if CLIENT then
	function ENT:Initialize()
		--self.BaseClass.Initialize(self)

		self.Emitter = ParticleEmitter(self:LocalToWorld(self:OBBCenter()))
		self.Emitter:SetNearClip(24, 32)
	end

	function ENT:Think()
		--self.BaseClass.Think(self)

		self.Emitter:SetPos(self:LocalToWorld(self:OBBCenter()))
	end

	local function CollideCallback(particle, hitpos, hitnormal)
		particle:SetDieTime(0)
		if math.random(1, 3) == 3 then
			WorldSound("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
			if particle:GetEndSize() > 3 then
				util.Decal("Blood", hitpos + hitnormal, hitpos - hitnormal)
			else
				util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
			end
		end
	end
	function ENT:Draw()
		--self.BaseClass.Draw(self)
		self:DrawModel()

		local vel = self:GetVelocity()
		if vel:Length() >= 64 then
			local particle = self.Emitter:Add("noxctf/sprite_bloodspray"..math.random(1,8), self:LocalToWorld(self:OBBCenter()))
			particle:SetVelocity(vel * 0.6)
			particle:SetLighting(true)
			particle:SetDieTime(3)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			local size = self:BoundingRadius() * math.Rand(0.3, 0.7)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-25, 25))
			particle:SetAirResistance(5)
			particle:SetBounce(0)
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetCollide(true)
			particle:SetCollideCallback(CollideCallback)
			particle:SetColor(255, 100, 100)
		end
	end
end
