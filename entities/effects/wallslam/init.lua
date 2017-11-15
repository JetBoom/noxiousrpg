function EFFECT:Init(data)
	self.DieTime = CurTime() + 0.25

	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()

	util.Decal("Scorch", pos + normal, pos - normal)

	local ent = data:GetEntity()
	if ent and ent:IsValid() then
		local knockdown = ent.KnockedDown
		if knockdown and knockdown:IsValid() then
			--knockdown.WallFreezePos = pos + normal * 8
			knockdown.WallFreezeHitNormal = normal * -1
		end
	end

	util.Decal("Scorch", pos + normal, pos - normal)
	pos = pos + normal * 2
	self.Pos = pos
	self.Normal = normal

	--WorldSound("physics/concrete/boulder_impact_hard"..math.random(1,4)..".wav", pos, 75, math.Rand(95, 105))
	WorldSound("Breakable.MatConcrete", pos, 80, math.Rand(95, 105))

	local vBounds = Vector(6, 6, 6)
	local vNBounds = Vector(-6, -6, -6)
	for i=1, math.random(5, 8) do
		local dir = ((normal * 2 + VectorRand()) * 0.3333333):Normalize()
		local ent = ClientsideModel("models/props_junk/Rock001a.mdl", RENDERGROUP_OPAQUE)
		ent:SetPos(pos + dir * 16)
		ent:PhysicsInitBox(vNBounds, vBounds)
		ent:SetCollisionBounds(vNBounds, vBounds)
		ent:GetPhysicsObject():SetMaterial("rock")
		ent:GetPhysicsObject():ApplyForceOffset(ent:GetPos() + VectorRand() * 5, dir * math.Rand(300, 800))
		timer.Simple(math.Rand(4, 6), ent.Remove, ent)
	end

	local ang = normal:Angle()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRefraction	= Material("refract_ring")
local matRing = Material("effects/select_ring")
function EFFECT:Render()
	render.SetMaterial(matRing)
	local delta = math.max(0.001, self.DieTime - CurTime())
	local rdelta = 0.25 - delta
	local size = rdelta * 2000
	local col = Color(255, 255, 255, delta * 1000)
	--local rot = RealTime() * 360
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, col, 0)
	local negno = self.Normal * -1
	render.DrawQuadEasy(self.Pos, negno, size, size, col, 0)

	matRefraction:SetMaterialFloat("$refractamount", math.sin(delta * 2 * math.pi) * 0.2)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	--local qsiz = rdelta * 1500 + math.cos(delta * 12) * 100
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, color_white, 0)
	render.DrawQuadEasy(self.Pos, negno, size, size, color_white, 0)
end
