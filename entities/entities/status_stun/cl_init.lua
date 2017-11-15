include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBoundsNumber(72)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	local owner = self:GetOwner()
	owner.Stunned = self
end

function ENT:OnRemove()
	self.Emitter:Finish()

	local owner = self:GetOwner()
	if owner.Stunned == self then
		owner.Stunned = nil
	end

	if owner:IsValid() then
		owner:SetPoseParameter("head_roll", 0)
	end
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then self:SetPos(owner:EyePos()) end
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	ent:SetPoseParameter("head_roll", math.sin(CurTime()*5) * 10)

	if ent:GetVisibility() < 180 then return end

	local pos

	if ent == MySelf then
		pos = ent:GetPos() + Vector(0,0,72)
	else
		local attach = ent:GetAttachment(ent:LookupAttachment("eyes"))
		if not attach then return end
		pos = attach.Pos + Vector(0,0,16)
	end

	local rot = RealTime() * 240
	local emitter = self.Emitter
	for i=rot, 359 + rot, 120 do
		local ang = Angle(0, 0, 0)
		ang:RotateAroundAxis(Vector(0, 0, 1), i)
		local pos2 = pos + ang:Forward() * 8
		render.SetMaterial(matGlow)
		render.DrawSprite(pos2, 3.5, 3.5, COLOR_YELLOW)
		local particle = emitter:Add("sprites/glow04_noz", pos2)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetDieTime(0.25)
		particle:SetStartAlpha(254)
		particle:SetEndAlpha(50)
		particle:SetStartSize(4)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, 255, 0)
		particle:SetAirResistance(50)
	end
end
