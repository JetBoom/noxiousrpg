pContainer = {}

local function Waiting(uid, endtime)
	if Items[uid] then
		MakepContainer(Items[uid])
	end

	if CurTime() >= endtime or Items[uid] then
		timer.Remove("waitingforcontainer"..uid)
	end
end

function WaitMakepContainer(uid, maxdelay)
	maxdelay = maxdelay or 5

	timer.Create("waitingforcontainer"..uid, 0, 0, function() Waiting(uid, CurTime() + maxdelay) end)
end

function MakepContainer(container)
	if not container or not container:IsContainer() then return end

	--local ent = container:GetRootEntity()

	local curx, cury
	local openpan = pContainer[container.ID]
	if openpan and openpan:IsValid() then
		curx, cury = openpan:GetPos()
		openpan:SetDeleteOnClose(true)
		openpan:Close()
	end

	local wid, hei = 400, 420

	local window = vgui.Create("DFrame")
	pContainer[container.ID] = window
	window:SetDeleteOnClose(false)
	window:SetSize(wid, hei)
	window:SetScreenLock(true)
	if curx then
		window:SetPos(curx, cury)
	else
		window:Center()
	end

	--[[local title = container:GetDisplayName()
	if ent:IsValid() then
		if ent == MySelf then
			title = title.." owned by you"
		elseif ent:IsPlayer() then
			title = title.." owned by "..ent:RPGName(MySelf)
		end
	end
	window:SetTitle(title)]]
	window:SetTitle(container:GetDisplayName())

	local goldpanel = WordBox(window, "Gold: "..container:ItemAmountNonStrict("gold"), "rpg_derma_small", COLOR_YELLOW)
	goldpanel:SetPos(8, 64 - goldpanel:GetTall())

	local capacity = container:GetCapacity()
	if capacity and capacity ~= -1 then
		local count = container:TotalItemObjectCount()
		local capacitypanel = WordBox(window, "Items: "..count.." / "..capacity, "rpg_derma_small", count >= capacity and COLOR_RED or count >= capacity * 0.75 and COLOR_YELLOW or color_white)
		capacitypanel:SetPos(window:GetWide() - capacitypanel:GetWide() - 8, 64 - capacitypanel:GetTall())
	end

	local containerpanel = vgui.Create("DContainer", window)
	containerpanel:SetPos(8, 72)
	local cwid, chei = wid - 16, hei - 80
	containerpanel:SetSize(cwid, chei)
	containerpanel:SetContainer(container)
	window.Container = containerpanel

	--window:MakePopup()
	window:SetVisible(true)
end

local PANEL = {}

PANEL.m_ItemPanels = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
end

function PANEL:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		local itempanel = GetActiveItemPanel()
		if itempanel and itempanel:IsValid() and itempanel:IsVisible() then
			itempanel:ContainerPanelClicked(self)
		end
	end
end

function PANEL:GetItemPanels()
	return self.m_ItemPanels
end

function PANEL:ContainsItemPanel(panel)
	return table.HasValue(self:GetItemPanels(), panel)
end

function PANEL:ContainsItem(item)
	for k, v in pairs(self:GetItemPanels()) do
		if v:GetItem() == item then
			return true
		end
	end
end

function PANEL:AddItemPanel(panel)
	local itempanels = self:GetItemPanels()
	if not table.HasValue(itempanels, panel) then
		table.insert(itempanels, panel)
		panel:SetContainer(self)
	end
end

function PANEL:RemoveItemPanel(panel, dontremove)
	local itempanels = self:GetItemPanels()

	for k, v in ipairs(itempanels) do
		if v == panel then
			table.remove(itempanels, k)

			if dontremove then
				panel:SetContainer(nil)
			else
				panel:Remove()
			end
		end
	end
end

function PANEL:ClearItemPanels()
	for _, panel in pairs(self:GetItemPanels()) do
		panel:Remove()
	end

	self.m_ItemPanels = {}
end

function PANEL:SetContainer(container)
	if not container or Item.IsItem(container) then
		self.m_Container = container
	end

	self:RefreshContents()
end

function PANEL:GetContainer()
	return self.m_Container
end

function PANEL:RefreshContents()
	self:ClearItemPanels()

	local container = self:GetContainer()
	if Item.IsItem(container) then
		for _, child in pairs(container:GetChildren(true)) do
			self:AddItemPanel(child:ItemPanel())
		end
	end
end

function PANEL:Paint()
	local wid, hei = self:GetSize()

	surface.SetDrawColor(0, 0, 0, 90)
	surface.DrawRect(0, 0, wid, hei)
	surface.SetDrawColor(90, 90, 90, 90)
	surface.DrawOutlinedRect(0, 0, wid, hei)
end

vgui.Register("DContainer", PANEL, "DPanel")
