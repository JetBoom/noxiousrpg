GM.HotBars = {}
GM.HotBarKeyCombos = {0, IN_SPEED, IN_WALK, IN_SPEED + IN_WALK}
for k, v in pairs(GM.HotBarKeyCombos) do
	GM.HotBars[v] = {}
end

function GM:CreateHotBar()
	if self.HotBar and self.HotBar:Valid() then
		self.HotBar:Remove()
		self.HotBar = nil
	end

	local screenscale = BetterScreenScale()

	local window = vgui.Create("DHotBar")
	window:SetSize(screenscale * 32 * HOTBAR_CELLCOUNT, screenscale * 32)
	window:AlignBottom(screenscale * 32)
	window:CenterHorizontal()

	self.HotBar = window

	--[[for i=1, 10 do
		local pan = vgui.Create("DPanel", window)
		pan:SetSize(cellsize, cellsize)
		pan:SetPos(x, 8)
		window.Cells[i] = pan

		local celldata = HotBars[curset][i]
		if celldata then
			if celldata.Type == HOTBAR_CELLTYPE_ITEMDATANAME then
				local dataname = celldata.DataName
				if dataname then
					local itemdata = ItemData(itemordataname)
					if itemdata then
						local mdl = itemdata.Model
						if mdl and util.IsValidModel(mdl) then
							local mdlpanel = vgui.Create("DModelPanel", pan)
							mdlpanel:SetSize(cellsize, cellsize)
							mdlpanel:SetModel(mdl)
							local PrevMins, PrevMaxs = mdlpanel.Entity:GetRenderBounds()
							mdlpanel:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.75, 0.75, 0.5))
							mdlpanel:SetLookAt((PrevMaxs + PrevMins) / 2)
							pan:SetTooltip(util.NameByAmount(itemdata.Name, itemdata.Amount))
						end
					end
				else
					HotBars[curset][i] = nil
				end
			elseif celldata.Type == HOTBAR_CELLTYPE_SPELL then
				-- TODO
			end
		end

		x = x + pan:GetWide() + 8
	end

	window:SetWide(x)

	window:SetPos(w * 0.5 - window:GetWide() * 0.5, h - window:GetTall() - screenscale * 64)]]
end

function GM:LoadHotBars()
	if file.Exists("noxiousrpg_hotbars.txt") then
		self.HotBars = Deserialize(file.Read("noxiousrpg_hotbars.txt"))
	end
end

function GM:SaveHotBars()
	file.Write("noxiousrpg_hotbars.txt", Serialize(self.HotBars))
end

local PANEL = {}

function PANEL:Init()
	self.HotBarCells = {}

	self:Refresh()
end

function PANEL:Paint()
	local wid, hei = self:GetSize()

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, 0, wid, hei)
	surface.SetDrawColor(90, 90, 10, 180)
	surface.DrawOutlinedRect(0, 0, wid, hei)
	surface.SetDrawColor(75, 75, 8, 180)
	surface.DrawOutlinedRect(1, 1, wid - 2, hei - 2)
	surface.SetDrawColor(60, 60, 6, 180)
	surface.DrawOutlinedRect(2, 2, wid - 4, hei - 4)

	return true
end

function PANEL:GetKeyCombo()
	if MySelf:IsValid() then
		if MySelf:KeyDown(IN_SPEED) then
			if MySelf:KeyDown(IN_WALK) then
				return IN_SPEED + IN_WALK
			else
				return IN_SPEED
			end
		elseif MySelf:KeyDown(IN_WALK) then
			return IN_WALK
		end
	end

	return 0
end

function PANEL:Refresh(keycombo)
	keycombo = keycombo or self:GetKeyCombo()

	local hotbarset = GAMEMODE.HotBars[keycombo]
	if not hotbarset then return end

	self.m_CurrentKeyCombo = keycombo

	for i, panel in pairs(self.HotBarCells) do
		panel:Remove()
	end

	self.HotBarCells = {}

	local cellsize = self:GetTall()

	for i=1, HOTBAR_CELLCOUNT do
		-- TODO
		--hotbarset[i].Command, .Type, .SpellID, .Model, .Image, .Label, etc.
		local button = vgui.Create("DHotBarCell", self)
		button:SetSize(cellsize, cellsize)
		button:SetPos((i - 1) * cellsize, 0)

		self.HotBarCells[i] = button
	end
end

function PANEL:Think()
	local keycombo = self:GetKeyCombo()
	if self.m_CurrentKeyCombo ~= keycombo then
		self:Refresh()
	end
end

function PANEL:HotBarPressed(i)
	local cell = self.HotBarCells[i]
	if cell and cell:Valid() then
		cell:DoClick()
	end
end

vgui.Register("DHotBar", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:SetText(" ")
end

function PANEL:Paint()
	return true
end

function PANEL:DoClick()
	
end

vgui.Register("DHotBarCell", PANEL, "DButton")
