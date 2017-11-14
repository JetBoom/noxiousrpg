function MakepSkills(ent)
	if ent and ent:IsValid() and ent.Skills then
		if ent.m_SkillPanel and ent.m_SkillPanel:Valid() then
			ent.m_SkillPanel:SetVisible(true)
		else
			local panel = vgui.Create("DSkills")
			panel:SetSize(math.min(w - 16, 300), math.min(h - 16, 420))
			panel:Center()
			panel:SetEntity(ent)
		end
	end
end

local PANEL = {}
PANEL.m_Entity = NULL
function PANEL:Init()
	self:SetDraggable(true)
	self:SetDeleteOnClose(true)
	self:SetTitle(" ")
	self:SetScreenLock(true)

	self.m_HeadingLabel = EasyLabel(self, "Skills", DEFAULTFONT, COLOR_YELLOW)

	local list = vgui.Create("DPanelList", self)
	list:SetPadding(2)
	list:SetSpacing(2)
	list:EnableVerticalScrollbar(true)
	self.m_SkillPanelList = list

	for i, skilltab in ipairs(SKILLS) do
		local skillpanel = vgui.Create("DSkillPanel", list)
		skillpanel:SetSkillID(i)
		skillpanel:SetTall(40)
		list:AddItem(skillpanel)
	end
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)

	local wid, hei = self:GetSize()

	local y = 8
	self.m_HeadingLabel:SetPos(wid * 0.5 - self.m_HeadingLabel:GetWide() * 0.5, y)
	y = y + self.m_HeadingLabel:GetTall() + 8

	self.m_SkillPanelList:SetPos(8, y)
	self.m_SkillPanelList:SetSize(wid - 16, hei - y - 8)
end

function PANEL:SetEntity(ent)
	if ent:IsValid() and ent.Skills then
		self.m_Entity = ent
		ent.m_SkillPanel = self
		for _, item in pairs(self.m_SkillPanelList:GetItems()) do
			if item.SetUpdateEntity then
				item:SetUpdateEntity(ent)
			end
		end
	end
end

function PANEL:GetEntity()
	return self.m_Entity or NULL
end
vgui.Register("DSkills", PANEL, "DFrame")

local PANEL = {}
PANEL.m_Entity = NULL
function PANEL:Init()
	self.m_ProgressBar = vgui.Create("ProgressBar", self)
	self.m_ProgressBar:SetMaxProgress(SKILLS_MAX)

	self.m_SkillNameLabel = EasyLabel(self, "Skill", DEFAULTFONT)
	self.m_SkillAmountLabel = EasyLabel(self, "0.0", DEFAULTFONT)

	self:SetSkillID(SKILL_STRENGTH)
	self:SetSkillAmount(0)

	self:InvalidateLayout()
end

function PANEL:UpdateSkill()
	local amount = self:GetSkillAmount()

	self.m_ProgressBar:SetProgress(amount)

	self.m_SkillAmountLabel:SetText(math.floor(amount * 100) * 0.01)
	self.m_SkillAmountLabel:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)

	local wid, hei = self:GetSize()

	self.m_SkillNameLabel:SetPos(4, 4)
	self.m_SkillAmountLabel:SetPos(wid - 4 - self.m_SkillAmountLabel:GetWide(), 4)

	self.m_ProgressBar:SetSize(wid - 8, math.max(2, math.min(16, hei - 10 - self.m_SkillNameLabel:GetTall())))
	self.m_ProgressBar:SetPos(4, hei - 4 - self.m_ProgressBar:GetTall())
end

function PANEL:SetUpdateEntity(ent)
	if ent and (not ent:IsValid() or ent.GetSkill) then
		self.m_Entity = ent
	end
end

function PANEL:ClearUpdateEntity()
	self:SetUpdateEntity(NULL)
end

function PANEL:GetUpdateEntity()
	return self.m_Entity or NULL
end

function PANEL:SetSkillID(id)
	if SKILLS[id] then
		self.m_SkillID = id

		self.m_SkillNameLabel:SetText(SKILLS[id].Name)
		self.m_SkillNameLabel:SizeToContents()

		self:SetTooltip(SKILLS[id].Description)

		self:InvalidateLayout()
	end
end

function PANEL:GetSkillID()
	return self.m_SkillID or 1
end

function PANEL:SetSkillAmount(amount)
	self.m_SkillAmount = amount

	self:UpdateSkill()
end

function PANEL:GetSkillAmount()
	return self.m_SkillAmount
end

function PANEL:Think()
	local ent = self:GetUpdateEntity()
	if ent:IsValid() and ent.GetSkill then
		local skill = ent:GetSkill(self:GetSkillID())
		if skill ~= self:GetSkillAmount() then
			self:SetSkillAmount(skill)
		end
	end
end
vgui.Register("DSkillPanel", PANEL, "DPanel")
