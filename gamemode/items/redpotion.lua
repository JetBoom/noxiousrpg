ITEM.DataIndex = 32

ITEM.Name = "red potion"
ITEM.Model = Model("models/items/provisions/potions/life_potion.mdl")
ITEM.Mass = 6
ITEM.MaxStack = -1

if SERVER then
	function ITEM:OnUse(pl)
		if CurTime() < (pl.NextPotion or 0) then
			pl:SendMessage("You can't drink another potion so quickly!", "COLOR_RED")
			return
		end

		local curhealth = pl:Health()
		local maxhealth = pl:GetMaxHealth()
		if curhealth < maxhealth then
			pl.NextPotion = CurTime() + POTION_REDRINKTIME
			pl:SetHealth(math.min(maxhealth, curhealth + 15))
			pl:UseSkill(SKILL_HEALING, 0.25)

			pl:SendMessage("You drank the "..self.Name.." and gained "..pl:Health() - curhealth.." health.", "COLOR_LIMEGREEN")

			return ITEM_ONUSE_DECREMENT
		end

		pl:SendMessage("You are already at full health.", "COLOR_RED")
	end

	--[[function ENT:Use(activator, caller, action)
		if activator:IsPlayer() and action == "drink" and GetItemData(self:GetItemClass()).OnUse(self.ItemData, activator) == ITEM_ONUSE_DECREMENT then
			self:Remove()
		end
	end]]
end

if CLIENT then
	function ITEM:OnUse(pl)
	end

	--[[ENT.ContextMenuOptions = {
		"Drink",
		function(btn)
			if IsValid(btn.Entity) then
				RunConsoleCommand("rpg_interact", btn.Entity:EntIndex(), "drink")
			end
		end
	}]]
end
