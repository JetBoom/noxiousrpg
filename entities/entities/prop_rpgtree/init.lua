AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if self:GetModel() == "models/error.mdl" then
		self:SetModel(GAMEMODE:GetRandomTreeModel())
	end
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if self:GetMaxLumberjackingHealth() == 0 then
		self:SetMaxLumberjackingHealth(1000)
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
