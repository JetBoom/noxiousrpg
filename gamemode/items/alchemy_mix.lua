ITEM.Name = "alchemy mix"
ITEM.DataIndex = 2

ITEM.Model = Model("models/props_junk/garbage_glassbottle003a.mdl")
ITEM.Mass = 1
ITEM.MaxStack = 1

if SERVER then
	function ITEM:OnUse(pl)
		return ITEM_ONUSE_NOTHING
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end
end
