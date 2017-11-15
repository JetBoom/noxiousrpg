ITEM.Base = "weaponbase"

ITEM.Name = "wooden two-handed sword"
ITEM.Model = Model("Models/nayrbarr/Sword/Sword.mdl")
ITEM.Mass = 20
ITEM.SWEP = ITEMNAME
ITEM.PhysMaterial = "wood"
ITEM.BaseDamage = 16

SWEP.SoundSet = SOUNDSET_MELEE_SHARP_3

RegisterItemWeapon(nil, nil, "weapon__base_melee2h")
RegisterItemWeaponStatus(nil, nil, nil, Vector(0.75, 0.75, 16), Angle(270, 0, 90))
