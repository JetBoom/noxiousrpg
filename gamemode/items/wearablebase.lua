ITEM.DataIndex = 54

ITEM.Name = "wearable"
ITEM.Model = Model("models/Weapons/w_suitcase_passenger.mdl")
ITEM.Mass = 1
ITEM.MaxStack = 1
ITEM.WearableSlot = WEARABLE_HEAD

if SERVER then
	function ITEM:OnUse(pl)
		pl:EquipItem(self)
	end

	function ITEM:OnDrop(pl)
		return gamemode.Call("PlayerDropWearable", pl, self)
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end
end
