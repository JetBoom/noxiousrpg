AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:ResetSpeed()
end

function ENT:Think()
	if self:IsRemoving() then return end

	local target = self:GetHealTarget()
	local owner = self:GetOwner()
	if not target:IsValid() or owner ~= target and owner:TraceHull(32, MASK_SOLID, 2).Entity ~= target then
		owner:SendMessage("Your target is no longer in range.", "COLOR_RED")

		self:Remove()
	elseif CurTime() >= self:GetEndTime() then
		if gamemode.Call("PlayerCanHelp", owner, target) then
			if target:GetMaxHealth() <= target:Health() then
				owner:SendMessage("You finish applying the bandages but they barely do anything.", "COLOR_RED")
			else
				local oldhealth = target:Health()
				--gamemode.Call("PlayerHeal", target, owner, math.floor(10 + self:GetSkillLevel() * 0.03))
				gamemode.Call("PlayerHeal", target, owner, math.floor(10 + owner:GetSkill(SKILL_HEALING) * 0.03))
				owner:UseSkill(SKILL_HEALING, math.abs(oldhealth - target:Health()) / 50)
				owner:SendMessage("You finish applying the bandages.")
				if target ~= owner then
					target:SendMessage("You had bandages applied to you by "..owner:Name()..".", "COLOR_LIMEGREEN")
				end
			end
			--target:EmitSound("")
		else
			owner:SendMessage("You couldn't heal them.", "COLOR_RED")
		end

		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		parent:ResetSpeed()
	end
end

function ENT:SetSkillLevel(skill)
	self:SetDTFloat(3, skill)
end
