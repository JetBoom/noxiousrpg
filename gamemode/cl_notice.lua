function GM:AddNotify2(str, color, noantispam)
	self:AddNotify(str, color, nil, nil, noantispam)
end

local HUDNotes = {}
function GM:AddNotify(str, color, length, font, noantispam)
	if not str then return end

	length = length or 6
	color = color or color_white

	local findmin, findmax, text, snd = string.find(str, "(.+)~s(.+)")
	if text and str then
		str = text
		if snd ~= "nil" then
			surface.PlaySound(snd)
		end
	end

	if not noantispam then
		for _, note in pairs(HUDNotes) do
			if note.text == str then
				note.death = math.max(RealTime() + length, note.death)
				note.color = table.Copy(color)
				note.repeats = (note.repeats or 1) + 1
				if length <= 1 then
					note.color.a = math.floor(length * 255)
				end

				return
			end
		end
	end

	local tab = {}
	tab.text = str
	tab.death = RealTime() + length
	tab.color = table.Copy(color)
	tab.font = font or "rpg_notice"

	chat.AddText(tab.color, str)

	if 12 < #HUDNotes then
		table.remove(HUDNotes, #HUDNotes)
	end

	table.insert(HUDNotes, 1, tab)
end

function GM:PaintNotes()
	if #HUDNotes == 0 then return end

	local rt = RealTime()
	local y = h * 0.35
	local x = w * 0.5
	for i, note in ipairs(HUDNotes) do
		if note then
			if rt <= note.death then
				note.color.a = math.min(note.death - rt, 1) * 255
				if note.repeats then
					draw.SimpleText(note.text.." (x"..note.repeats..")", note.font, x, y, note.color, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(note.text, note.font, x, y, note.color, TEXT_ALIGN_CENTER)
				end
				local addx, addy = surface.GetTextSize(note.text)
				y = y - addy
			else
				table.remove(HUDNotes, i)
				i = i - 1
			end
		end
	end
end
