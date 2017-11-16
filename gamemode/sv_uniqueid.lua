local uid = tonumber(file.Read("rpguid.txt", "DATA") or 2049)

function GetUID()
	uid = uid + 1
	return uid
end

local SavedUID = uid
timer.Create("SaveUID", 10, 0, function()
	if SavedUID ~= uid then
		file.Write("uid.txt", uid)
		SavedUID = uid
	end
end)
