include("shared.lua")

function ENT:OnInitialize()
	self:SetRenderBoundsNumber(72)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	self.Created = CurTime()
end

function ENT:CreateParticle(pos, r, g, b)
	local particle = self.Emitter:Add("sprites/glow04_noz", pos)
	particle:SetDieTime(math.Rand(0.3, 1))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(3, 7))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-30, 30))
	particle:SetColor(r * math.Rand(0.7, 1), g * math.Rand(0.7, 1), b * math.Rand(0.7, 1))
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(2, 64))
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	local target = self:GetTarget()
	local col = owner:IsValid() and target:IsValid() and owner:GetNameColor(target) or COLOR_WHITE
	local r, g, b = col.r, col.g, col.b

	local beampositions = self.BeamPositions
	if beampositions then
		for i, beamposition in ipairs(beampositions) do
			local nextbeam = beampositions[i + 1]
			if nextbeam then
				local norm = nextbeam - beamposition
				norm:Normalize()

				local dist = nextbeam:Distance(beamposition)
				for x=0, 1, 0.1 do
					local basepos = beamposition + dist * x * norm
					for _=1, math.random(1, 4) do
						self:CreateParticle(basepos + VectorRand():GetNormalized() * math.Rand(1, 8), r, g, b)
					end
				end
			end
		end
	end

	if target:IsValid() then
		local pos = target:LocalToWorld(target:OBBCenter())
		for i=1, 16 do
			self:CreateParticle(pos + VectorRand():GetNormalized() * math.Rand(8, 32), r, g, b)
		end
	end

	self.Emitter:Finish()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	local owner = self:GetOwner()
	local target = self:GetTarget()
	if owner:IsValid() and target:IsValid() then
		local ownerpos = owner:CastPos()
		local targetpos = target:LocalToWorld(target:OBBCenter())
		if self.BeamPositions then
			local norm = targetpos - ownerpos
			norm:Normalize()

			local ft = FrameTime()
			for i=1, 16 do
				local desired = ownerpos + targetpos:Distance(ownerpos) * (i / 16) * norm
				local current = self.BeamPositions[i]
				local power = ft * math.max(0.15, (math.abs(i - 12) / 4)) * math.min(desired:Distance(current) * 1.25, 512)
				self.BeamPositions[i] = current + (desired - current):GetNormalized() * power
			end
		else
			self.BeamPositions = {}
			local norm = targetpos - ownerpos
			norm:Normalize()

			local dist = targetpos:Distance(ownerpos)
			for i=1, 16 do
				self.BeamPositions[i] = ownerpos + (i / 16) * dist * norm
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

local matBeam = Material("trails/laser")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local target = self:GetTarget()
	if not target:IsValid() then return end

	local col = owner:GetNameColor(target)
	local endpos = target:LocalToWorld(target:OBBCenter())

	local beampositions = self.BeamPositions
	if beampositions then
		render.SetMaterial(matBeam)
		render.StartBeam(18)
		render.AddBeam(owner:CastPos(), 16, 0, col)
		for i, beampos in ipairs(beampositions) do
			render.AddBeam(beampos, 10, i * 0.5, col)
		end
		render.AddBeam(endpos, 16, 1, col)
		render.EndBeam()
	end

	local r, g, b = col.r, col.g, col.b
	for i=1, math.random(1, 3) do
		self:CreateParticle(endpos + VectorRand():GetNormalized() * math.Rand(3, 16), 255, 255, 255)
	end

	local rt = RealTime()

	render.SetMaterial(matGlow)
	render.DrawSprite(endpos, 64, 64, color_white)
	local pos1 = endpos + Angle(UnPredictedCurTime() * 360, rt * 360, math.sin(rt)):Forward() * 32
	render.DrawSprite(pos1, 38, 38, col)
	local pos2 = endpos + Angle((self.Created + UnPredictedCurTime()) * 360, CurTime() * -360, math.cos(rt)):Forward() * 32
	render.DrawSprite(pos2, 38, 38, col)

	self:CreateParticle(pos1, r, g, b)
	self:CreateParticle(pos2, r, g, b)

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = endpos
			dlight.r = r
			dlight.g = g
			dlight.b = b
			dlight.Brightness = 2
			dlight.Size = 300
			dlight.Decay = 1200
			dlight.DieTime = CurTime() + 1
		end
	end
end
