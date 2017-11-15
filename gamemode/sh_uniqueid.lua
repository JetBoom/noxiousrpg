local FILE_NAME = "rpguid.txt"
if not file.Exists(FILE_NAME, "DATA") then file.Write(FILE_NAME, 2049) end
function GetUID()
	local num = tonumber(file.Read(FILE_NAME, "DATA")) + 1
	file.Write(FILE_NAME, num)

	return num
end
