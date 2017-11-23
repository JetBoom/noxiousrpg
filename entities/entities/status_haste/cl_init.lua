include("shared.lua")

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local color = owner:GetColor()
	if a < 180 then return end

	local skill = self:GetSkillLevel()
	local pos = owner:GetPos() + Vector(0, 0, 8)
	local emitter = self.Emitter

	for i=1, math.random(1, 3) do
		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(VectorRand() * 20)
		particle:SetDieTime(math.Rand(0.7, 0.8))
		particle:SetStartAlpha(color.a)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(4 + skill * 0.075)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(skill * 2)

		local particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(VectorRand() * 20)
		particle:SetDieTime(math.Rand(0.5, 0.6))
		particle:SetStartAlpha(a)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(2 + skill * 0.05)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-60, -30))
	end
end

function ENT:OnInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:DrawShadow(false)
	self:SetRenderBoundsNumber(72)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()
end
