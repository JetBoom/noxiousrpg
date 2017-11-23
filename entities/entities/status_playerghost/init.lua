AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() and owner:KeyPressed(IN_ATTACK) then
		self:SetPublicVisible(not self:GetPublicVisible())
	end

	self:NextThink(CurTime())
	return true
end
ENT._Think = ENT.Think

function ENT:DelayedPlayerSet()
	if CurTime() >= self.m_Delay then
		self.m_Delay = nil
		self.Think = self._Think

		local owner = self:GetOwner()
		if owner:IsValid() then
			local color = owner:GetColor()
			owner:SetColor(color.r, color.g, color.b, 1)

			owner:SetSolid(SOLID_CUSTOM)
			owner:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			owner:SetDSP(16) --owner:SetDSP(56)
			owner:SetNoTarget(true)
			owner:SetMaterial("models/debug/debugwhite")
			owner:ResetSpeed()
		end
	end
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.m_PlayerGhost = self
	pPlayer:StripWeapons()
	local color = pPlayer:GetColor()
	pPlayer:SetColor(color.r, color.g, color.b, 1)

	self.m_Delay = CurTime() + 0.1
	self.Think = self.DelayedPlayerSet
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() and owner.m_PlayerGhost == self then
		owner.m_PlayerGhost = nil

		local color = owner:GetColor()
		owner:SetColor(color.r, color.g, color.b, 255)

		owner:SetSolid(SOLID_BBOX)
		owner:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		owner:SetDSP(0)
		owner:SetNoTarget(false)
		owner:SetMaterial()
		owner:ResetSpeed()

		owner:TemporaryNoCollide()
	end
end

function ENT:SetPublicVisible(onoff)
	if onoff ~= self:GetPublicVisible() then
		local owner = self:GetOwner()
		if owner:IsValid() then
			if onoff then
				owner:SendMessage("You are now visible to living beings.~snpc/combine_gunship/ping_search.wav", nil, true)
			else
				owner:SendMessage("You are no longer visible to living beings.~sambient/voices/squeal1.wav", nil, true)
			end
		end
	end

	self:SetDTBool(0, onoff)
end
