AddCSLuaFile("shared.lua")

STATE_MELEE_NEUTRAL = 0 -- Doing nothing
STATE_MELEE_SWINGING = 1 -- Actually swinging.
STATE_MELEE_BLOCKING = 2 -- Blocking. This has no wind-up time.
STATE_MELEE_BLOCKED = 3 -- Our attack was blocked and we're in a short stunned state where we should only have enough time to block.
STATE_MELEE_WAIT = 4
STATE_MELEE_SWUNG = STATE_MELEE_WAIT

--[[ TODO:
Replace boring directional system with Thief style melee.
4 directions to attack. Faster than current system.
You can hold block to block but you must face the direction swings are coming from to block swings.
You can also hit block immediately as you would get hit to not need to face the direction.
]]

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Secondary.Automatic = true

SWEP.BaseDamage = 10

SWEP.Skill = SKILL_BLADES

SWEP.DamageType = DMGTYPE_SLASHING

SWEP.AnimationGroup = "melee_1h"
SWEP.HoldType = "melee"

SWEP.SoundSet = SOUNDSET_MELEE_SHARP_1

SWEP.AutoRange = true

SWEP.SwingTime = 0.625
SWEP.SwingSoundTime = 0.4
SWEP.AnimationSwingTime = SWEP.SwingTime

local function GetRange(self)
	if self:IsValid() then
		self.MeleeRange = self:OBBMins():Distance(self:OBBMaxs())
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetupForWeaponStatus()

	if self.AutoRange and not self.MeleeRange then
		timer.Simple(0, GetRange, self)
	end
end

function SWEP:PrimaryAttack()
	if not self.Owner:IsIdle() then return end

	self:Swing()
end

function SWEP:SecondaryAttack()
	if not self.Owner:IsIdle(true) then return end

	self:StartBlocking()
end

function SWEP:Reload()
end

function SWEP:Think()
	local state = self:GetState()

	if state == STATE_MELEE_NEUTRAL or state == STATE_MELEE_BLOCKED then
		local owner = self.Owner
		local newdir
		if owner:KeyDown(IN_MOVELEFT) then
			if not owner:KeyDown(IN_MOVERIGHT) then
				newdir = DIRECTION_LEFT
			end
		elseif owner:KeyDown(IN_MOVERIGHT) then
			if not owner:KeyDown(IN_MOVELEFT) then
				newdir = DIRECTION_RIGHT
			end
		elseif owner:KeyDown(IN_FORWARD) then
			if not owner:KeyDown(IN_BACK) then
				newdir = DIRECTION_UP
			end
		elseif owner:KeyDown(IN_BACK) then
			if not owner:KeyDown(IN_FORWARD) then
				newdir = DIRECTION_DOWN
			end
		end

		if newdir and self:GetDirection() ~= newdir then
			self:SetDirection(newdir)
		end
	elseif self:IsBlocking() and not self.Owner:KeyDown(IN_ATTACK2) then
		self:StopBlocking()
	elseif state == STATE_MELEE_SWINGING then
		if self.m_SwingSoundTime and CurTime() >= self.m_SwingSoundTime then
			self.m_SwingSoundTime = nil
			self:EmitSoundSet(self.SoundSet, SOUNDSUBSET_MELEE_SWING)
		end
		if CurTime() >= self:GetStateEndTime() then
			self:Swung()
		end
	elseif state == STATE_MELEE_SWUNG then
		if CurTime() >= self:GetStateEndTime() then
			self:SetState(STATE_MELEE_NEUTRAL)
		end
	end

	self:NextThink(CurTime())
	return true
end

function SWEP:GetSwingTime()
	local swingtime = self.SwingTime
	local multiplier = 1

	local item = self:GetItem()
	if item then
		swingtime = item.SwingTime or swingtime

		if item.SwingTimeMultiplier then
			multiplier = item.SwingTimeMultiplier
			swingtime = swingtime * multiplier
		end
	end

	stat.Start(swingtime)
	self.Owner:StatusHook("AlterSwingTime")
	return stat.End(), multiplier
end

function SWEP:Swing()
	local swingtime, multiplier = self:GetSwingTime()

	self.m_SwingSoundTime = CurTime() + self.SwingSoundTime * multiplier
	self:SetState(STATE_MELEE_SWINGING)
	self:SetStateEndTime(CurTime() + swingtime)

	self.Owner:ResetLuaAnimation(self.AnimationGroup.."_swing"..self:GetDirection(), nil, nil, self.AnimationSwingTime / swingtime)
	--self:EmitSoundSet(self.SoundSet, SOUNDSUBSET_MELEE_SWING)
end

function SWEP:Swung()
	self:SetState(STATE_MELEE_SWUNG)

	self.Owner:LagCompensation(true)
	self.Owner:MeleeAttack(self)
	self.Owner:LagCompensation(false)

	self:SetStateEndTime(CurTime() + 0.7)
