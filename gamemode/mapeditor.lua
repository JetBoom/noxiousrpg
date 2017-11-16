file.CreateDir(GM.MapEditorPrefix.."maps")

concommand.Add("mapeditor_add", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local tr = sender:GetEyeTrace()
	if tr.Hit then
		local ent = ents.Create(string.lower(arguments[1]))
		if ent:IsValid() then
			ent:SetPos(tr.HitPos)
			ent:Spawn()
			table.insert(GAMEMODE.MapEditorEntities, ent)
			GAMEMODE:SaveMapEditorFile()
		end
	end
end)

concommand.Add("mapeditor_addonme", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local ent = ents.Create(string.lower(arguments[1]))
	if ent:IsValid() then
		ent:SetPos(sender:EyePos())
		ent:SetAngles(sender:GetAngles())
		ent:Spawn()
		table.insert(GAMEMODE.MapEditorEntities, ent)
		GAMEMODE:SaveMapEditorFile()
	end
end)

concommand.Add("mapeditor_remove", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				table.remove(GAMEMODE.MapEditorEntities, i)
				ent:Remove()
			end
		end
		GAMEMODE:SaveMapEditorFile()
	end
end)

local function ME_Pickup(pl, ent, uid)
	if pl:IsValid() and ent:IsValid() then
		ent:SetPos(util.TraceLine({start=pl:EyePos(),endpos=pl:EyePos() + pl:GetAimVector() * 3000, filter={pl, ent}}).HitPos)
		return
	end
	timer.Destroy(uid.."mapeditorpickup")
	GAMEMODE:SaveMapEditorFile()
end

concommand.Add("mapeditor_pickup", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				timer.Create(sender:UniqueID().."mapeditorpickup", 0.25, 0, function() ME_Pickup(sender, ent, sender:UniqueID()) end)
			end
		end
	end
end)

concommand.Add("mapeditor_nudgeup", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				ent:SetPos(ent:GetPos() + Vector(0,0,amount))
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_nudgeforward", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				ent:SetPos(ent:GetPos() + ent:GetForward() * amount)
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_nudgeright", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				ent:SetPos(ent:GetPos() + ent:GetRight() * amount)
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_rotateup", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				local ang = ent:GetAngles()
				ang:RotateAroundAxis(ang:Up(), amount)
				ent:SetAngles(ang)
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_rotateforward", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				local ang = ent:GetAngles()
				ang:RotateAroundAxis(ang:Forward(), amount)
				ent:SetAngles(ang)
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_rotateright", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:GetEyeTrace()
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			if ent == tr.Entity then
				local amount = tonumber(arguments[1]) or 1
				local ang = ent:GetAngles()
				ang:RotateAroundAxis(ang:Right(), amount)
				ent:SetAngles(ang)
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

concommand.Add("mapeditor_drop", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	timer.Destroy(sender:UniqueID().."mapeditorpickup")
	GAMEMODE:SaveMapEditorFile()
end)

function GM:LoadMapEditorFile()
	local mapname = game.GetMap()

	self.MapEditorEntities = {}
	if file.Exists(self.MapEditorPrefix.."maps/"..mapname..".txt", "DATA") then
		local red = file.Read(self.MapEditorPrefix.."maps/"..mapname..".txt", "DATA")
		if string.sub(red, 1, 3) == "SRL" then
			for _, enttab in pairs(Deserialize(red)) do
				local ent = ents.Create(string.lower(enttab.Class))
				if ent:IsValid() then
					ent:SetPos(enttab.Position)
					ent:SetAngles(enttab.Angles)
					if enttab.KeyValues then
						for key, value in pairs(enttab.KeyValues) do
							if ent["Set"..key] then
								ent["Set"..key](ent, value)
							else
								ent[key] = value
							end
						end
					end
					ent:Spawn()
					table.insert(self.MapEditorEntities, ent)
				end
			end
		else
			for _, stuff in pairs(string.Explode(",", red)) do
				local expstuff = string.Explode(" ", stuff)
				local ent = ents.Create(string.lower(expstuff[1]))
				if ent:IsValid() then
					ent:SetPos(Vector(tonumber(expstuff[2]), tonumber(expstuff[3]), tonumber(expstuff[4])))
					for i=5, #expstuff do
						local kv = string.Explode("�", expstuff[i])
						ent:SetKeyValue(kv[1], kv[2])
					end
					ent:Spawn()
					table.insert(self.MapEditorEntities, ent)
				end
			end
		end
	end
end

function GM:SaveMapEditorFile()
	local sav = {}
	for _, ent in pairs(self.MapEditorEntities) do
		if ent:IsValid() then
			local enttab = {}
			enttab.Class = ent:GetClass()
			enttab.Position = ent:GetPos()
			enttab.Angles = ent:GetAngles()
			if ent.KeyValues then
				local keyvalues = {}
				for i, key in ipairs(ent.KeyValues) do
					if ent["Get"..key] then
						keyvalues[key] = ent["Get"..key](ent)
					else
						keyvalues[key] = ent[key]
					end
				end
				enttab.KeyValues = keyvalues
			end
			table.insert(sav, enttab)
		end
	end
	file.Write(self.MapEditorPrefix.."maps/"..game.GetMap()..".txt", Serialize(sav))
end
