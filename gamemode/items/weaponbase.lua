ITEM.Name = "weapon"
ITEM.Model = Model("models/weapons/w_pistol.mdl")
ITEM.Mass = 20
ITEM.MaxStack = 1
ITEM.WearableSlot = WEARABLE_SLOT_WEAPON

if SERVER then
	function ITEM:OnUse(pl)
		print('SERVER:ITEM:OnUse', pl)
		pl:EquipItem(self)
	end

	function ITEM:OnDrop(pl)
		return gamemode.Call("PlayerDropWeapon", pl, self)
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end
end
