ITEM.DataIndex = 47

ITEM.Base = "weaponbase"

ITEM.Name = "practice sword"
ITEM.Model = Model("Models/nayrbarr/Sword/Sword.mdl")
ITEM.Mass = 10
ITEM.SWEP = ITEMNAME
ITEM.PhysMaterial = "wood"
ITEM.BaseDamage = 2

RegisterItemWeapon(nil, nil, "weapon__base_melee")
RegisterItemWeaponStatus(nil, nil, nil, Vector(0.75, 0.75, 16), Angle(270, 0, 90))

resource.AddFile("Models/nayrbarr/Sword/Sword.mdl")
resource.AddFile("Materials/nayrbarr/Sword/Blade.vmt")
resource.AddFile("Materials/nayrbarr/Sword/Blade.vtf")
resource.AddFile("Materials/nayrbarr/Sword/Counter weight.vmt")
resource.AddFile("Materials/nayrbarr/Sword/Counter weight.vtf")
resource.AddFile("Materials/nayrbarr/Sword/Guard.vmt")
resource.AddFile("Materials/nayrbarr/Sword/Guard.vtf")
resource.AddFile("Materials/nayrbarr/Sword/Handle.vmt")
resource.AddFile("Materials/nayrbarr/Sword/Handle.vtf")
