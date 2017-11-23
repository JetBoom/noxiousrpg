function ItemPanel(item, parent)
	local panel = vgui.Create("DItemPanel", parent)
	panel:SetItem(item)

	return panel
end
MakeItemPanel = ItemPanel
CreateItemPanel = ItemPanel

hook.Add("GUIMouseReleased", "pItemGUIMouseReleased", function(mc)
	if Dragging and mc == MOUSE_LEFT then
		if Dragging:Valid() and Dragging:IsVisible() then
			Dragging:OnMouseReleased(mc)
		else
			Dragging = nil
		end
	end
end)

local ActiveItemPanel

function GetActiveItemPanel()
	return ActiveItemPanel
end

function SetActiveItemPanel(panel)
	local active = GetActiveItemPanel()
	if active == panel then return end

	if active and active:Valid() then
		active:Deactivated()
	end

	if panel and panel:Valid() then
		panel:Activated()
	end

	ActiveItemPanel = panel
end

local PANEL = {}

function PANEL:Init()
	self:SetMoveable(true)

	self:SetMouseInputEnabled(true)
	self:SetSize(64, 64)

	local modelpanel = vgui.Create("DModelPanel2", self)
	modelpanel:SetSize(self:GetSize())
	modelpanel:SetAnimated(false)
	modelpanel:SetFOV(90)
	self:SetModelPanel(modelpanel)

	self:InvalidateLayout()
end

function PANEL:Paint()
	if self:IsActive() then
		local x = self:GetWide() * 0.5
		local y = self:GetTall() * 0.5
		local rt = RealTime()
		for i=1, 2, 0.25 do
			local radius = (rt + i) % 1
			surface.DrawCircle(x, y, x * radius, Color(255, 255, 255, (1 - radius) * 70))
		end
	end
end

function PANEL:ContainerPanelClicked(containerpanel)
	local item = self:GetItem()
	local container = containerpanel:GetContainer()
	if Item.IsItem(item) and Item.IsItem(container) and item:GetParent() ~= container then
		local cx, cy = containerpanel:CursorPos()
		if MySelf:TransferItem(item, container, cx - self:GetWide() * 0.5, cy - self:GetTall() * 0.5) then
			surface.PlaySound("buttons/lever8.wav")
			--SetActiveItemPanel(nil)
			RunConsoleCommand("rpg_transferitem", item.ID, container.ID)
		else
			surface.PlaySound("buttons/button8.wav")
		end
	end
end

function PANEL:PerformLayout()
	local modelpanel = self:GetModelPanel()
	if modelpanel then
		modelpanel:SetSize(self:GetSize())
		modelpanel:SetMouseInputEnabled(false)
	end
end

function PANEL:SetItem(item)
	self.m_Item = item

	self:RefreshAll()
end

function PANEL:GetItem()
	return self.m_Item
end

function PANEL:SetModelPanel(modelpanel)
	modelpanel:SetParent(self)
	modelpanel:SetPos(0, 0)
	modelpanel:SetMouseInputEnabled(false)
	self.m_ModelPanel = modelpanel

	self:InvalidateLayout()
end

function PANEL:GetModelPanel()
	return self.m_ModelPanel
end

function PANEL:GetItem()
	return self.m_Item
end

function PANEL:SetMoveable(moveable)
	self.m_Moveable = moveable
	if not moveable then
		self:OnMouseReleased(MOUSE_LEFT)
	end
end

function PANEL:GetMoveable()
	return self.m_Moveable
end
PANEL.IsMoveable = PANEL.GetMoveable

function PANEL:GetItemData()
	local item = self:GetItem()
	if item then return item:GetItemData() end
end

function PANEL:Activated()
	surface.PlaySound("buttons/lightswitch2.wav")
end

function PANEL:Deactivated()
	--surface.PlaySound("buttons/lightswitch2.wav")
end

function PANEL:Activate()
	SetActiveItemPanel(self)
end

function PANEL:Deactivate()
	if self:IsActive() then
		SetActiveItemPanel(nil)
	end
end

function PANEL:IsActive()
	return GetActiveItemPanel() == self
end

function PANEL:ToggleActive()
	if self:IsActive() then
		self:Deactivate()
	else
		self:Activate()
	end
end

