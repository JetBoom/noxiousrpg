-- TODO: This is more like a holder for other things so you can save position, size, alpha, and anything else. This frame is only paints when the mouse is over it. It also has a transparency control (default 220, range 30 - 255).
-- You use vgui.Create("DPersistFrame"), set its signature, then call PANEL:Loaded() after you're done putting all the vgui elements on it.
-- This will call PANEL:PersistFrameLoaded(tab) on itself and then recursively call CHILD:PersistFrameLoaded(tab) (needs to be handled by that child) where tab is the table of data being loaded.
-- As for saving data, panels have the PANEL:GetPersistFrame() (first parent) and PANEL:GetRootPersistFrame() (highest parent) built in to them. They can use these to insert their data with PERSISTFRAME:SetKeyValue(key, value).
-- Each frame's data should be in a separate txt file. The table of data can have an optional expiration key which should be used for garbage or temporary stuff (inventory windows of other people). This is from os.time(). The game will delete these files on GM:Initialize() after checking for them.

local PANEL = {}

function PANEL:SetSignature(signature)
	self.m_Signature = signature
end

function PANEL:GetSignature()
	return self.m_Signature
end

function PANEL:Loaded()
end

function PANEL:PersistFrameLoaded(tab)
	if tab.x and tab.y then
		self:SetPos(math.Clamp(tab.x, 0, math.max(0, ScrW() - self:GetWide())), math.Clamp(tab.y, 0, math.max(0, ScrH() - self:GetTall())))
	end

	if tab.alpha then
		self:SetAlpha(tab.Alpha)
	end
end

function PANEL:SetKeyValue(key, value)
end

vgui.Register("DPersistFrame", PANEL, "DPanel")
