ITEM.DataIndex = 11

ITEM.Base = "container_base"
ITEM.Name = "secure bank"
ITEM.Moveable = false
ITEM.MaxStack = 1

function ITEM:GetMassCapacity()
	return -1
end

if SERVER then
	function ENT:Initialize()
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
	end

	function ENT:Think()
		local pl = self.m_Player
		if not pl or not pl:IsValid() or pl:NearestPoint(self:GetPos()):Distance(self:GetPos()) >= 256 then
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
	end
end

function ITEM:IsUsableBy(pl)
	local ent = self:GetEntity()
	return ent:IsValid() and ent.m_Player == pl and ent.m_PlayerUID == pl:UniqueID()
end

function ITEM:OnContentsChanged(item)
	local ent = self:GetEntity()
	if ent:IsValid() then
		local pl = ent.m_Player
		if pl and pl:IsValid() and pl.Banks then
			pl.Banks[ent.m_Zone] = self:GetContainer()
		end
	end
end
