function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()
	local damage = data:GetMagnitude()
	local damagetype = math.Round(data:GetScale())

	self.Owner = ent
	self.Damage = damage
	self.DamageType = damagetype
	self.DieTime = CurTime() + 0.25

	WorldSound("physics/metal/metal_sheet_impact_bullet1.wav", pos, 82, math.Rand(110, 125) - math.min(damage * 0.5, 30))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(30, 40)
	local grav = Vector(0, 0, -800)
	for i = 0, math.Rand(damage * 0.75, damage * 1.25) do
		local heading = VectorRand()
		heading:Normalize()

		local particle = emitter:Add("effects/spark", pos + heading * 4)
		particle:SetVelocity(heading * math.Rand(20, 380))
		particle:SetDieTime(math.Rand(0.6, 2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(2, 8))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-90, 90))
		particle:SetBounce(0.9)
		particle:SetCollide(true)
		particle:SetGravity(grav)
	end
	emitter:Finish()
end

function EFFECT:Think()
	local ent = self.Owner
	if ent and ent:IsValid() and ent:Alive() then
		local pos
		local angpos = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
		if angpos then
			pos = angpos.Pos
		else
			pos = ent:EyePos()
		end

		self.Entity:SetPos(pos)
	end

	return CurTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ent = self.Owner
	if ent and ent:IsValid() and ent:Alive() then
		local pos
		local angpos = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
		if angpos then
			pos = angpos.Pos
		else
			pos = ent:EyePos()
		end

		render.SetMaterial(matGlow)
		local size = 32 - (self.DieTime - CurTime()) * 128
		render.DrawSprite(pos, size, size, Color(255, 255, 255, math.min(255, (self.DieTime - CurTime()) * 800)))
	end
end
