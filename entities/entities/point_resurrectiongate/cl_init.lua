include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(self.CollisionBoundsMin, self.CollisionBoundsMax)

	self.AmbientSound = CreateSound(self, "ambient/levels/labs/machine_ring_resonance_loop1.wav")
end

function ENT:Think()
	if MySelf:IsValid() and MySelf:IsGhost() then
		self.AmbientSound:PlayEx(0.8, 100 + math.sin(RealTime()))
	else
		self.AmbientSound:Stop()
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/glow04_noz")
local matGlow2 = Material("Sprites/light_glow02_add_noz")
local colGateChaos = Color(255, 30, 30, 255)
local colGateNormal = Color(10, 180, 255, 255)
function ENT:DrawTranslucent()
	if MySelf:IsValid() and MySelf:IsGhost() then
		local colGate
		if self:IsChaos() then
			colGate = colGateChaos
		else
			colGate = colGateNormal
		end

		local pos = self:LocalToWorld(self:OBBCenter())
		local maxs = self:OBBMaxs()
		local width = maxs.x * 2
		local height = maxs.z * 2

		local sin = math.sin(CurTime())

		render.SetMaterial(matGlow)
		render.DrawSprite(pos, width + sin * 16, height + sin * 64, colGate)
		render.SetMaterial(matGlow2)
		render.DrawSprite(pos, width, height, colGate)

		if DYNAMICLIGHTING then
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.Pos = pos
				dlight.r = colGate.r
				dlight.g = colGate.g
				dlight.b = colGate.b
				dlight.Brightness = 5
				local size = 128 + math.abs(sin) * 64
				dlight.Size = size
				dlight.Decay = size * 3
				dlight.DieTime = CurTime() + 1
			end
		end
	end
end
