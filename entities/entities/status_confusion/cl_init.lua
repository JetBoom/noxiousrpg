include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBoundsNumber(72)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	self.Seed = math.Rand(0, 360)

	self.BaseClass.Initialize(self)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:SetPoseParameter("head_roll", 0)
	end
end

local colGlow = Color(200, 0, 255)
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	ent:SetPoseParameter("head_roll", math.sin(CurTime() * 10) * 10)

	local r, g, b, a = ent:GetColor()
	colGlow.a = a

	local ang = Angle(0, (self.Seed + CurTime()) * 360, 0)
	local startpos = ent:GetPos() + (ent:OBBMaxs().z + 8) * ent:GetUp()

	for i=1, 3 do
		ang:RotateAroundAxis(ang:Up(), 120)
		local pos = startpos + ang:Forward() * 13

		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 12, 12, colGlow)

		local particle = self.Emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(0.25)
		particle:SetStartAlpha(a)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetColor(200, 0, 255)
	end
end