function PANEL:OnMousePressed(mc)
	DEBUG(tostring(self)..":OnMousePressed("..tostring(mc)..")")
	if mc == MOUSE_LEFT and not self.MouseIn then
		if self.LastMouseRelease and SysTime() <= self.LastMouseRelease + 0.3 then
			self:OnMouseDoublePressed()
		else --if self:GetMoveable() then
			self.OldX, self.OldY = self:GetPos()
			self.MouseIn = true
			self.MoveX, self.MoveY = self:GetParent():CursorPos()
			self.LocalX, self.LocalY = self:CursorPos()

			self:ToggleActive()
		end
	elseif mc == MOUSE_RIGHT then
		local item = self:GetItem()
		local itemdata = self:GetItemData()
		if itemdata and not (itemdata.OnRightClick and itemdata.OnRightClick(item)) and itemdata.RightClickMenu then
			if self.DMenu and self.DMenu:Valid() then
				self.DMenu:Remove()
				self.DMenu = nil
			end

			local menu = DermaMenu()
			menu:SetPos(MousePos())
			for i = 1, #itemdata.RightClickMenu, 2 do
				if menu:AddOption(self.RightClickMenu[i], self.RightClickMenu[i + 1]) then
					local menuoption = menu.Panels[#menu.Panels]
					menuoption.Item = self:GetItem()
					menuoption.ItemData = itemdata
				end
			end
			menu:AddSpacer()
			menu:AddOption("Do nothing")
			menu:MakePopup()
			self.DMenu = menu
		end
	end
end

function PANEL:OnMouseDoublePressed()
	self:Deactivate()

	local item = self:GetItem()
	PrintTable(item)
	if item then
		local itemdata = self:GetItemData()
		if itemdata.OnMouseDoublePressed and itemdata.OnMouseDoublePressed(item, self) then
			return
		end

		if item:IsUsable() then
			if itemdata.OnUse then
				itemdata.OnUse(item, MySelf)
			end
			RunConsoleCommand("rpg_useitem", item.ID)
			DEBUG("Use itemid "..tostring(item))
		end
	end
end

function PANEL:OnMouseReleased(mc)
	if mc == MOUSE_LEFT and self.MouseIn then
		self.MouseIn = nil

		self:SetDragging(false)

		self.OldX = nil
		self.OldY = nil
		self.LocalX = nil
		self.LocalY = nil

		self.LastMouseRelease = SysTime()
	end
end

local function AskDropCancelDoClick(self)
	self:GetParent():Close()
end

local function AskDropOKDoClick(self)
	local item = self:GetParent().Item
	if item then
		RunConsoleCommand("rpg_dropitem", item.ID, self.NumberWang:GetValue())
	end
	self:GetParent():Close()
end

function PANEL:AskDropAmount()
	local item = self:GetItem()
	if not item then return end

	local wid = 128

	local frame = vgui.Create("DFrame")
	frame:SetTitle("Drop how many "..item:GetDisplayName().."?")
	frame:SetWide(wid)
	frame:SetPos(MousePos())
	frame:SetDeleteOnClose(true)
	frame.Item = item

	local y = 24

	local numberwang = vgui.Create("DNumberWang", frame)
	numberwang:SetDecimals(0)
	numberwang:SetValue(1) --numberwang:SetValue(self.ItemData.Amount)
	numberwang:SetMin(1)
	numberwang:SetMax(item:GetAmount())
	numberwang:SizeToContentsY()
	numberwang:SetWide(wid - 16)
	numberwang:SetPos(8, y)
	y = y + numberwang:GetTall() + 8

	local cancelbutton = EasyButton(frame, "Cancel", 8, 4)
	cancelbutton.DoClick = AskDropCancelDoClick

	local okbutton = EasyButton(frame, "Drop", 8, 4)
	okbutton:SetWide(cancelbutton:GetWide())
	okbutton.DoClick = AskDropOKDoClick
	okbutton.NumberWang = numberwang

	okbutton:SetPos(8, y)
	cancelbutton:SetPos(frame:GetWide() - 8 - cancelbutton:GetWide(), y)
	y = y + cancelbutton:GetTall() + 8

	frame:SetTall(y)
	frame:MakePopup()
end

function PANEL:GetDragging()
	return Dragging == self
end
PANEL.IsDragging = PANEL.GetDragging

function PANEL:SetDragging(drag)
	if self:IsDragging() == drag then return end

	if drag then
		self:Activate()

		EndTooltip()

		Dragging = self
	else
		self:Deactivate()

		Dragging = nil

		self.MoveX = nil
		self.MoveY = nil

		local item = self:GetItem()
		if not item then return end

		local x, y = self:GetParent():CursorPos()
		x = x - self.LocalX
		y = y - self.LocalY

		local wid, hei = self:GetSize()
		local parentwid, parenthei = self:GetParent():GetSize()
		if x < -48 or x > parentwid + 48 or y > parenthei + 48 or y < -48 then
			if item:IsDroppableBy(MySelf) then
				if item:GetAmount() > 1 and (input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) then
					self:AskDropAmount()
				else
					RunConsoleCommand("rpg_dropitem", item.ID, item:GetAmount())
				end
			end
		elseif MySelf:MoveItem(item, x, y) then
			RunConsoleCommand("rpg_moveitem", item.ID, x, y)
		end

		self:RefreshPosition()
	end
end

function PANEL:SetContainer(panel)
	self:SetParent(panel)
	self:RefreshPosition()
end

function PANEL:RefreshPosition()
	local item = self:GetItem()
	if not item then return end
	local x = item.X or 0
	local y = item.Y or 0

	local parent = self:GetParent()
	if not parent or not parent:Valid() then return self:SetPos(x, y) end

	return self:SetPos(math.Clamp(x, 0, parent:GetWide() - self:GetWide()), math.Clamp(y, 0, parent:GetTall() - self:GetTall()))
end

function PANEL:Think()
	local item = self:GetItem()
	if not item then self:Remove() return end

	if self.MouseIn then
		local x, y = self:GetParent():CursorPos()
		x = x - self.LocalX
		y = y - self.LocalY
		if not self:IsDragging() and (math.abs(x - self.OldX) > 8 or math.abs(y - self.OldY) > 8) then
			self:SetDragging(true)
		else
			self.MoveX = x
			self.MoveY = y
		end

		if self:IsDragging() then
			self:SetPos(x, y)
		end
	end

	if item.WearableSlot then
		if item:GetEntity():IsValid() then
			if not self.m_EntityIcon then
				self.m_EntityIcon = vgui.Create("DImage", self)
				self.m_EntityIcon:SetImage("gui/silkicons/add")
				self.m_EntityIcon:SizeToContents()
			end
		elseif self.m_EntityIcon then
			self.m_EntityIcon:Remove()
			self.m_EntityIcon = nil
		end
	end

	--[[if self:IsDragging() or self:IsActive() then
		local modelpanel = self:GetModelPanel()
		if not self.m_UndoDraggingColor then
			self.m_UndoDraggingColor = modelpanel:GetColor()
		end
		local light = 100 + 125 * math.abs(math.sin(CurTime() * 5))
		modelpanel:SetColor(Color(light, light, light, 255))
	elseif self.m_UndoDraggingColor then
		self:GetModelPanel():SetColor(self.m_UndoDraggingColor)
		self.m_UndoDraggingColor = nil
	end]]
end

function PANEL:RefreshModelPanel()
	local item = self:GetItem()
	if item then
		local modelpanel = self:GetModelPanel()
		modelpanel:SetModel(item:GetModel())
		modelpanel:AutoCam()
		if item.Material then
			modelpanel:SetMaterial(item.Material)
		end
		if item.Color then
			modelpanel:SetColor(item.Color)
		end
	end
end

function PANEL:RefreshAll()
	self:RefreshPosition()
	self:RefreshModelPanel()
	self:RefreshToolTip()
end

function PANEL:RefreshToolTip()
	self:SetToolTipPanel()
	self:SetToolTipPanel(self:GetItemToolTip())
end
PANEL.RefreshTooltip = PANEL.RefreshToolTip

local function CapW(panel, maxw)
	local x, y = panel:GetPos()
	return math.max(maxw, panel:GetWide() + x)
end

local function MultiplierLabel(panel, item, display, member)
	if not item[member] then return end

	local percentage = item[member]
	if percentage == 1 then return end

	local col
	local text = display.." - "

	if percentage < 1 then
		col = COLOR_RED
	else
		col = COLOR_LIMEGREEN
	end

	text = text .. percentage * 100 .. "%"

	local lab = EasyLabel(panel, text, DEFAULTFONT, col)

	return lab
end

local function MemberLabel(panel, item, display, member)
	if item[member] then
		return EasyLabel(panel, display.." - "..item[member], DEFAULTFONT)
	end
end

function PANEL:GetItemToolTip()
	local item = self:GetItem()
	if not item then return end

	local panel = vgui.Create("DPanel")
	panel:SetVisible(false)

	local panels = {}

	local maxw = 32

	local y = 4

	local titlelabel = EasyLabel(panel, "-- "..item:GetDisplayName().." --", DEFAULTFONT, item.DisplayColor or COLOR_WHITE)
	titlelabel:SetPos(0, y)
	y = y + titlelabel:GetTall()
	maxw = CapW(titlelabel, maxw)
	table.insert(panels, titlelabel)

	for i, tab in ipairs(ITEMDESCRIPTIONS_FUNCTIONS) do
		local func = tab[2]
		if func then
			local display = tab[1]

			local ret = func(panel, item)
			if ret then
				if type(ret) == "Panel" then
					ret:SetPos(0, y)
					y = y + ret:GetTall()
					maxw = CapW(ret, maxw)
					table.insert(panels, ret)
				else
					local lab = EasyLabel(panel, ret, DEFAULTFONT)
					if lab then
						lab:SetPos(0, y)
						y = y + lab:GetTall()
						maxw = CapW(lab, maxw)
						table.insert(panels, lab)
					end
				end
			end
		end
	end

	for i, tab in ipairs(ITEMDESCRIPTIONS_MEMBERS) do
		local lab = MemberLabel(panel, item, tab[1], tab[2])
		if lab then
			lab:SetPos(0, y)
			y = y + lab:GetTall()
			maxw = CapW(lab, maxw)
			table.insert(panels, lab)
		end
	end

	for i, tab in ipairs(ITEMDESCRIPTIONS_MULTIPLIER) do
		local lab = MultiplierLabel(panel, item, tab[1], tab[2])
		if lab then
			lab:SetPos(0, y)
			y = y + lab:GetTall()
			maxw = CapW(lab, maxw)
			table.insert(panels, lab)
		end
	end

	panel:SetSize(maxw + 8, y + 4)

	for _, p in pairs(panels) do
		p:CenterHorizontal()
	end

	return panel
end
PANEL.GetItemTooltip = PANEL.GetItemToolTip

vgui.Register("DItemPanel", PANEL, "Panel")
