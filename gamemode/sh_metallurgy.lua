METAL_IRON = 0
METAL_COPPER = 1

metal = {}

metal.DefaultNodeModels = {
Model("models/props_wasteland/rockcliff01b.mdl"),
Model("models/props_wasteland/rockcliff01c.mdl"),
Model("models/props_wasteland/rockcliff01e.mdl"),
Model("models/props_wasteland/rockcliff01f.mdl"),
Model("models/props_wasteland/rockcliff01J.mdl"),
Model("models/props_wasteland/rockcliff01k.mdl")
}

-- Real metals based on stuff from Wikipedia.

metal.Types = {}
metal.Types[METAL_IRON] = {Name = "iron", Color = Color(190, 190, 190), Mass = 8}
metal.Types[METAL_COPPER] = {Name = "copper", Color = Color(200, 135, 110), Mass = 9}

function metal.BuildMetalInformation(contents)
	local r, g, b, a = 0, 0, 0, 0
	local mass = 0
	local count = 0

	for metaltype, amount in pairs(contents) do
		count = count + amount

		local metaltab = metal.Types[metaltype]
		if metaltab then
			local metalcolor = metaltab.Color
			mass = mass + metaltab.Mass * amount
			r = r + metalcolor.r * amount
			b = b + metalcolor.g * amount
			g = g + metalcolor.b * amount
			a = a + metalcolor.a * amount
		end
	end

	count = math.max(count, 1)
	return {Mass = math.max(1, math.ceil(mass)), Color = Color(r / count, g / count, b / count, a / count), Material = ""}
end
