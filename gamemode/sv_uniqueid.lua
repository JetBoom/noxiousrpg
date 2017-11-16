local FILE_NAME = "rpguid.txt"

local uid = tonumber(file.Read(FILE_NAME, "DATA") or 2049) 

function GetUID()
	uid = uid + 1
	return uid
end

local SavedUID = uid
timer.Create("SaveUID", 10, 0, function()
	if SavedUID ~= uid then
		file.Write(FILE_NAME, uid)
		SavedUID = uid
	end
end)
