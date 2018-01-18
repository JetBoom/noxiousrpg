ITEM.DataIndex = 5

ITEM.Name = "bandage"
ITEM.Model = Model("models/items/provisions/potions/life_potion.mdl")
ITEM.Mass = 0.5
ITEM.MaxStack = -1

if SERVER then
	function ITEM:OnUse(pl)
		if pl:Health() >= pl:GetMaxHealth() then
			pl:SendMessage("You are already at full health.", "COLOR_RED")
			return
		end

		if IsValid(pl.status_applyingbandage) then
			pl:SendMessage("You are already applying a bandage.", "COLOR_RED")
			return
		end
		pl:RemoveStatus("applyingbandage", false, true)

		local status = pl:GiveStatus("applyingbandage")
		if status and status:IsValid() then
			status:SetHealTarget(pl)
			status:SetSkillLevel(pl:GetSkill(SKILL_HEALING))
			status:SetEndTime(CurTime() + (10 - pl:GetSkill(SKILL_DEXTERITY) * 0.03))

			pl:SendMessage("You begin applying the bandage.")
			--pl:EmitSound("")

			return ITEM_ONUSE_DECREMENT
		end
	end

	function ITEM:OnInteract(pl, arguments)
		if arguments == "apply" then
			return pl:UseItem(self)
		end
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end

	--[[ENT.ContextMenuOptions = {
		"Apply",
		function(btn)
			if IsValid(btn.Entity) then
				RunConsoleCommand("rpg_interact", btn.Entity:EntIndex(), "apply")
			end
		end
	}]]
end
