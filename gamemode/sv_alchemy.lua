function ProcessAlchemyMix(mix, targetitem)
	local base = mix.Base % 5
	local dataname = targetitem:GetDataName()

	for mixtype, mixtab in pairs(ALCHEMY_MIXES) do
		if mixtab.Ingredient == dataname and mix.Base == mixtab.Base then
			local power = math.floor(mix.Base / 5) + 1
			-- TODO: Create the potion.
			local item = Item({Power = power, Mix = mixtype}, "potion")
			if item then
				mix:SetAmount(mix:GetAmount() - 1)
				targetitem:SetAmount(targetitem:GetAmount() - 1)
				return item
			end

			return
		end
	end

	if ALCHEMY_BASE_MODIFIERS[dataname] then
		mix.Base = ALCHEMY_BASE_MODIFIERS[dataname](mix.Base, targetitem) % 50
		targetitem:SetAmount(targetitem:GetAmount() - 1)
		return
	end

	return
end

ALCHEMY_MIX_ONUSE = {}

-- Heals for maximum of 40
ALCHEMY_MIX_ONUSE[ALCHEMY_MIX_HEAL] = function(pl, item)
	pl:SetHealth(math.min(pl:GetMaxHealth(), pl:Health() + 10 + item.Power * 4))
end

-- Harms for maximum of 25
ALCHEMY_MIX_ONUSE[ALCHEMY_MIX_HARM] = function(pl, item)
	pl:TakeDamage(5 + item.Power * 2, pl, item:GetEntity())
end
