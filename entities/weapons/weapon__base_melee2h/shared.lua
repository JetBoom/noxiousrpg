AddCSLuaFile("shared.lua")

SWEP.Base = "weapon__base_melee"

SWEP.AnimationGroup = "melee_2h"
SWEP.HoldType = "melee2"

SWEP.SwingTime = 1.025
SWEP.SwingSoundTime = 0.85
SWEP.AnimationSwingTime = SWEP.SwingTime

RegisterLuaAnimation("melee_2h_swing"..DIRECTION_RIGHT, {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RF = -24
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 21,
					RR = -31
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 14,
					RR = -2,
					RF = 75
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 12,
					RR = 38,
					RF = 10
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -12
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 34,
					RR = -4,
					RF = 33
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = -22
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -9
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -9
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 12,
					RR = 22
				}
			},
			FrameRate = 1.1111111111111
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -6,
					RR = -3,
					RF = -21
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -84
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -58,
					RR = -6,
					RF = 56
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 26
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 27,
					RR = 14,
					RF = 48
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -1
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 44
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 27
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 79
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -12,
					RR = 11,
					RF = -23
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 54
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -6,
					RR = -3,
					RF = -21
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -84
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -58,
					RR = -6,
					RF = 56
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 26
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 27,
					RR = 14,
					RF = 48
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -1
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 44
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 27
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 54
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -12,
					RR = 11,
					RF = -23
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 79
				}
			},
			FrameRate = 2.5
		},
		{
			BoneInfo = {
			},
			FrameRate = 2.5
		}
	},
	Type = TYPE_GESTURE,
	Group = "melee_2h"
})
