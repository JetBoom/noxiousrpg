ENT.Type = "anim"

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