end

function SWEP:StopAnimations(time)
	self.Owner:StopLuaAnimationGroup(self.AnimationGroup, time or 0.2)
end

function SWEP:Deploy()
	self:SetState(STATE_MELEE_NEUTRAL)
	self:SetDirection(DIRECTION_UP)

	self:GiveWeaponStatus()
	return true
end

function SWEP:Holster()
	if self:CanHolster() then
		self:StopAnimations(0)
		return true
	end

	return false
end

function SWEP:OnRemove()
	local owner = self.Owner
	if owner and owner:IsValid() then
		self:StopAnimations(0)
	end
	self:RemoveWeaponStatus()
end

function SWEP:CanHolster()
	return self.Owner:IsIdle()
end

function SWEP:ShouldGuardAgainst(attacker, wep, damage, damagetype, hitdata, ...)
	return self:GetState() == STATE_MELEE_BLOCKING and self.Owner:IsFacing(attacker:EyeLevelPos()) and (not wep or not wep.GetDirection or math.abs(self:GetDirection() - wep:GetDirection()) % 2 == 0)
	--return self:GetState() == STATE_MELEE_BLOCKING and self.Owner:IsFacing(attacker:EyeLevelPos())
end

function SWEP:GetBaseMeleeDamage(state)
	local damage = self.BaseDamage
	local item = self:GetItem()
	if item then
		damage = item.BaseDamage or damage

		if item.MeleeDamageMultiplier then
			damage = damage * item.MeleeDamageMultiplier
		end
	end

	return damage * self.Owner:GetStrengthDamageMultiplier() * self.Owner:GetSkillDamageMultiplier(self.Skill)
end

function SWEP:StartBlocking()
	self:SetState(STATE_MELEE_BLOCKING)
	self:StopAnimations()
	self.Owner:ResetLuaAnimation(self.AnimationGroup.."_block"..self:GetDirection())
end

function SWEP:StopBlocking()
	if self:IsBlocking() then
		self:SetState(STATE_MELEE_WAIT)
		self:SetStateEndTime(CurTime() + 0.25)
		self:StopAnimations()
	end
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
	self:SetState(STATE_MELEE_WAIT)
	self:SetStateEndTime(CurTime() + 0.45)
	self:StopAnimations(0.45)
end

function SWEP:Move(move)
	if self:GetState() == STATE_MELEE_BLOCKING then
		move:SetForwardSpeed(move:GetForwardSpeed() * 0.6)
		move:SetSideSpeed(move:GetSideSpeed() * 0.6)
	elseif self:GetState() == STATE_MELEE_BLOCKED then
		move:SetForwardSpeed(move:GetForwardSpeed() * 0.3)
		move:SetSideSpeed(move:GetSideSpeed() * 0.3)
	end
end

function SWEP:IsIdle(fromblock)
	if fromblock and self:GetState() == STATE_MELEE_SWINGING then
		return true
	end

	return self:GetState() == STATE_MELEE_NEUTRAL and self:GetNextPrimaryAttack() <= CurTime()
end

function SWEP:GetBaseMeleeDamageType()
	return self.DamageType
end

function SWEP:MeleeHit(ent, damage, damagetype, hitdata, state)
	if ent:IsCharacter() then
		self:EmitSoundSet(self.SoundSet, SOUNDSUBSET_MELEE_HIT_FLESH)

		if SERVER then
			ent:BloodSpray(ent:NearestPoint(self.Owner:EyePos()), damage, self.Owner:GetForward(), damage * 10)
		end
	else
		local subset = soundset.GetMaterialSubSet(hitdata.MatType)
		if subset then
			self:EmitSoundSet(self.SoundSet, subset)
		end
	end
end

function SWEP:OnHitWorld(damage, damagetype, hitdata, state)
	local subset = soundset.GetMaterialSubSet(hitdata.MatType)
	if subset then
		self:EmitSoundSet(self.SoundSet, subset)
		--[[local snd = soundset.Get(self.SoundSet, subset)
		if snd and #snd > 0 then
			WorldSound(snd, hitdata.HitPos + hitdata.HitNormal, 75, math.Rand(95, 105))
		end]]
	end
end

function SWEP:SetState(state)
	self:SetDTInt(0, state)
end

function SWEP:GetState()
	return self:GetDTInt(0)
end

function SWEP:SetStateEndTime(time)
	self:SetDTFloat(0, time)
end

function SWEP:GetStateEndTime()
	return self:GetDTFloat(0)
end

function SWEP:SetDirection(dir)
	self:SetDTInt(1, dir)
end

function SWEP:GetDirection()
	return self:GetDTInt(1)
end

function SWEP:IsBlocking()
	return self:GetState() == STATE_MELEE_BLOCKING
end
SWEP.IsGuarding = SWEP.IsBlocking

