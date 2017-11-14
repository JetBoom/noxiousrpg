ITEM.Base = "container_base"
ITEM.Name = "corpse"
ITEM.Model = "models/zombie/classic.mdl"
ITEM.Moveable = false
ITEM.MaxStack = 1

function ITEM:GetMassCapacity()
	return 200
end

if SERVER then
	ENT.Model = ITEM.Model

	function ENT:Initialize()
		self:SetModel(self.Model)

		self:PhysicsInit(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		self:SetSequence("slump_b")
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:IsPersistent()
	return true
end

function ENT:SetPlayerUID(uid)
	self:SetDTInt(0, uid)
end

function ENT:GetPlayerUID()
	return self:GetDTInt(0)
end

function ENT:SetPlayer(pl)
	self:SetPlayerUID(pl:UniqueID())
end

function ENT:GetPlayer()
	local uid = self:GetPlayerUID()
	if uid ~= 0 then
		for _, pl in pairs(player.GetAll()) do
			if pl:UniqueID() == uid then return pl end
		end
	end

	return NULL
end
