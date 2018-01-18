ITEM.DataIndex = 51

ITEM.Base = "wearablebase"

ITEM.Name = "leather armor set"
ITEM.Mass = 18
ITEM.WearableSlot = WEARABLE_SLOT_BODY
ITEM.BodyType = BODY_TYPE_LIGHT

ITEM.DamageMultipliers = {
	[DMGTYPE_CUTTING] = 0.85,
	[DMGTYPE_PIERCING] = 0.85,
	[DMGTYPE_IMPACT] = 0.90,
	[DMGTYPE_FIRE] = 0.90,
	[DMGTYPE_ENERGY] = 0.80,
	[DMGTYPE_COLD] = 0.80,
	[DMGTYPE_POISON] = 0.90
}

RegisterBodyArmor()