local blockvert = {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = -18,
					RR = 31,
					RF = 12
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 21,
					RR = -12
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = -93,
					RF = -62
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -57,
					RR = -1,
					RF = -23
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -5,
					RR = -31,
					RF = -44
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 24
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -25
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 62,
					RF = -5
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	TimeToArrive = 0.2,
	Group = "melee_1h"
}
RegisterLuaAnimation('melee_1h_block'..DIRECTION_RIGHT, blockvert)
RegisterLuaAnimation('melee_1h_block'..DIRECTION_LEFT, blockvert)

RegisterLuaAnimation('melee_1h_block'..DIRECTION_UP, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 6,
					RR = 10,
					RF = -38
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 23,
					RR = -34
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -61,
					RR = 25
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 43
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	TimeToArrive = 0.2,
	Group = "melee_1h"
})

RegisterLuaAnimation('melee_1h_block'..DIRECTION_DOWN, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 26,
					RF = -19
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 44,
					RR = -79
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 4,
					RR = -50
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -12,
					RR = -2,
					RF = -138
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	TimeToArrive = 0.2,
	Group = "melee_1h"
})

--[[RegisterLuaAnimation('melee_1h_block'..DIRECTION_RIGHT, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -37,
					RR = -25,
					RF = -56
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RR = -65
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 51,
					RR = -47
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	TimeToArrive = 0.2,
	Group = "melee_1h"
})

RegisterLuaAnimation('melee_1h_block'..DIRECTION_LEFT, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 17,
					RR = 15
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 46,
					RR = -32,
					RF = -32
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -43,
					RR = -63,
					RF = -54
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 34,
					RR = 43,
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 2,
					RR = -20,
					RF = 6
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 66
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 10,
					RR = -32,
					RF = -54
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -7,
					RR = 48,
					RF = -5
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	TimeToArrive = 0.2,
	Group = "melee_1h"
})]]

local verticalswanim = {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = -5
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -86,
					RR = -14
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 1,
					RR = -13,
					RF = 36
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -28,
					RR = 7,
					RF = 62
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 27,
					RF = 10
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -15,
					RF = -6
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 57
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -5,
					RF = -26
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 42
				}
			},
			FrameRate = 2
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = 16,
					RR = -4,
					RF = -14
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 6,
					RR = -92,
					RF = -94
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 17,
					RR = 15,
					RF = -33
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -12,
					RR = -58
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 18
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 91
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 27
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 30
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 19,
					RR = 25
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RU = 16,
					RR = -4,
					RF = 7
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 6,
					RR = -92,
					RF = -94
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 17,
					RR = 9,
					RF = -33
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -12,
					RR = -58
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 91
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 8
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 23
				}
			},
			FrameRate = 2.5
		},
		{
			BoneInfo = {},
			FrameRate = 4
		}
	},
	Type = TYPE_GESTURE,
	Group = "melee_1h"
}
RegisterLuaAnimation('melee_1h_swing'..DIRECTION_UP, verticalswanim)
RegisterLuaAnimation('melee_1h_swing'..DIRECTION_DOWN, verticalswanim)

RegisterLuaAnimation('melee_1h_swing'..DIRECTION_LEFT, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Head1'] = {
					RF = 38
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -11,
					RF = 51
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 71
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -29
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -9
				}
			},
			FrameRate = 2
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RF = 11
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -101,
					RR = -62,
					RF = -31
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -54
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -46,
					RR = -3,
					RF = 88
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 18
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 45,
					RR = 57,
					RF = 1
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 35
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RF = 11
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -101,
					RR = -62,
					RF = -31
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -54
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -46,
					RR = -3,
					RF = 88
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 18
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 35
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 45,
					RR = 57,
					RF = 1
				}
			},
			FrameRate = 2.5
		},
		{
			BoneInfo = {},
			FrameRate = 4
		}
	},
	Type = TYPE_GESTURE,
	Group = "melee_1h"
})

RegisterLuaAnimation('melee_1h_swing'..DIRECTION_RIGHT, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RF = 16
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -59,
					RR = -28,
					RF = -70
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -72
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = -34
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 37
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 22
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 25
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 46
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -2,
					RR = 33,
					RF = 23
				}
			},
			FrameRate = 2
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -12,
					RF = -48
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = 13
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 20,
					RR = -21,
					RF = -79
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 22
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -7
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -4
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 40,
					RR = 33,
					RF = -7
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 66,
					RF = 21
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -12,
					RF = -48
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = 13
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 20,
					RR = -21,
					RF = -79
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 22
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -7
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -4
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 66,
					RF = 21
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 40,
					RR = 33,
					RF = -7
				}
			},
			FrameRate = 2.5
		},
		{
			BoneInfo = {},
			FrameRate = 4
		}
	},
	Type = TYPE_GESTURE,
	Group = "melee_1h"
})