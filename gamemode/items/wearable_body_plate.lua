ITEM.DataIndex = 52

ITEM.Base = "wearablebase"

ITEM.Name = "plate armor set"
ITEM.Mass = 35
ITEM.WearableSlot = WEARABLE_SLOT_BODY
ITEM.BodyType = BODY_TYPE_HEAVY

ITEM.ChargeMultiplier = 0.8
ITEM.CastTimeMultiplier = 1.4

ITEM.DamageMultipliers = {
	[DMGTYPE_CUTTING] = 0.60,
	[DMGTYPE_PIERCING] = 0.60,
	[DMGTYPE_IMPACT] = 0.65,
	[DMGTYPE_FIRE] = 0.80,
	[DMGTYPE_ENERGY] = 0.90,
	[DMGTYPE_COLD] = 0.95,
	[DMGTYPE_POISON] = 0.90
}

RegisterBodyArmor()
