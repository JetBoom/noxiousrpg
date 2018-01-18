ITEM.DataIndex = 43

ITEM.Base = "weaponbase"

ITEM.Name = "quarter staff"
ITEM.Model = Model("models/melee/s_staff.mdl")
ITEM.Mass = 10
ITEM.SWEP = ITEMNAME
ITEM.PhysMaterial = "wood"
ITEM.ProjectileDamageMultiplier = 0.8
ITEM.ProjectileForceMultiplier = 0.8

RegisterItemWeapon(nil, nil, "weapon__base_melee2h")
RegisterItemWeaponStatus()

--[[resource.AddFile("models/melee/s_staff.mdl")
resource.AddFile("materials/melee/s_staff/saber.vmt")
resource.AddFile("materials/melee/s_staff/saber.vtf")
resource.AddFile("materials/melee/s_staff/saber1.vmt")
resource.AddFile("materials/melee/s_staff/saber1.vtf")
resource.AddFile("materials/melee/s_staff/saber3.vmt")
resource.AddFile("materials/melee/s_staff/saber3.vtf")
]]
