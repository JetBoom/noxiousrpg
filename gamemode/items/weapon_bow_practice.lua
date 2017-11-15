ITEM.Base = "weaponbase"

ITEM.Name = "practice bow"
ITEM.Model = Model("Models/nayrbarr/Bow/bow.mdl")
ITEM.Mass = 10
ITEM.SWEP = ITEMNAME
ITEM.PhysMaterial = "wood"
ITEM.ProjectileDamage = 2

RegisterItemWeapon(nil, nil, "weapon__base_bow")
RegisterItemWeaponStatus(nil, nil, nil, Vector(-3, 2, -21), Angle(0, 220, 0), "anim_attachment_LH", Vector(0.75, 0.75, 0.75))

resource.AddFile("Models/nayrbarr/Bow/bow.mdl")
resource.AddFile("Materials/nayrbarr/Bow/BUBING_2.vmt")
resource.AddFile("Materials/nayrbarr/Bow/Leather - black.vmt")
resource.AddFile("Materials/nayrbarr/Bow/Leather-dark brown.vmt")
resource.AddFile("Materials/nayrbarr/Bow/scuffed metal.vmt")
