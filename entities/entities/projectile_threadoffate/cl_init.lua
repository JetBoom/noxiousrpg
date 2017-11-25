include("shared.lua")

util.PrecacheSound("weapons/physgun_off.wav")
util.PrecacheSound("weapons/gauss/chargeloop.wav")

--ENT.MaxTrailPositions = 64

function ENT:ProjectileInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "weapons/gauss/chargeloop.wav")
	self:EmitSound("weapons/physgun_off.wav")

	self.TrailPositions = {}
	self.NextTrailPosition = 0
end

function ENT:Think()
	local rt = RealTime()

	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.72, 200 + math.sin(rt))

	if rt >= self.NextTrailPosition then
		self.NextTrailPosition = rt + 0.1
		self.TrailPositions[#self.TrailPositions + 1] = self:GetPos()

		--[[local tp = self.TrailPositions
		local tpn = #tp
		tp[tpn + 1] = self:GetPos()
		if tpn >= self.MaxTrailPositions then
			local mid = math.floor(tpn / 2)
			tp[mid + 1] = (tp[mid + 1] + tp[mid]) / 2
			table.remove(tp, mid)
		end]]
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.Emitter:Finish()
end

local vRadius = Vector(64, 64, 64)
local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("trails/laser")
function ENT:DrawTranslucent()
	local pos = self:GetPos()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local col = (not MySelf:IsValid() or owner == MySelf) and COLOR_WHITE or owner:GetNameColor(MySelf)
	local r, g, b = col.r, col.g, col.b

	self:SetRenderBoundsWS(owner:EyePos(), pos, vRadius)

	if DYNAMICLIGHTING then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = pos
			dlight.r = r
			dlight.g = g
			dlight.b = b
			dlight.Brightness = 2
			dlight.Size = 300
			dlight.Decay = 1200
			dlight.DieTime = CurTime() + 1
		end
	end

	render.SetMaterial(matBeam)
	render.StartBeam(#self.TrailPositions)
	for i, p in ipairs(self.TrailPositions) do
		render.AddBeam(p, 5, i * 0.5, col)
	end
	render.EndBeam()

	local size1 = math.sin(RealTime() * 35) * 33 + 64
	local size2 = math.cos(RealTime() * 38) * 21 + 64
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size1, size1, col)
	render.DrawSprite(pos, size2, size2, COLOR_WHITE)

	local particle = self.Emitter:Add("sprites/light_glow02_add", pos + VectorRand():GetNormalized() * math.Rand(4, 24))
	particle:SetDieTime(math.Rand(0.5, 0.75))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(50)
	particle:SetStartSize(math.Rand(8, 10))
	particle:SetEndSize(1)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(r, g, b)
end
