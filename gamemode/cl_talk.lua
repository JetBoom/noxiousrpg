GM.TalkBubbles = {}
local TalkBubbles = GM.TalkBubbles

usermessage.Hook("playertalk", function(um)
	local ent = um:ReadEntity()
	local radius = um:ReadFloat()
	local text = um:ReadString()

	if not ent:IsValid() then return end

	ent:Talk(text)
end)

local scale = 0.25
local hscale = scale * 0.5
hook.Add("PostDrawOpaqueRenderables", "TalkPostDrawOpaqueRenderables", function()
	for ent, pan in pairs(TalkBubbles) do
		if not pan:Valid() then
			TalkBubbles[ent] = nil
		elseif ent:IsValid() then
			local mouthpos = ent:MouthPos()
			local ang = (EyePos() - mouthpos):Angle()
			local oldup = ang:Up()
			local oldright = ang:Right()

			ang:RotateAroundAxis(ang:Right(), 270)
			ang:RotateAroundAxis(ang:Up(), 90)
			cam.Start3D2D(mouthpos + oldup * (16 + scale * pan:GetTall()) + oldright * hscale * pan:GetWide(), ang, scale)
				pan:SetPaintedManually(false)
				pan:PaintManual()
				pan:SetPaintedManually(true)
			cam.End3D2D()
		end
	end
end)

local PANEL = {}

function PANEL:Init()
	self:SetStartTime(0)
	self:SetEndTime(0)
end

function PANEL:Think()
	local delta = self:GetEndTime() - CurTime()
	if delta < 1 then
		self:SetAlpha(math.max(0, delta) * 255)
	end
end

local colOutline = Color(40, 40, 40, 180)
function PANEL:Paint()
	draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), colOutline)
	return true
end

function PANEL:SetStartTime(time)
	self.m_StartTime = time
end

function PANEL:GetStartTime()
	return self.m_StartTime
end

function PANEL:SetEndTime(time)
	self.m_EndTime = time
end

function PANEL:GetEndTime()
	return self.m_EndTime
end

function PANEL:SetText(text, ent)
	local panel = NDB.CreateChatPanel(ent and ent:IsValid() and ent:EntIndex() or 0, text, COLOR_WHITE, COLOR_BLACK, "rpg_talk", 9999, true)
	if panel then
		panel:SetParent(self)
		panel:SetKeyboardInputEnabled(false)
		panel:SetMouseInputEnabled(false)
		self.m_TextPanel = panel

		self:SetSize(panel:GetWide() + 24, panel:GetTall() + 8)
		panel:Center()

		self:InvalidateLayout()
	end
end

function PANEL:PerformLayout()
	if self.m_TextPanel and self.m_TextPanel:Valid() then
		self.m_TextPanel:Center()
	end
end

vgui.Register("DTalkBubble", PANEL, "Panel")

local PANEL = {}

function PANEL:Init()
	self.m_List = {}

	self:SetWide(2048)

	self:SetRemoveOnEmpty(false)
end

function PANEL:SetRemoveOnEmpty(removeonempty)
	self.m_RemoveOnEmpty = removeonempty
end

function PANEL:GetRemoveOnEmpty()
	return self.m_RemoveOnEmpty
end

function PANEL:Think()
	for _, pan in pairs(self.m_List) do
		if CurTime() >= pan:GetEndTime() then
			self:RemovePanel(pan)
		end
	end
end

function PANEL:Paint()
	--[[surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(0, 0, self:GetSize())
	return true]]
end

local function sortlist(a, b)
	return a:GetStartTime() < b:GetStartTime()
end
function PANEL:SortList()
	table.sort(self.m_List, sortlist)

	local y = 0
	for i, pan in ipairs(self.m_List) do
		if pan:Valid() then
			local curx, cury = pan:GetPos()
			pan:MoveTo(curx, y, 0.2, 0, 0.05)
			--pan:SetPos(curx, y)
			y = y + pan:GetTall() + 8
		end
	end

	self:SetTall(y)
end

function PANEL:AddLine(text, ent)
	local pan = vgui.Create("DTalkBubble")
	pan:SetText(text, ent)
	pan:SetStartTime(CurTime())
	pan:SetEndTime(CurTime() + 5 + string.len(text) * 0.07)

	self:AddPanel(pan)
end

function PANEL:AddPanel(pan)
	table.insert(self.m_List, pan)

	pan:SetParent(self)

	pan:CenterHorizontal()

	self:SortList()
end

function PANEL:RemovePanel(pan)
	for i, p in ipairs(self.m_List) do
		if p == pan then
			table.remove(self.m_List, i)
			break
		end
	end

	if #self.m_List == 0 and self:GetRemoveOnEmpty() then
		self:Remove()
	else
		self:SortList()
	end
end

vgui.Register("DTalkBubbleLinkedList", PANEL, "Panel")
