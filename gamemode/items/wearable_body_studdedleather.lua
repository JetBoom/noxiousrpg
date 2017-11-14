ITEM.Base = "wearablebase"

ITEM.Name = "studded leather armor"
ITEM.Mass = 20
ITEM.WearableSlot = WEARABLE_SLOT_BODY
ITEM.BodyType = BODY_TYPE_LIGHT

ITEM.DamageMultipliers = {
	[DMGTYPE_CUTTING] = 0.80,
	[DMGTYPE_PIERCING] = 0.80,
	[DMGTYPE_IMPACT] = 0.80,
	[DMGTYPE_FIRE] = 0.85,
	[DMGTYPE_ENERGY] = 0.82,
	[DMGTYPE_COLD] = 0.80,
	[DMGTYPE_POISON] = 0.90
}

RegisterBodyArmor()
