-- HACK: Delete me. Temporary fix.

NDB = {}
function NDB:AddContentsCallback(type, callback)
	net.Receive(tostring(type), callback)
end

if SERVER then
	local meta = FindMetaTable("Player")
	if not meta then return end
	
	function meta:SendLongString(type, str)
		type = tostring(type)

		if util.NetworkStringToID(type) == 0 then
			util.AddNetworkString(type)
		end
	
		net.Start(type)
			net.WriteString(str)
		net.Send()
	end
end