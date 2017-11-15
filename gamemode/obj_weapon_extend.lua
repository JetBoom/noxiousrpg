local meta = FindMetaTable("Weapon")
if not meta then return end

function meta:GetNextPrimaryFire()
	return self.m_NextPrimaryFire or 0
end
meta.GetNextPrimaryAttack = meta.GetNextPrimaryFire

function meta:GetNextSecondaryFire()
	return self.m_NextSecondaryFire or 0
end
meta.GetNextSecondaryAttack = meta.GetNextSecondaryFire

meta.OldSetNextPrimaryFire = meta.SetNextPrimaryFire
function meta:SetNextPrimaryFire(fTime)
	self.m_NextPrimaryFire = fTime
	self:OldSetNextPrimaryFire(fTime)
end
meta.SetNextPrimaryAttack = meta.SetNextPrimaryFire

meta.OldSetNextSecondaryFire = meta.SetNextSecondaryFire
function meta:SetNextSecondaryFire(fTime)
	self.m_NextSecondaryFire = fTime
	self:OldSetNextSecondaryFire(fTime)
end
meta.SetNextSecondaryAttack = meta.SetNextSecondaryFire

function meta:SetNextReload(fTime)
	self.m_NextReload = fTime
end

meta.AlterCastRecoveryTime = GenericWearableAlterCastRecoveryTime
meta.AlterCastTime = GenericWearableAlterCastTime

function meta:GetNextReload()
	return self.m_NextReload or 0
end

function meta:GetPrimaryAmmoCount()
	return self.Owner:GetAmmoCount(self.Primary.Ammo) + self:Clip1()
end

function meta:GetSecondaryAmmoCount()
	return self.Owner:GetAmmoCount(self.Secondary.Ammo) + self:Clip2()
end

function meta:SetupForWeaponStatus()
	if self:UseWeaponStatus() then
		self:HideViewAndWorldModel()
	end
end

function meta:HideViewAndWorldModel()
	self:HideViewModel()
	self:HideWorldModel()
end
meta.HideWorldAndViewModel = meta.HideViewAndWorldModel

if SERVER then
	function meta:HideWorldModel()
		self:DrawShadow(false)
	end

	function meta:HideViewModel()
	end
end

if CLIENT then
	local function empty() end
	local function NULLViewModelPosition(self, pos, ang)
		return pos + ang:Forward() * -256, ang
	end
	function meta:HideWorldModel()
		self:DrawShadow(false)
		self.DrawWorldModel = empty
		self.DrawWorldModelTranslucent = empty
	end
	function meta:HideViewModel()
		self.GetViewModelPosition = NULLViewModelPosition
	end
end

function meta:UseWeaponStatus()
	return scripted_ents.GetStored("status_"..self:GetClass())
end

function meta:GiveWeaponStatus()
	if self.Owner and self.Owner:IsValid() and self:UseWeaponStatus() then
		local class = self:GetClass()
		self.Owner:RemoveStatus("weapon_*", false, true, class)
		self.Owner:GiveStatus(class)
	end
end

function meta:RemoveWeaponStatus()
	if self.Owner and self.Owner:IsValid() then
		self.Owner:RemoveStatus(self:GetClass(), false, true)
	end
end

function meta:IsSharp()
	local damagetype = self:GetDamageType()
	return damagetype == DMGTYPE_SLASHING or damagetype == DMGTYPE_PIERCING
end

function meta:IsBlunt()
	return self:GetDamageType() == DMGTYPE_BASHING
end

function meta:GetDamage(...)
	stat.Start(self.GetBaseMeleeDamage and self:GetBaseMeleeDamage(...) or 1)
		self.Owner:StatusWeaponHook("GetMeleeDamage", self, ...)
	return stat.End()
end

function meta:GetDamageType(...)
	stat.Start(self.GetBaseMeleeDamageType and self:GetBaseMeleeDamageType(...) or DMGTYPE_SLASHING)
		self.Owner:StatusWeaponHook("GetMeleeDamageType", self, ...)
	return stat.End()
end

if SERVER then
function meta:CastSpellEnchantments(flags, target, attacker, ...)
	local item = self:GetItem()
	if item and item.SpellEnchantments then
		self.Owner:SetSkillLocked(true)

		local shouldupdate
		for i, enchantment in pairs(item.SpellEnchantments) do
			if enchantment.Spell and bit.band(enchantment.Flags, flags) == flags and (not enchantment.Charges or enchantment.Charges > 0) and SPELLS[enchantment.Spell] and (not enchantment.Chance or math.Rand(0, 100) <= enchantment.Chance) then
				local tocaston
				if enchantment.Target then
					if enchantment.Target == SPELLENCHANT_TARGET_SELF then
						tocaston = self.Owner
					elseif enchantment.Target == SPELLENCHANT_TARGET_ATTACKER then
						tocaston = attacker
					elseif enchantment.Target == SPELLENCHANT_TARGET_TARGET then
						tocaston = target
					end
				--else
					--tocaston = target or attacker or self
				end

				--if tocaston then
					CastSpell(self.Owner, SPELLS[enchantment.Spell], true, true, true, tocaston, ...)
					if enchantment.Charges then
						enchantment.Charges = enchantment.Charges - 1
						shouldupdate = true
					end
				--end
			end
		end

		if shouldupdate then
			item:Syncronize()
		end

		self.Owner:SetSkillLocked(false)
	end
end
end
if CLIENT then
function meta:CastSpellEnchantments(flags, target, attacker, ...)
end
end

function meta:GetSwingData(pl, ...)
	local radius = self.GetMeleeRadius and self:GetMeleeRadius(...) or self.MeleeRadius or 16
	return pl:MultipleTraceHull(self.GetMeleeRange and self:GetMeleeRange(...) or self.MeleeRange or 50, MASK_SOLID, radius, radius)
	--return ents.FindInSphere(pl:EyePos() + pl:GetAimVector() * (self.GetMeleeRange and self:GetMeleeRange(...) or 32), self.GetMeleeRadius and self:GetMeleeRadius(...) or 32)
end

function meta:GenericMeleeHit(ent, damage, damagetype, hitdata, ...)
	if ent.HitByMelee then
		ent:HitByMelee(self.Owner, self, damage, damagetype, hitdata, ...)
	end

	ent:TakeSpecialDamage(damage, damagetype, self.Owner, self)

	self:CastSpellEnchantments(SPELLENCHANT_EFFECT_ONSTRIKE, ent)

	if ent.CallCastSpellEnchantments then
		ent:CallCastSpellEnchantments(SPELLENCHANT_EFFECT_ONSTRUCK, nil, self.Owner)
	end

	if self.Skill and ent.TotalSkill and gamemode.Call("PlayerShouldSkillUp", self.Owner, ent) then
		gamemode.Call("PlayerUseSkill", self.Owner, self.Skill, self.Owner:GetHostileSkillUpDifficulty(ent))
	end
end

function meta:GenericMeleeGuard(attacker, wep, damage, damagetype, hitdata, ...)
	attacker:HostileAction(self.Owner)

	local effectdata = EffectData()
		effectdata:SetEntity(self.Owner)
		effectdata:SetOrigin(self.Owner:EyePos())
		effectdata:SetMagnitude(damage)
		effectdata:SetScale(damagetype)
	util.Effect("meleeguard", effectdata)

	self:CastSpellEnchantments(SPELLENCHANT_EFFECT_ONGUARD, nil, attacker)
end

meta.ProcessDamage = GenericWearableProcessDamage
