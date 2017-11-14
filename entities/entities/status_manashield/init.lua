AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() and owner:GetMana() <= 1 then
		self.DieTime = 0
	end

	return self.BaseClass.Think(self)
end

function ENT:PlayerSet(pPlayer, bExists)
	local mana = pPlayer:GetMana()
	local amount = pPlayer:GetSkill(SKILL_INTELLIGENCE)
	pPlayer:SetMaxMana(GAMEMODE:GetMaxMana(amount), GAMEMODE:GetManaRegeneration(amount) - 2)
	pPlayer:SetMana(mana, true)
end

function ENT:OnRemove()
	local pPlayer = self:GetOwner()
	if pPlayer:IsValid() then
		local mana = pPlayer:GetMana()
		local amount = pPlayer:GetSkill(SKILL_INTELLIGENCE)
		pPlayer:SetMaxMana(GAMEMODE:GetMaxMana(amount), GAMEMODE:GetManaRegeneration(amount) - 2)
		pPlayer:SetMana(mana, true)
	end
end
