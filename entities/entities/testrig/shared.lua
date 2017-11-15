AddCSLuaFile("shared.lua")

ENT.Type = "anim"

--[[local DefaultPosAng = {
["ValveBiped"] = Angle(-0.000, 90.000, 90.000),
["ValveBiped.Bip01"] = Angle(-0.000, 90.000, 90.000),
["ValveBiped.Bip01_Pelvis"] = Angle(-0.000, 90.000, 90.000),
["ValveBiped.Bip01_L_Thigh"] = Angle(87.015, 174.253, 84.245),
["ValveBiped.Bip01_L_Calf"] = Angle(85.061, 176.535, 86.522),
["ValveBiped.Bip01_L_Foot"] = Angle(33.483, 3.000, -89.694),
["ValveBiped.Bip01_L_Toe0"] = Angle(0.000, 3.000, -90.163),
["ValveBiped.Bip01_R_Thigh"] = Angle(87.015, -174.252, 95.756),
["ValveBiped.Bip01_R_Calf"] = Angle(85.061, -176.535, 93.478),
["ValveBiped.Bip01_R_Foot"] = Angle(33.483, -3.000, -89.694),
["ValveBiped.Bip01_R_Toe0"] = Angle(0.000, -3.000, -94.405),
["ValveBiped.Bip01_Spine"] = Angle(-85.233, 180.000, 90.000),
["ValveBiped.Bip01_Spine1"] = Angle(-83.582, 180.000, 90.000),
["ValveBiped.Bip01_Spine2"] = Angle(-89.158, 179.998, 90.001),
["ValveBiped.Bip01_Spine4"] = Angle(-80.162, 0.000, -90.000),
["ValveBiped.Bip01_Neck1"] = Angle(-56.893, 0.000, 90.000),
["ValveBiped.Bip01_Head1"] = Angle(-80.100, 0.000, 90.000),
["ValveBiped.Bip01_L_Clavicle"] = Angle(16.285, 89.670, 89.907),
["ValveBiped.Bip01_L_UpperArm"] = Angle(49.713, 94.166, 3.181),
["ValveBiped.Bip01_L_Forearm"] = Angle(49.782, 88.813, -0.906),
["ValveBiped.Bip01_R_Clavicle"] = Angle(16.285, -89.670, 85.977),
["ValveBiped.Bip01_R_UpperArm"] = Angle(49.713, -94.166, 176.820),
["ValveBiped.Bip01_R_Forearm"] = Angle(49.782, -88.813, -179.094)
}]]

function ENT:Initialize()
	self:SetModel("models/test/test_rig3.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

--[[function ENT:GetOffset(bone)
	if DefaultPosAng[bone] ~= nil then
		local boneid = self:LookupBone(bone)
		local bp, ba = self:GetBonePosition(self:LookupBone(boneid))
		if ba then
			return self:WorldToLocalAngles(ba) - DefaultPosAng[bone]
		end
	end

	return Angle(0, 0, 0)
end]]

function ENT:Think()
	self:SetSequence(1)
	self:SetPlaybackRate(1)
	self:SetCycle(math.abs(math.sin(CurTime())))

	self:NextThink(CurTime())
	return true
end

function ENT:AttachTo(ent)
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())
	self:SetOwner(ent)
	self:SetParent(ent)

	gmod.BroadcastLua("Entity("..ent:EntIndex()..").m_Rig = Entity("..self:EntIndex()..")")
end
