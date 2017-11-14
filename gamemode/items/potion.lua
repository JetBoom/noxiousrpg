ITEM.Name = "potion"
ITEM.Model = Model("models/props_junk/garbage_glassbottle003a.mdl")
ITEM.Mass = 1
ITEM.MaxStack = 1
ITEM.Power = 0

if SERVER then
	function ITEM:OnUse(pl)
		local mixtype = self.Mix
		if mixtype and ALCHEMY_MIX_ON_USE[mixtype] then
			ALCHEMY_MIX_ON_USE[mixtype](pl, self)
			return ITEM_ONUSE_DECREMENT
		end

		return ITEM_ONUSE_NOTHING
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end
end
