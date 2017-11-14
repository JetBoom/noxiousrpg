AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_foliage/tree_stump01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if self:GetMaxLumberjackingHealth() == 0 then
		self:SetMaxLumberjackingHealth(100)
	end
	if self:GetLumberjackingHealth() == 0 then
		self:SetLumberjackingHealth(self:GetMaxLumberjackingHealth())
	end
end

function ENT:OnSave(tab)
	tab.LumberjackingHealth = self:GetLumberjackingHealth()
	tab.MaxLumberjackingHealth = self:GetMaxLumberjackingHealth()
end

function ENT:OnLoaded(tab)
	if tab.LumberjackingHealth then
		self:SetLumberjackingHealth(tab.LumberjackingHealth)
	end
	if tab.MaxLumberjackingHealth then
		self:SetMaxLumberjackingHealth(tab.MaxLumberjackingHealth)
	end
end
