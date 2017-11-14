ENT.Type = "point"

ENT.Persist = true

function ENT:Initialize()
	if self.Disabled == nil then
		self.Disabled = false
	end
end

function ENT:OnSave(tab)
	tab.Disabled = self.Disabled
end

function ENT:OnLoaded(tab)
	self.Disabled = tab.Disabled
end
