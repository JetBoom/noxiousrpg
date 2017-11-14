function draw.DrawProgressBar(x, y, w, h, padding, progress, col, tex)
	surface.SetDrawColor(0, 0, 0, col.a)
	surface.DrawRect(x, y, w, h)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x, y, w, h)
	local dpadding = padding * 2
	if tex then
		surface.SetTexture(tex)
		surface.DrawTexturedRect(x + padding, y + padding, (w - dpadding) * math.Clamp(progress, 0, 1), h - dpadding)
	else
		surface.DrawRect(x + padding, y + padding, (w - dpadding) * math.Clamp(progress, 0, 1), h - dpadding)
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetProgress(0)
	self:SetMaxProgress(1)
	self:SetPadding(2)

	self:SetBackgroundColor(COLOR_BLACK)
	self:SetColor(COLOR_YELLOW)
end

function PANEL:SetPadding(padding)
	self.m_Padding = padding
end

function PANEL:GetPadding()
	return self.m_Padding
end

function PANEL:SetBackgroundColor(col)
	self.m_BackgroundColor = col
end

function PANEL:GetBackgroundColor()
	return self.m_BackgroundColor
end

function PANEL:SetTexture(tex)
	self.m_Texture = tex
end

function PANEL:GetTexture()
	return self.m_Texture
end

function PANEL:SetColor(col)
	self.m_Color = col
end

function PANEL:GetColor()
	return self.m_Color
end

function PANEL:Paint()
	draw.DrawProgressBar(0, 0, self:GetWide(), self:GetTall(), self:GetPadding(), math.Clamp(self:GetProgress() / self:GetMaxProgress(), 0, 1), self:GetColor(), self:GetTexture())

	return true
end

function PANEL:SetProgress(progress)
	self.m_Progress = progress
end

function PANEL:GetProgress()
	return self.m_Progress
end

function PANEL:SetMaxProgress(maxprogress)
	self.m_MaxProgress = maxprogress
end

function PANEL:GetMaxProgress()
	return self.m_MaxProgress
end

vgui.Register("ProgressBar", PANEL, "Panel")
