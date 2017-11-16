-- HACK: Delete me. Temporary fix.

local DEBUG = false

if not NDB then
	NDB = {}
	function NDB:SaveInfo(...)
		if DEBUG then error("NDB:SaveInfo called") end
	end
end

function NDB.AddContentsCallback(type, callback)
	if DEBUG then error("NDB:AddContentsCallback called") end
	net.Receive(tostring(type), callback(net.ReadString()))
end

local player = FindMetaTable("Player")
if SERVER then
	function player:SendLongString(type, str)
		if DEBUG then error("Player:SendLongString called") end
		local type = tostring(type)

		if util.NetworkStringToID(type) == 0 then
			util.AddNetworkString(type)
		end

		net.Start(type)
			net.WriteString(str)
		net.Send(self)
	end
end
