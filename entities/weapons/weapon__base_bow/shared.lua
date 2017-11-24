AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

STATE_BOW_NEUTRAL = 0
STATE_BOW_DRAWING = 1
STATE_BOW_HOLDING = 2

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.IsBow = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
SWEP.Primary.Delay = 0.5

SWEP.HoldType = "melee"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetupForWeaponStatus()
end

function SWEP:PrimaryAttack()
	if self:GetState() ~= STATE_BOW_NEUTRAL or CurTime() < self:GetNextPrimaryFire() or not self.Owner:IsIdle() then return end

	if not (self:GetItem() and self:GetItem().MagicAmmunition) and not self.Owner:HasItem("arrow") then
		if SERVER then
			self.Owner:SendMessage("You don't have any arrows to fire!", "COLOR_RED")
		end

		return
	end

	stat.Start(self:GetBaseDrawTime())
		self.Owner:StatusWeaponHook0("AlterDrawTime")
	self:SetDrawEnd(CurTime() + stat.Get())

	self:SetState(STATE_BOW_DRAWING)

	self:NextThink(CurTime())

	self:EmitSound("nox/bow_takearrow0"..math.random(1, 4)..".wav")
	--self.Owner:ResetLuaAnimation("bow_drawarrow")
end

function SWEP:SecondaryAttack()
	if self:GetState() == STATE_BOW_HOLDING then
		self.Owner:StopLuaAnimation("bow_holdarrow", 0.2)
		self:SetChargeStart(0)
		self:SetState(STATE_BOW_NEUTRAL)
		self:SetNextPrimaryAttack(CurTime() + 0.05)
		self:NextThink(CurTime())
	end
end

function SWEP:Reload()
end

function SWEP:Think()
	if self:GetState() == STATE_BOW_HOLDING then
		if not self.Owner:KeyDown(IN_ATTACK) then
			self:LaunchArrow()
			self:SetState(STATE_BOW_NEUTRAL)
		end

		self:NextThink(CurTime())
		return true
	elseif self:GetState() == STATE_BOW_DRAWING then
		if self:GetDrawEnd() <= CurTime() then
			self:SetChargeStart(self:GetDrawEnd())
			self:SetState(STATE_BOW_HOLDING)

			self:EmitSound("nox/bow_start0"..math.random(1, 2)..".wav")
			self.Owner:ResetLuaAnimation("bow_holdarrow")
		end

		self:NextThink(CurTime())
		return true
	end
end

function SWEP:Deploy()
	self:GiveWeaponStatus()
	self.Owner:ResetLuaAnimation("bow_idle")
	return true
end

function SWEP:Holster()
	if self:CanHolster() then
		local owner = self.Owner
		if owner and owner:IsValid() then
			owner:StopLuaAnimationGroup("bow", 0.2)
			owner:StopLuaAnimation("bow_idle", 0.2)
		end
		self:RemoveWeaponStatus()
		return true
	end

	return false
end

function SWEP:OnRemove()
	local owner = self.Owner
	if owner and owner:IsValid() then
		owner:StopLuaAnimationGroup("bow", 0.2)
		owner:StopLuaAnimation("bow_idle", 0.2)
	end
	self:RemoveWeaponStatus()
end

function SWEP:CanHolster()
	return self.Owner:IsIdle()
end

function SWEP:IsIdle()
	return self:GetState() == STATE_BOW_NEUTRAL and self:GetNextPrimaryAttack() <= CurTime()
end

function SWEP:PlayerKnockedDown(status, exists, dietime)
	self:HitReset()
end

function SWEP:OwnerHitByMelee(attacker, attackerwep, damage, damagetype, hitdata, ...)
	if damage > 5 then
		self:HitReset()
	end
end

function SWEP:HitReset()
	self:SetState(STATE_BOW_NEUTRAL)
	self:SetChargeStart(0)
	self:SetNextPrimaryAttack(CurTime() + 0.1)
	self.Owner:StopLuaAnimationGroup("bow", 0.2)
end

function SWEP:Move(move)
	if not self:IsIdle() then
		move:SetSideSpeed(move:GetSideSpeed() * 0.75)
		move:SetForwardSpeed(move:GetForwardSpeed() * 0.75)
	end
end

