local meta = FindMetaTable("Entity")
if not meta then return end

function meta:Talk(text, filter, radius)
	if filter and filter ~= MySelf or radius and MySelf ~= self and MySelf:EyePos():Distance(self:MouthPos()) > radius then return end

	if string.sub(text, 1, 1) == ">" then
		if self == MySelf then
			chat.AddText(COLOR_THINK, text)
		end
	else
		local col = self:GetNameColor(MySelf)
		local c = "<c="..math.ceil(col.r)..","..math.ceil(col.g)..","..math.ceil(col.b)..">"

		if self:IsPlayer() then
			if self:IsGhost() and not MySelf:IsGhost() then
				text = string.GhostScramble(text)
			end

			if self == MySelf then
				chat.AddText(COLOR_WHITE, c.."You</c> say \""..text.."\"")
			else
				chat.AddText(COLOR_WHITE, c..self:RPGName().."</c> says \""..text.."\"")
			end
		else
			local itemdata = self:GetItem() or self:GetDefaultItemData()
			chat.AddText(COLOR_WHITE, "You hear \""..text.."\" come from "..c..(util.NameByAmount(itemdata.Name, self:GetAmount()) or self:GetClass()).."</c>.")
		end

		if self ~= MySelf then
			if not (GAMEMODE.TalkBubbles[self] and GAMEMODE.TalkBubbles[self]:Valid()) then
				local pan = vgui.Create("DTalkBubbleLinkedList")
				pan:SetRemoveOnEmpty(true)
				pan:SetPaintedManually(true)
				GAMEMODE.TalkBubbles[self] = pan
			end

			GAMEMODE.TalkBubbles[self]:AddLine(text, self)
		end
	end
end

function meta:Floatie(text, colid, filter)
	if filter and filter ~= MySelf then return end

	table.insert(GAMEMODE.Floaties, {Entity = self, Text = text, Color = table.Copy(COLID_TO_COLOR[colid] or color_white), EndTime = CurTime() + math.Clamp(#text * 0.15, 3, 7)})
end

function meta:SetRenderBoundsNumber(fNum)
	local fNumNegative = -fNum
	self:SetRenderBounds(Vector(fNumNegative, fNumNegative, fNumNegative), Vector(fNum, fNum, fNum))
end

function meta:SetMaxMana(amount, regeneration)
	self.MaxMana = amount
	self.ManaRegenerate = regeneration
end

--[[function meta:SetMaxStamina(amount, regeneration)
	self.MaxStamina = amount
	self.StaminaRegenerate = regeneration
end]]

function meta:GetContainerPanel()
	local container = self:GetContainer()
	if container then
		return pContainer[container.ID]
	end
end

-- Just in case these are added to the client at a later date.
local function empty() end
meta.TakeDamage = meta.TakeDamage or empty
meta.TakeSpecialDamage = meta.TakeSpecialDamage or empty
meta.TakeDamageInfo = meta.TakeDamageInfo or empty
