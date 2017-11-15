local meta = FindMetaTable("NPC")
if not meta then return end

function meta:Alive()
	return 0 < self:Health()
end

function meta:GetShootPos()
	return self:EyePos()
end

function meta:EyeAngles()
	return self:GetAimVector():Angle()
end

function meta:Team()
	return self:GetTeamID()
end

function meta:UniqueID()
	return self:EntIndex()
end

function meta:InVehicle()
	return false
end

function meta:GetRagdollEntity()
end

function meta:RPGName(viewer)
	return "#"..self:GetClass()
end

function meta:GetNameColor(viewer)
	return COLOR_WHITE
end