function SWEP:LaunchArrow(dontshoot)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local owner = self.Owner

	local item = self:GetItem()

	self.Owner:StopLuaAnimation("bow_holdarrow", 0.2)
	--self.Owner:ResetLuaAnimation("bow_launcharrow")

	local charge = self:GetCharge()
	self:SetChargeStart(0)

	if not (item and item.MagicAmmunition) then
		if not self.Owner:HasItem("arrow") then return end

		self.Owner:TakeItem("arrow", 1, true)
	end

	self:EmitSound("nox/bow_end.wav")

	if CLIENT then return end

	local ent = ents.Create("projectile_arrow")
	if ent:IsValid() then
		ent:SetOwner(owner)
		local ang = owner:EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ent:SetAngles(ang)
		ent:SetPos(owner:NewEyePos() - owner:GetAimVector() * 4)
		ent:Spawn()

		ent:SetSkillLevel(owner:GetSkill(SKILL_STRENGTH))
		ent.ProjectileDamage = item and item.ProjectileDamage or ent.ProjectileDamage
		ent:SetCharge(charge)
		owner:GlobalHook("PlayerCreatedArrowProjectile", ent, self)

		local variance = (SKILLS_MAX - owner:GetSkill(SKILL_BOWS)) * SKILLS_RMAX
		if variance > 0 then
			ang:RotateAroundAxis(ang:Up(), variance * math.Rand(-4, 4))
			ang:RotateAroundAxis(ang:Right(), variance * math.Rand(-4, 4))
		end
		ent:Launch(ang:Forward())
		owner:GlobalHook("PlayerLaunchedArrowProjectile", ent, self)

		ent.Bow = self

		self:CastSpellEnchantments(SPELLENCHANT_EFFECT_ONARROWRELEASE)
	end
end

function SWEP:PlayerCreatedArrowProjectile(ent, wep)
	local item = self:GetItem()
	if item then
		if item.ProjectileDamageMultiplier and ent.ProjectileDamage then
			ent.ProjectileDamage = ent.ProjectileDamage * item.ProjectileDamageMultiplier
		end
		if item.ProjectileSpeedMultiplier and ent.ProjectileSpeed then
			ent.ProjectileSpeed = ent.ProjectileSpeed * item.ProjectileSpeedMultiplier
		end
	end
end

function SWEP:SetState(state)
	self:SetDTInt(0, state)
end

function SWEP:GetState()
	return self:GetDTInt(0)
end

function SWEP:GetDrawEnd()
	return self:GetDTFloat(0)
end

function SWEP:SetDrawEnd(tim)
	self:SetDTFloat(0, tim)
end

function SWEP:SetChargeStart(tim)
	self:SetDTFloat(1, tim)
end

function SWEP:GetChargeStart()
	return self:GetDTFloat(1)
end

function SWEP:AlterDrawTime()
	local item = self:GetItem()
	if item and item.DrawTimeMultiplier then
		stat.Mul(item.DrawTimeMultiplier)
	end
end

function SWEP:GetBaseDrawTime()
	return 1.25 - math.min(SKILLS_MAX * 0.5, self.Owner:GetSkill(SKILL_DEXTERITY) * SKILLS_RMAX * 0.5)
end

function SWEP:GetCharge()
	local chargestart = self:GetChargeStart()
	if chargestart == 0 then return 0 end

	local item = self:GetItem()
	return math.Clamp((CurTime() - chargestart) * (item and item.ChargeMultiplier or 1), 0, 1)
end

function SWEP:SetCharge(charge)
	self:SetChargeStart(CurTime() - charge)
end

RegisterLuaAnimation("bow_idle", {
	FrameData = {
		{
			BoneInfo = {
				["ValveBiped.Bip01_R_Forearm"] = {
					RU = 20
				},
				["ValveBiped.Bip01_R_Upperarm"] = {
					RF = -120,
					RR = -80
				}
			},
			FrameRate = 5
		}
	},
	TimeToArrive = 0.2,
	Type = TYPE_POSTURE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		local wep = pl:GetActiveWeapon()
		return wep:IsValid() and wep.IsBow
	end
})

RegisterLuaAnimation("bow_holdarrow", {
	FrameData = {
		{
			BoneInfo = {
				["ValveBiped.Bip01_L_Upperarm"] = {
					RF = -40,
					RU = -40,
					RR = -40
				},
				["ValveBiped.Bip01_L_Forearm"] = {
					RU = 70,
					RF = 0
				},
				["ValveBiped.Bip01_L_Hand"] = {
					RU = -30
				},
				["ValveBiped.Bip01_R_Upperarm"] = {
					RR = -20,
					RF = 39
				},
				["ValveBiped.Bip01_R_Forearm"] = {
					RU = -20
				}
			},
			FrameRate = 4
		}
	},
	TimeToArrive = 0.2,
	Type = TYPE_POSTURE,
	Group = "bow",
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		local wep = pl:GetActiveWeapon()
		return wep:IsValid() and wep.IsBow and wep:GetState() == STATE_BOW_HOLDING
	end
})
