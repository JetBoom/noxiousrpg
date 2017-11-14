ITEM.Name = "container"
ITEM.Model = Model("models/props_junk/wood_crate001a.mdl")
ITEM.Mass = 15
ITEM.MaxStack = 1
ITEM.ItemCapacity = 30

if SERVER then
	function ITEM:OnCreated()
		self.Container = {}
	end

	function ITEM:OnUse(pl)
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
		local curpanel = pContainer[self.ID]
		if curpanel and curpanel:IsValid() and curpanel:IsVisible() then
			curpanel:Close()
		else
			RunConsoleCommand("rpg_requestitem", self.ID)
			MakepContainer(self)
		end
	end

	ENT.ContextMenuOptions = {
		"Open",
		function(btn)
			local ent = btn.Entity
			if IsValid(ent) then
				RunConsoleCommand("rpg_requestitem", ent:GetItemUID())
				if ent:GetContainer() then
					MakepContainer(ent:GetContainer())
				else
					WaitMakepContainer(ent:GetItemUID())
				end
			end
		end
	}
end
