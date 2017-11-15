function draw.WordBox(text, font, x, y, col, colbg, xalign, yalign, borderradius, xpadding, ypadding)
	borderradius = borderradius or 8
	xpadding = xpadding or 16
	ypadding = ypadding or 8

	surface.SetFont(font)
	local textw, texth = surface.GetTextSize(text)

	local totalw, totalh = textw + xpadding * 2, texth + ypadding * 2

	if xalign == TEXT_ALIGN_CENTER then
		x = x - totalw * 0.5
	elseif xalign == TEXT_ALIGN_RIGHT then
		x = x - totalw
	end

	if yalign == TEXT_ALIGN_CENTER then
		y = y - totalh * 0.5
	elseif yalign == TEXT_ALIGN_BOTTOM then
		y = y - totalh
	end

	draw.RoundedBox(borderradius, x, y, totalw, totalh, colbg)

	surface.SetTextColor(col.r, col.g, col.b, col.a)
	surface.SetTextPos(x + xpadding, y + ypadding)
	surface.DrawText(text)
end

function WordBox(parent, text, font, textcolor)
	local cpanel = vgui.Create("DPanel", parent)
	local label = EasyLabel(cpanel, text, font, textcolor)
	local tsizex, tsizey = label:GetSize()
	cpanel:SetSize(tsizex + 16, tsizey + 8)
	label:SetPos(8, (tsizey + 8) * 0.5 - tsizey * 0.5)
	cpanel:SetVisible(true)
	cpanel:SetMouseInputEnabled(false)
	cpanel:SetKeyboardInputEnabled(false)

	return cpanel
end

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "Default")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end

function GM:ForceDermaSkin()
	return "noxiousrpg"
end

local surface = surface
local draw = draw
local Color = Color

local SKIN = {}

SKIN.PrintName = "Zombie Survival Derma Skin"
SKIN.Author = "William \"JetBoom\" Moodhe"
SKIN.DermaVersion = 1

SKIN.bg_color_dark = Color(2, 2, 2, 120)
SKIN.bg_color_sleep = Color(10, 10, 10, 120)
SKIN.bg_color = Color(30, 30, 30, 180)
SKIN.bg_color_bright = Color(40, 40, 40, 120)
SKIN.frame_border = Color(50, 50, 50, 120)
SKIN.frame_title = Color(50, 50, 50, 120)

SKIN.font						= "rpg_derma_default"
SKIN.fontSmall					= "rpg_derma_small"
SKIN.fontTooltip				= "Default"
DEFAULTFONT = SKIN.font

SKIN.fontFrame					= SKIN.font

SKIN.control_color 				= Color( 30, 30, 30, 120 )
SKIN.control_color_highlight	= Color( 45, 45, 250, 120 )
SKIN.control_color_active 		= Color( 100, 95, 30, 120 )
SKIN.control_color_bright 		= Color( 50, 50, 50, 120 )
SKIN.control_color_dark 		= Color( 0, 0, 0, 120 )

SKIN.bg_alt1 					= Color( 20, 20, 20, 120 )
SKIN.bg_alt2 					= Color( 25, 25, 25, 120 )

SKIN.listview_hover				= Color( 70, 70, 70, 255 )
SKIN.listview_selected			= Color( 100, 170, 220, 255 )

SKIN.text_bright				= Color( 255, 255, 255, 255 )
SKIN.text_normal				= Color( 240, 240, 240, 255 )
SKIN.text_dark					= Color( 170, 170, 170, 255 )
SKIN.text_highlight				= Color( 255, 180, 20, 255 )

SKIN.texGradientUp				= Material( "gui/gradient_up" )
SKIN.texGradientDown			= Material( "gui/gradient_down" )

SKIN.combobox_selected			= SKIN.listview_selected

SKIN.panel_transback			= Color( 25, 25, 25, 90 )
SKIN.tooltip					= Color( 20, 20, 20, 220 )
SKIN.tooltip2					= Color( 120, 120, 120, 220 )

SKIN.colPropertySheet 			= SKIN.control_color_dark
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabInactive				= Color( 140, 140, 140, 255 )
SKIN.colTabShadow				= Color( 0, 0, 0, 170 )
SKIN.colTabText		 			= Color( 255, 255, 255, 255 )
SKIN.colTabTextInactive			= Color( 0, 0, 0, 200 )
SKIN.fontTab					= "rpg_derma_default"

SKIN.colCollapsibleCategory		= Color( 255, 255, 255, 20 )

SKIN.colCategoryText			= Color( 255, 255, 255, 255 )
SKIN.colCategoryTextInactive	= Color( 200, 200, 200, 255 )
SKIN.fontCategoryHeader			= "rpg_derma_default"

SKIN.colNumberWangBG			= Color( 255, 240, 150, 255 )
SKIN.colTextEntryBG				= Color( 240, 240, 240, 255 )
SKIN.colTextEntryBorder			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryText			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )
SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )

SKIN.colMenuBG					= Color( 255, 255, 255, 200 )
SKIN.colMenuBorder				= Color( 0, 0, 0, 200 )

SKIN.colButtonText				= Color( 255, 255, 255, 255 )
SKIN.colButtonTextDisabled		= Color( 255, 255, 255, 55 )
SKIN.colButtonBorder			= Color( 20, 20, 20, 255 )
SKIN.colButtonBorderHighlight	= Color( 255, 255, 255, 50 )
SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 100 )
SKIN.fontButton					= "rpg_derma_default"

function SKIN:PaintFrame(panel)
	draw.RoundedBox(4, 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color)
	--[[draw.RoundedBox(4, 0, 0, panel:GetWide(), panel:GetTall(), self.frame_border)
	draw.RoundedBox(4, 1, 1, panel:GetWide()-2, panel:GetTall()-2, self.frame_title)
	draw.RoundedBoxEx(4, 2, 21, panel:GetWide()-4, panel:GetTall()-23, self.bg_color, false, false, true, true)]]
end

function SKIN:PaintTooltip(panel)
	local w, h = panel:GetSize()

	DisableClipping(true)

	surface.SetDrawColor(self.tooltip)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self.tooltip2)
	surface.DrawOutlinedRect(0, 0, w, h)
	--self:DrawGenericBackground(0, 0, w, h, self.tooltip)
	panel:DrawArrow(0, 0)

	DisableClipping(false)
end

function SKIN:DrawGenericBackground(x, y, w, h, color)
	draw.RoundedBox(8, x, y, w, h, color)
end

--[[function SKIN:SchemeLabel(panel)
	if not panel.m_AppliedRPGFont then
		panel.m_AppliedRPGFont = true
		panel:SetFont(self.font)
	end

	derma.GetNamedSkin("Default"):SchemeLabel(panel)
end]]

derma.DefineSkin("noxiousrpg", "The default Derma skin for NoXious RPG", SKIN, "Default")

local oldsetcontents = DTooltip.SetContents
function DTooltip:SetContents(panel, bDelete)
	oldsetcontents(self, panel, bDelete)

	local contents = self.Contents
	if contents and contents:Valid() then
		if contents.SetTextColor then
			contents:SetTextColor(SKIN.text_normal)
		end
		if contents.SetFont then
			contents:SetFont(SKIN.fontTooltip)
			contents:SizeToContents()
			self:InvalidateLayout(true)
		end
	end
end
