ENT.Type = "point"

ENT.Persist = true

function ENT:Initialize()
	self.MaxSpawn = self.MaxSpawn or 4
	self.MinDelay = self.MinDelay or 20
	self.MaxDelay = self.MaxDelay or 30
	self.MinSpawnMultiplier = self.MinSpawnMultiplier or 1
	self.MaxSpawnMultiplier = self.MaxSpawnMultiplier or 1
	self.Radius = self.Radius or 256
	self.UID = self.UID or GetUID()
	self.SpawnClasses = self.SpawnClasses or {}
	self.SpawnKeyValues = self.SpawnKeyValues or {}
	if self.SpawnWhenPlayersInRadius == nil then
		self.SpawnWhenPlayersInRadius = false
	end
	if self.DropOBBCenter == nil then
		self.DropOBBCenter = false
	end
	if self.Disabled == nil then
		self.Disabled = true
	end

	self:Fire("dospawn", "1", math.Rand(self.MinDelay, self.MaxDelay))
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "dospawn" and not (self.Loaded and args == "1") then
		self:Fire("dospawn", "", math.Rand(self.MinDelay, self.MaxDelay))

		if self.Disabled or #self.SpawnClasses == 0 then return true end

		local insphere = ents.FindInSphere(self:GetPos(), self.Radius)

		if not self.SpawnWhenPlayersInRadius then
			for _, e in pairs(insphere) do
				if e:IsPlayer() and e:Alive() and not e:IsGhost() then
					return true
				end
			end
		end

		local count = 0
		for _, e in pairs(insphere) do
			if e.SpawnerUID and e.SpawnerUID == self.UID then
				count = count + 1
			end
		end

		if count >= self.MaxSpawn then return true end

		for i=1, math.min(math.random(self.MinSpawnMultiplier, self.MaxSpawnMultiplier), self.MaxSpawn - count) do
			local class = self.SpawnClasses[math.random(1, #self.SpawnClasses)]
			local ent = ents.Create(class)
			if ent:IsValid() then
				ent.SpawnerUID = self.UID
				ent:SetPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):Normalize() * math.Rand(-self.Radius, self.Radius))
				ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
				ent:Spawn()
				ent:DropToFloor()
				if self.DropOBBCenter then
					ent:SetPos(ent:GetPos() - Vector(0, 0, (ent:OBBCenter().z - ent:OBBMins().z) - 1))
				end

				local stop = false
				for _, e in pairs(ents.FindInBox(ent:WorldSpaceAABB())) do
					if e:IsCharacter() or e:GetClass() == class and e ~= ent then
						ent:Remove()
						stop = true
					end
				end

				if not stop then
					for key, value in pairs(self.SpawnKeyValues) do
						if ent["Set"..key] and value then
							--local val = tab.MinValue and tab.MaxValue and math.Rand(tab.MinValue, tab.MaxValue) or tab.Value
							ent["Set"..key](ent, value)
						end
					end
				end
			end
		end

		return true
	end
end

function ENT:OnSave(tab)
	tab.MaxSpawn = self.MaxSpawn
	tab.MinDelay = self.MinDelay
	tab.MaxDelay = self.MaxDelay
	tab.MinSpawnMultiplier = self.MinSpawnMultiplier
	tab.MaxSpawnMultiplier = self.MaxSpawnMultiplier
	tab.Radius = self.Radius
	tab.SpawnWhenPlayersInRadius = self.SpawnWhenPlayersInRadius
	tab.Disabled = self.Disabled
	tab.UID = self.UID
	tab.SpawnClasses = self.SpawnClasses
	tab.SpawnKeyValues = self.SpawnKeyValues
	tab.DropOBBCenter = self.DropOBBCenter
end

function ENT:OnLoaded(tab)
	self.MaxSpawn = tab.MaxSpawn
	self.MinDelay = tab.MinDelay
	self.MaxDelay = tab.MaxDelay
	self.MinSpawnMultiplier = tab.MinSpawnMultiplier
	self.MaxSpawnMultiplier = tab.MaxSpawnMultiplier
	self.Radius = tab.Radius
	self.SpawnWhenPlayersInRadius = tab.SpawnWhenPlayersInRadius
	self.Disabled = tab.Disabled
	self.UID = tab.UID
	self.SpawnClasses = tab.SpawnClasses
	self.SpawnKeyValues = tab.SpawnKeyValues
	self.DropOBBCenter = tab.DropOBBCenter

	self.Loaded = true

	self:Fire("dospawn", "", math.Rand(self.MinDelay, self.MaxDelay))
end
