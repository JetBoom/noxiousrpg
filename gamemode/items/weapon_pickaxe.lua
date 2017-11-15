ITEM.Base = "weaponbase"

ITEM.Name = "pickaxe"
ITEM.Model = Model("models/weapons/w_crowbar.mdl")
ITEM.Mass = 10
ITEM.SWEP = ITEMNAME
ITEM.PhysMaterial = "wood"
ITEM.BaseDamage = 10

SWEP.SoundSet = SOUNDSET_MELEE_AXE_2

SWEP.DamageType = DMGTYPE_BASHING
SWEP.IsPickaxe = true

RegisterItemWeapon(nil, nil, "weapon__base_melee")
RegisterItemWeaponStatus(nil, nil, nil, Vector(0.75, 0.75, 16), Angle(270, 0, 90))
