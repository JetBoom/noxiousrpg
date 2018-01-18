ITEM.DataIndex = 50

ITEM.Base = "wearablebase"

ITEM.Name = "chain armor set"
ITEM.Mass = 26
ITEM.WearableSlot = WEARABLE_SLOT_BODY
ITEM.BodyType = BODY_TYPE_MEDIUM

ITEM.ChargeMultiplier = 0.9
ITEM.CastTimeMultiplier = 1.2

ITEM.DamageMultipliers = {
	[DMGTYPE_CUTTING] = 0.70,
	[DMGTYPE_PIERCING] = 0.70,
	[DMGTYPE_IMPACT] = 0.75,
	[DMGTYPE_FIRE] = 0.90,
	[DMGTYPE_ENERGY] = 0.90,
	[DMGTYPE_COLD] = 0.95,
	[DMGTYPE_POISON] = 0.90
}

RegisterBodyArmor()
