ITEM.DataIndex = 45

ITEM.Base = "weaponbase"

ITEM.Name = "haunt sword"
ITEM.Model = Model("Models/nayrbarr/Sword/Sword.mdl")
ITEM.SWEP = ITEMNAME
ITEM.BaseDamage = 21

SWEP.SoundSet = SOUNDSET_MELEE_SHARP_3

RegisterItemWeapon(nil, nil, "weapon__base_melee")
RegisterItemWeaponStatus(nil, nil, nil, Vector(0.75, 0.75, 16), Angle(270, 0, 90))
