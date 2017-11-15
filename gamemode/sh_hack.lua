-- HACK: Delete me. Temporary fix.

local DEBUG = false

NDB = {}
function NDB:AddContentsCallback(type, callback)
	if DEBUG then error("NDB:AddContentsCallback called") end
	net.Receive(tostring(type), callback)
end

function NDB:SaveInfo(...)
	if DEBUG then error("NDB:SaveInfo called") end
end

local player = FindMetaTable("Player")
local entity = FindMetaTable("Entity")
if SERVER then

	if player then
		function player:SendLongString(type, str)
			if DEBUG then error("Player:SendLongString called") end
			type = tostring(type)

			if util.NetworkStringToID(type) == 0 then
				util.AddNetworkString(type)
			end
		
			net.Start(type)
				net.WriteString(str)
			net.Send(self)
		end
	end

	if entity then
		function entity:GiveStatus(...)
			if DEBUG then error("Entity:GiveStatus called") end
			return {
				CapSkillLevel = function(...)
					if DEBUG then error("Status:CapSkillLevel called") end
				end
			}
		end

		function entity:RemoveStatus(...)
			if DEBUG then error("Entity:RemoveStatus called") end
		end

		function entity:RemoveAllStatus(...)
			if DEBUG then error("Entity:RemoveAllStatus called") end
		end
	end
end

function entity:IsCharacter()
	if DEBUG then error("Entity:IsCharacter called") end
	return self:IsPlayer() and not self:IsMonster()
end