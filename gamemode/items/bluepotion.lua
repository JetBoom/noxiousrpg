ITEM.Name = "blue potion"
ITEM.Model = Model("models/items/provisions/potions/life_potion.mdl")
ITEM.Color = Color(0, 100, 255, 255)
ITEM.Mass = 6
ITEM.MaxStack = -1

if SERVER then
	function ITEM:OnUse(pl)
		if CurTime() < (pl.NextPotion or 0) then
			pl:SendMessage("You can't drink another potion so quickly!", "COLOR_RED")

			return
		end

		local curmana = pl:GetMana()
		local maxmana = pl:GetMaxMana()
		if curmana < maxmana then
			pl.NextPotion = CurTime() + POTION_REDRINKTIME
			pl:SetMana(math.min(maxmana, curmana + 30))

			-- pl:SendLua("GAMEMODE:AddNotify()")
			pl:SendMessage("You drank the "..self.Name.." and gained ".. math.ceil((pl:GetMana() - curmana) * 10) * 0.1 .." mana.", "COLOR_LIMEGREEN", true)

			return ITEM_ONUSE_DECREMENT
		end

		pl:SendMessage("You are already at full mana.", "COLOR_RED")
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end
end

resource.AddFile("models/items/provisions/potions/life_potion.mdl")
resource.AddFile("Materials/models/potion_life/glass_life_potion.vmt")
resource.AddFile("Materials/models/potion_life/glass_life_potion.vtf")
resource.AddFile("Materials/models/potion_life/glass_life_potion.vmt")
resource.AddFile("Materials/models/potion_life/glass_life_potion_normal.vtf")
resource.AddFile("Materials/models/potion_life/glass_life_potion_trans.vmt")
