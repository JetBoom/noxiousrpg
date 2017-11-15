ALCHEMY_MIX_HEAL = 1
ALCHEMY_MIX_HARM = 2
ALCHEMY_MIX_REGENERATION = 3
ALCHEMY_MIX_SMOKE = 4
ALCHEMY_MIX_STONESKIN = 5

ALCHEMY_MIXES = {
	[ALCHEMY_MIX_HEAL] = {
		Name = "H0",
		Ingredient = "item_somethingorother",
		Base = 0,
		Color = Color(255, 0, 0, 255),
		CoolDown = 5
	},
	[ALCHEMY_MIX_HARM] = {
		Name = "H1",
		Ingredient = "item_somethingorother",
		Base = 1,
		Color = Color(160, 20, 0, 255),
		CoolDown = 5
	},
	[ALCHEMY_MIX_REGENERATION] = {
		Name = "R2",
		Ingredient = "item_somethingorother",
		Base = 2,
		Color = Color(255, 60, 60, 255),
		CoolDown = 5
	},
	[ALCHEMY_MIX_SMOKE] = {
		Name = "S0",
		Ingredient = "item_somethingorother",
		Base = 0,
		Color = Color(160, 160, 160, 255),
		CoolDown = 2,
		Throwable = true
	},
	[ALCHEMY_MIX_STONESKIN] = {
		Name = "S4",
		Ingredient = "item_somethingorother",
		Base = 4,
		Color = Color(120, 120, 120, 255),
		CoolDown = 5
	}
}

local function Increment(base, targetitem) return base + 1 end
ALCHEMY_BASE_MODIFIERS = {
	["item_alchemymix"] = function(base, targetitem) return base * targetitem.Base end,
	["item_somethingbasey"] = Increment
}
