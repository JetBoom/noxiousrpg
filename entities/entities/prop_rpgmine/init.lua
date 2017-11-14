AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if self:GetModel() == "models/error.mdl" then
		self:SetModel(metal.DefaultNodeModels[math.random(1, #metal.DefaultNodeModels)])
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if self:GetMineHealth() == 0 then
		self:SetMineHealth(self.MaxMineHealth)
	end

	self:NextThink(0)
end

function ENT:SetContents(contents)
	self.Contents = contents
	self:RefreshCharacteristics()
end

function ENT:SetContentsRandom(contents)
	local tab = {}

	for typ, t in pairs(contents) do
		tab[typ] = math.random(t[1], t[2])
	end

	self:SetContents(tab)
end

function ENT:GetContents()
	return self.Contents or {}
end

function ENT:RefreshCharacteristics()
	local metalinfo = metal.BuildMetalInformation(self:GetContents())

	self:SetColor(metalinfo.Color.r, metalinfo.Color.g, metalinfo.Color.b, metalinfo.Color.a)
	self:SetMaterial(metalinfo.Material)
	self:SetMass(metalinfo.Mass)
end

function ENT:Think()
	if self.Removing then self:Remove() end
end

function ENT:OnTakeDamage(dmginfo)
	local damage = dmginfo:GetDamage()
	local damagetype = dmginfo:GetDamageType()
	if damagetype == DMGTYPE_BASHING then
		if not dmginfo:GetInflictor().IsPickaxe then -- Heavy maces can sort of be used for mining.
			damage = damage - 25
		end

		if damage > 0 then
			if self:GetMineHealth() <= damage then
				self:Destroyed(dmginfo)
			else
				self:SetMineHealth(self:GetMineHealth() - damage)
				self:EmitSound("rpgsounds/impact_stone2.wav", 80, 65 + (self:GetMineHealth() / self.MaxMineHealth) * 80)
			end
		end
	end
end

function ENT:Destroyed(dmginfo)
	local contents = self:GetContents()

	local pos = self:LocalToWorld(self:OBBCenter())
	local force = dmginfo:GetDamage() + 128

	-- Evenly split the total material in this node in to smaller bits and throw them around.
	local subcontents = {}
	for i=1, self.NumBits do
		subcontents[i] = {}
	end

	for metaltype, amount in pairs(contents) do
		local cycle = 1
		while amount > 0 do
			subcontents[cycle][metaltype] = (subcontents[cycle][metaltype] or 0) + 1
			amount = amount - 1

			cycle = cycle + 1
			if cycle > self.NumBits then
				cycle = 1
			end
		end
	end

	for i=1, self.NumBits do
		if table.Count(subcontents[i]) > 0 then
			local ent = SpawnItem("ore")
			if ent:IsValid() then
				local heading = (VectorRand() + self:GetUp()):Normalize()

				ent:SetPos(pos + heading * 8)
				ent:SetAngles(VectorRand():Angle())
				ent:Spawn()
				local item = ent:GetItem()
				if item then
					item:GetItemData().SetContents(item, table.Copy(subcontents[i]))
				end
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocityInstantaneous(force * heading)
					phys:AddAngleVelocity(force * 0.1 * VectorRand())
				end
			end
		end
	end

	self.Contents = nil

	self.Removing = true
	self:NextThink(CurTime())
end

function ENT:OnSave(tab)
	tab.MineHealth = self:GetMineHealth()
	tab.MaxMineHealth = self.MaxMineHealth
	tab.Contents = self.Contents
end

function ENT:OnLoaded(tab)
	if tab.MineHealth then
		self:SetMineHealth(tab.MineHealth)
	end
	if tab.MaxMineHealth then
		self.MaxMineHealth = tab.MaxMineHealth
	end
	if tab.Contents then
		self:SetContents(tab.Contents)
	end
end
