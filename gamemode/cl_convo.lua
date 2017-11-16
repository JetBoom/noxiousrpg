include("sh_convo.lua")

local ActiveConvoFrame

local function ChoiceDoClick(self)
	RunConsoleCommand("convo_reply", self.Choice, unpack(self.SendAlong))
end

local function EmptyPaint(self)
	return true
end
local function CloseDoClick(self)
	RunConsoleCommand("convo_reply", -1)
	self:GetParent():Remove()
end
function convo.CreateConvoFrame(ent, text, choices)
	convo.CloseFrame()

	local wid, hei = math.min(640, ScrW() - 64), 200

	local window = vgui.Create("DPanel")
	window:SetSize(wid, hei * 2)
	window.Paint = EmptyPaint
	ActiveConvoFrame = window

	local textholder = vgui.Create("DPanelList", window)
	textholder:SetSize(wid, hei)
	textholder:AlignTop(hei)
	textholder:SetPadding(2)
	--textholder:SetDrawBackground(false)
	textholder:EnableVerticalScrollbar()

	if ent:IsValid() then
		local namebox = WordBox(window, ent:RPGName(MySelf))
		namebox:AlignRight(8)
		namebox:MoveAbove(textholder, 8)
	end

	local label = vgui.Create("DLabel", textholder)
	label:SetTall(textholder:GetTall())
	label:SetContentAlignment(7)
	label:SetWrap(true)
	label:SetAutoStretchVertical(true)
	label:SetText(text)
	label:SetFont(DEFAULTFONT)
	if string.sub(text, 1, 1) == ">" then
		label:SetTextColor(COLOR_THINK)
	end
	textholder:AddItem(label)

	if choices and #choices > 0 then
		local choiceswide = 300
		local choicesholder = vgui.Create("DPanel", window)
		choicesholder:SetWide(choiceswide)

		local y = 8

		local sendalong = {}

		for i, choice in ipairs(choices) do
			local choicetype = choice[1]
			if choicetype == CHOICETYPE_POINT then
				local button = EasyButton(choicesholder, choice[3], 0, 4)
				button:SetWide(choiceswide - 16)
				button:SetPos(8, y)
				button:CenterHorizontal()
				button.Choice = i
				button.DoClick = ChoiceDoClick
				button.SendAlong = sendalong

				y = y + button:GetTall() + 8
			elseif choicetype == CHOICETYPE_SLIDER then
				-- TODO
			elseif choicetype == CHOICETYPE_TEXTENTRY then
				-- TODO
			end
		end

		choicesholder:SetTall(y)
		choicesholder:MoveAbove(textholder, 8)
	end

	local closebutton = vgui.Create("DImageButton", window)
	closebutton:SetImage("gui/silkicons/check_off")
	closebutton:SizeToContents()
	closebutton.DoClick = CloseDoClick
	closebutton:AlignTop()
	closebutton:AlignRight()

	window:SetPos(ScrW() * 0.5 - window:GetWide() * 0.5, ScrH() - window:GetTall() - 32)
	--window:MakePopup()
end

function convo.CloseFrame()
	if ActiveConvoFrame and ActiveConvoFrame:Valid() then
		ActiveConvoFrame:Remove()
	end

	ActiveConvoFrame = nil
end

net.Receive("rpg_convo_upd", function(len)
	local ent = net.ReadEntity()
	local text = net.ReadString()
	local choices = net.ReadTable()

	convo.CreateConvoFrame(ent, text, choices)
end)
