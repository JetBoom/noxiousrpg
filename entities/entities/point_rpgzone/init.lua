include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Persist = true

function ENT:StartTouch(ent)
	gamemode.Call("OnEnterZone", self, ent)
end

function ENT:EndTouch(ent)
	gamemode.Call("OnLeaveZone", self, ent)
end

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetTrigger(true)

	self.DisplayName = self.DisplayName or "Unnamed"
	self.DataName = self.DataName or "NULL"
	self.Ruleset = self.Ruleset or RULESET_DEFAULT

	self.Initializing = true
	if self.Mins and self.Maxs then
		self:SetMins(self.Mins)
	elseif self.Radius then
		self:SetRadius(self.Radius)
	end
	self.Initializing = nil
end

function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "registerzone" then
		self:RegisterZone()
		return true
	end
end

function ENT:RegisterZone()
	local allzones = GetAllZones()
	local cur = allzones[self.DataName]
	if cur then
		cur.DisplayName = self.DisplayName
		cur.Position = self:GetPos()
		cur.Radius = self.Radius
		cur.Mins = self.Mins
		cur.Maxs = self.Maxs
		cur.Guild = self.Guild
		cur.Ruleset = self.Ruleset
		cur.ExitSound = self.ExitSound
		cur.EnterSound = self.EnterSound
	else
		allzones[self.DataName] = {DisplayName = self.DisplayName, Position = self:GetPos(), Radius = self.Radius, Mins = self.Mins, Maxs = self.Maxs, Guild = self.Guild, Ruleset = self.Ruleset, ExitSound = self.ExitSound, EnterSound = self.EnterSound}
	end

	allzones[self.DataName].Entity = self

	if not self.Initializing then
		gamemode.Call("UpdateZone", self.DataName)
	end
end

function ENT:SetPosition(pos)
	self:SetPos(pos)
	self:RegisterZone()
end

function ENT:SetEnterSound(snd)
	self.EnterSound = snd
	self:RegisterZone()
end

function ENT:SetExitSound(snd)
	self.ExitSound = snd
	self:RegisterZone()
end

function ENT:SetRadius(radius)
	self.Radius = radius

	if radius then
		self:PhysicsInitSphere(radius)
		self:SetCollisionBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
		end

		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetNotSolid(true)
	end

	self:RegisterZone()
end

function ENT:SetDataName(name)
	if self.DataName and name ~= self.DataName then
		if GetAllZones()[self.DataName] then
			GetAllZones()[self.DataName] = nil
		end
	end

	self.DataName = name
	self:RegisterZone()
end

function ENT:SetDisplayName(name)
	self.DisplayName = name
	self:RegisterZone()
end

function ENT:SetMins(mins)
	self.Mins = mins

	if mins and self.Maxs then
		self:PhysicsInitBox(mins, self.Maxs)
		self:SetCollisionBounds(mins, self.Maxs)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
		end

		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetNotSolid(true)
	end

	self:RegisterZone()
end

function ENT:SetMaxs(maxs)
	self.Maxs = maxs

	if maxs and self.Mins then
		self:PhysicsInitBox(self.Mins, maxs)
		self:SetCollisionBounds(self.Mins, maxs)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
		end

		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetNotSolid(true)
	end

	self:RegisterZone()
end

function ENT:SetGuild(guildid)
	self.Guild = guildid
	self:RegisterZone()
end

function ENT:SetRuleset(id)
	self.Ruleset = id
	self:RegisterZone()
end

function ENT:OnSave(tab)
	tab.DisplayName = self.DisplayName
	tab.DataName = self.DataName
	tab.Radius = self.Radius
	tab.Mins = self.Mins
	tab.Maxs = self.Maxs
	tab.Guild = self.Guild
	tab.Ruleset = self.Ruleset
	tab.EnterSound = self.EnterSound
	tab.ExitSound = self.ExitSound
end

function ENT:OnLoaded(tab)
	self.Initializing = true
	self:SetDisplayName(tab.DisplayName or self.DisplayName)
	self:SetDataName(tab.DataName or self.DataName)
	self:SetRadius(tab.Radius or self.Radius)
	self:SetMins(tab.Mins or self.Mins)
	self:SetMaxs(tab.Maxs or self.Maxs)
	self:SetGuild(tab.Guild or self.Guild)
	self:SetRuleset(tab.Ruleset or self.Ruleset)
	self:SetEnterSound(tab.EnterSound or self.EnterSound)
	self:SetExitSound(tab.ExitSound or self.ExitSound)
	self.Initializing = nil

	self:Input("registerzone", self, self)
end
