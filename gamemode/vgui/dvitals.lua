local PANEL = {}

PANEL.m_Entity = NULL

local colHealth = Color(255, 0, 0, 255)
local colMana = Color(0, 160, 255, 255)
--local colStamina = Color(255, 255, 0, 255)
function PANEL:Init()
	self.m_HealthBar = vgui.Create("ProgressBar", self)
	self.m_HealthBar:SetColor(colHealth)

	self.m_ManaBar = vgui.Create("ProgressBar", self)
	self.m_ManaBar:SetColor(colMana)

	--[[self.m_StaminaBar = vgui.Create("ProgressBar", self)
	self.m_StaminaBar:SetColor(colStamina)]]

	self:InvalidateLayout()
end

function PANEL:Think()
	local ent = self:GetEntity()
	if ent:IsValid() then
		self.m_HealthBar:SetMaxProgress(ent:GetMaxHealth())
		self.m_ManaBar:SetMaxProgress(ent:GetMaxMana())
		--self.m_StaminaBar:SetMaxProgress(ent:GetMaxStamina())

		if ent:Alive() then
			self.m_HealthBar:SetProgress(ent:Health())
			self.m_ManaBar:SetProgress(ent:GetMana())
			--self.m_StaminaBar:SetProgress(ent:GetStamina())
		else
			self.m_HealthBar:SetProgress(0)
			self.m_ManaBar:SetProgress(0)
			--self.m_StaminaBar:SetProgress(0)
		end
	end
end

function PANEL:Paint()
end

function PANEL:PerformLayout()
	local wid, hei = self:GetSize()

	self.m_HealthBar:SetSize(wid - 16, 18)
	self.m_HealthBar:CenterHorizontal()
	self.m_HealthBar:AlignTop(24)

	self.m_ManaBar:SetSize(self.m_HealthBar:GetWide(), math.ceil(self.m_HealthBar:GetTall() * 0.75))
	self.m_ManaBar:CenterHorizontal()
	self.m_ManaBar:MoveBelow(self.m_HealthBar, 2)

	--[[self.m_StaminaBar:SetSize(self.m_HealthBar:GetWide(), self.m_ManaBar:GetTall())
	self.m_StaminaBar:CenterHorizontal()
	self.m_StaminaBar:MoveBelow(self.m_ManaBar, 2)]]
end

function PANEL:SetEntity(ent)
	self.m_Entity = ent
end

function PANEL:GetEntity()
	return self.m_Entity
end

vgui.Register("DVitals", PANEL, "DPersistFrame")
