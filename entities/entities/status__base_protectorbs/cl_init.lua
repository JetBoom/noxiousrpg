include("shared.lua")

ENT.GlowMaterial1 = Material("sprites/glow04_noz")
ENT.GlowColor1 = Color(255, 255, 255)
ENT.GlowMaterial2 = ENT.GlowMaterial1
ENT.GlowColor2 = ENT.GlowColor1

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBoundsNumber(72)
	self.Seed = math.Rand(0, 10)
	self.YawSeed = math.Rand(0, 360)
end

function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	local r, g, b, a = ent:GetColor()
	if a < 90 then return end

	self.GlowColor1.a = a
	self.GlowColor2.a = a * 0.5

	local pos = ent:LocalToWorld(ent:OBBCenter())
	local radius = ent:BoundingRadius()
	local skill = self:GetSkillLevel()
	local orbsize = radius * 0.4

	local ang = Angle(0, self.YawSeed, 0)
	ang:RotateAroundAxis(ang:Right(), math.sin((RealTime() + self.Seed) * 2) * 30)
	local up = ang:Up()
	ang:RotateAroundAxis(up, RealTime() * 300)

	local numorbs = 1 + math.floor((skill / SKILLS_MAX) * 3)
	local rotation = 360 / numorbs
	for i=1, numorbs do
		ang:RotateAroundAxis(up, rotation)
		local orbpos = pos + ang:Forward() * radius
		render.SetMaterial(self.GlowMaterial1)
		render.DrawSprite(orbpos, orbsize, orbsize, self.GlowColor1)
		render.SetMaterial(self.GlowMaterial2)
		render.DrawSprite(orbpos, orbsize, orbsize, self.GlowColor1)
	end
end
