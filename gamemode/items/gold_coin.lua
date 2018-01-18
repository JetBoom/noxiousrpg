ITEM.DataIndex = 19

ITEM.Model = Model("models/nayrbarr/coin/coin.mdl")
ITEM.Mass = 0.05
ITEM.MaxStack = -1
ITEM.PhysMaterial = "metal"

if CLIENT then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)

		self.Seed = math.Rand(0, 10)
	end

	local matGlow = Material("effects/yellowflare")
	function ENT:Draw()
		self.BaseClass.Draw(self)

		local size = math.sin((RealTime() + self.Seed) * 5) * 1024 - 1016
		if 0 < size then
			render.SetMaterial(matGlow)
			render.DrawSprite(self:GetPos() + EyeAngles():Forward() * -1, size, size)
		end
	end
end

resource.AddFile("models/nayrbarr/coin/coin.mdl")
resource.AddFile("Materials/nayrbarr/Coin/Coin.vmt")
