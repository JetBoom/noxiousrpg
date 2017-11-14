if not file.Exists("rpguid.txt") then file.Write("rpguid.txt", 2049) end
function GetUID()
	local num = tonumber(file.Read("rpguid.txt")) + 1
	file.Write("rpguid.txt", num)

	return num
end
