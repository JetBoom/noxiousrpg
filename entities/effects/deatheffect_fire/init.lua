function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	self.Death = CurTime() + 10
	self.Entity:SetRenderBoundsNumber(128)

	self.Threshold = CurTime() + 2
	self.NextEmit = 0
end

function EFFECT:Think()
	local ent = self.Owner

	if not (CurTime() < self.Death and ent and ent:IsValid() and not ent:Alive()) then
		return CurTime() < self.Threshold
	end

	ent = ent:GetRagdollEntity()
	if ent then
		if ent.Frozen or ent.Broken then
			return false
		end
		ent.Burnt = true
		self.Entity:SetPos(ent:GetPos())
		self.DoDraw = true
		self.Ent = ent
		local color = ent:GetColor()
		r = math.max(20, r - FrameTime() * 200)
		ent:SetColor(color.r, color.r, color.r, color.a)
	else
		return CurTime() < self.Threshold
	end

	return true
end

function EFFECT:Render()
	if self.DoDraw and self.Ent:IsValid() and self.NextEmit <= CurTime() then
		self.NextEmit = CurTime() + 0.1

		self.DoDraw = false
		local ent = self.Ent

		local emitter = ParticleEmitter(ent:GetPos())
		emitter:SetNearClip(50, 60)

		for i=1, ent:GetPhysicsObjectCount() do
			if math.random(0, 1) == 0 then
				local phys = ent:GetPhysicsObjectNum(i)
				if phys and phys:IsValid() then
					if math.random(1, 5) > 1 then
						local particle = emitter:Add("effects/fire_embers"..math.random(1, 3), phys:GetPos())
						particle:SetDieTime(math.Rand(0.4, 0.6))
						particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(-12, 12) + Vector(0, 0, 12))
						particle:SetStartAlpha(200)
						particle:SetEndAlpha(60)
						particle:SetStartSize(math.Rand(8, 16))
						particle:SetEndSize(2)
						particle:SetRoll(math.Rand(0, 359))
						particle:SetRollDelta(math.Rand(-2, 2))
					else
						local particle = emitter:Add("particles/smokey", phys:GetPos())
						particle:SetDieTime(math.Rand(0.6, 1.0))
						particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(-12, 12))
						particle:SetGravity(Vector(0, 0, math.Rand(24, 32)))
						particle:SetColor(20, 20, 20)
						particle:SetStartAlpha(130)
						particle:SetEndAlpha(1)
						particle:SetStartSize(2)
						particle:SetEndSize(math.Rand(12, 17))
						particle:SetRoll(math.Rand(0, 359))
						particle:SetRollDelta(math.Rand(-2, 2))
					end
				end
			end
		end

		emitter:Finish()
	end
end
