include("shared.lua")

util.PrecacheSound("ambient/materials/rock1.wav")
util.PrecacheSound("ambient/materials/rock2.wav")
util.PrecacheSound("ambient/materials/rock3.wav")
util.PrecacheSound("ambient/materials/rock4.wav")
util.PrecacheSound("ambient/materials/rock5.wav")
util.PrecacheSound("physics/concrete/concrete_break2.wav")
util.PrecacheSound("physics/concrete/concrete_break3.wav")

local fleckgravity = Vector(0, 0, -600)
function ENT:OnRemove()
	local center = self:LocalToWorld(self:OBBCenter())

	WorldSound("ambient/materials/rock"..math.random(1, 5)..".wav", center)
	WorldSound("physics/concrete/concrete_break"..math.random(2, 3)..".wav", center)

	local emitter = ParticleEmitter(center)
	emitter:SetNearClip(24, 32)

	local mins, maxs = self:OBBMins(), self:OBBMaxs()

	for i=1, mins:Distance(maxs) * 4 do
		local particlepos = self:LocalToWorld(Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z)))
		local centerdist = particlepos:Distance(center)
		local magnitude = 1 - centerdist / 128

		local fleck = math.random(1, 3) == 1

		local particle = emitter:Add(fleck and "Effects/fleck_cement"..math.random(1, 2) or "particles/smokey", particlepos)
		particle:SetDieTime(magnitude * 2 * math.Rand(0.5, 1.5))
		particle:SetVelocity((1 - magnitude) * 256 * (particlepos - center):GetNormalized())
		particle:SetStartSize(1)
		particle:SetStartAlpha(math.Rand(90, 180))
		particle:SetEndAlpha(0)
		particle:SetColor(90, 90, 90)
		particle:SetLighting(true)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		if fleck then
			particle:SetEndSize(magnitude)
			particle:SetBounce(0.1)
			particle:SetCollide(true)
			particle:SetGravity(fleckgravity)
		else
			particle:SetEndSize(magnitude * 32)
			particle:SetAirResistance(256)
		end
	end

	emitter:Finish()
end
