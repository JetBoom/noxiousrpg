util.PrecacheSound("Breakable.MatConcrete")

function EFFECT:Init(data)
	self.Rocks = {}

	local pos = data:GetOrigin()
	local normal = data:GetNormal()

	util.Decal("Scorch", pos + normal, pos - normal)

 	self.vOffset = pos
	self.Normal = normal

	self.Entity:SetRenderBoundsNumber(256)

	self.DieTime = CurTime() + 1

	WorldSound("Breakable.MatConcrete", pos, 80, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	for i=1, math.random(8, 16) do
		local particle = emitter:Add("effects/smoke", pos)
		particle:SetColor(50, 50, 50, 255)
		particle:SetVelocity(VectorRand() * 80)
		particle:VelocityDecay(2)
		particle:SetDieTime(math.Rand(1, 2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 15))
		particle:SetEndSize(math.Rand(50, 100))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(100)
		particle:SetGravity(Vector(0, 0, 10))
	end

	if render.SupportsHDR() then
		for i=1, math.random(3, 6) do
			local particle = emitter:Add("particle/warp1_warp", pos)
			particle:SetVelocity(VectorRand() * 80)
			particle:VelocityDecay(10)
			particle:SetDieTime(3)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(50, 75))
			particle:SetEndSize(math.Rand(5, 30))
			particle:SetAirResistance(50)
			particle:SetRoll(math.Rand(0, 360))
		end
	end

	emitter:Finish()

	for i=1, math.random(4, 8) do
		local dir = (normal + VectorRand()):Normalize()
		local rock = ents.Create("prop_physics")
		rock:SetModel("models/props_debris/concrete_chunk05g.mdl")
		rock:SetPos(pos + dir * 8)
		rock:SetAngles(Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
		rock:Spawn()

		local scale = math.Rand(1, 5)
		rock:SetModelScale(scale, 0)
		rock:PhysicsInitBox(rock:OBBMins(), rock:OBBMaxs())  
		rock:SetCollisionBounds(rock:OBBMins(), rock:OBBMaxs())  
		rock:SetMoveType(MOVETYPE_VPHYSICS)
		rock:SetSolid(SOLID_VPHYSICS)
		self.Rocks[i] = rock
		local phys = rock:GetPhysicsObject()  
		if phys:IsValid() then  
			phys:Wake()
			phys:EnableGravity(true)
			phys:ApplyForceCenter(dir * math.Rand(8000, 24000))
		end
	end
end

function EFFECT:Think()
	if self.DieTime <= CurTime() then
		for _, rock in pairs(self.Rocks) do
			if rock:IsValid() then
				rock:Remove()
			end
		end

		return false
	end

	return true
end

local colWhite = Color(255, 255, 255, 255)
local matCrater = Material("decals/rollermine_crater")
local matWaterRipple = Material("particle/warp_ripple")
function EFFECT:Render()
	local delta = self.DieTime - CurTime()
	colWhite.a = delta

	if render.SupportsHDR() then
		local size = (1 - delta) * 512
		render.SetMaterial(matWaterRipple)
		render.DrawQuadEasy(self.vOffset, self.Normal, size, size, colWhite)
		render.DrawQuadEasy(self.vOffset, self.Normal * -1, size, size, colWhite)
	end

	render.SetMaterial(matCrater)
	render.DrawQuadEasy(self.vOffset, self.Normal, 160, 160, colWhite)
	render.DrawQuadEasy(self.vOffset, self.Normal * -1, 160, 160, colWhite)
end
