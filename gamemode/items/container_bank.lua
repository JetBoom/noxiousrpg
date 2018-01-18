ITEM.DataIndex = 10

-- The way this works is actually pretty simple.
-- When the player uses this item, an invisible container is created on top of us.
-- The player's Bank[zoneid] contents are then copied on to the container. If a virtual container already exists with the player's bank then it won't be allowed.
-- Any interactions done to the new virtual container are copied back on to the player's Bank[zoneid] table.
-- The virtual container is removed if the player goes too far from it or if the player isn't valid anymore.

ITEM.Name = "secure bank"
ITEM.Model = "models/Items/item_item_crate.mdl"
ITEM.Moveable = false
ITEM.MaxStack = 1

if SERVER then
	ENT.Model = ITEM.Model

	function ENT:Initialize()
		self:SetModel(self.Model)

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then phys:EnableMotion(false) phys:Wake() end
	end

	function ENT:Use(pl)
		local item = self:GetItem()
		if item then
			item:GetItemData().OnUse(item, pl)
		end
	end
end

function ENT:IsPersistent()
	return true
end

function ITEM:GetCapacity()
	return 25
end

if SERVER then
	local function Open(pl, ent)
		local itemuid = ent:GetItemUID()
		ent:GetItem():Sync(pl)
		pl:SendLua("WaitMakepContainer("..itemuid..")")
	end

	function ITEM:OnUse(pl)
		if pl.Banks then
			local zoneid = pl:GetZone()
			pl.Banks[zoneid] = pl.Banks[zoneid] or {}

			local uid = pl:UniqueID()
			for _, ent in pairs(ents.FindByClass("item_container_bankvirtual")) do
				if ent.m_PlayerUID == uid then
					Open(pl, ent)
					return
				end
			end

			local ent = SpawnItem("container_bankvirtual")
			if ent:IsValid() then
				ent:SetPos(pl:EyePos())
				ent:Spawn()
				--ent:GetItem().Container = pl.Banks[zoneid] or {}
				for _, item in pairs(pl.Banks[zoneid]) do
					ent:AddItem(item, nil, true)
				end
				ent.m_Player = pl
				ent.m_PlayerUID = uid
				ent.m_Zone = zoneid

				Open(pl, ent)
			end
		end
	end
end

if CLIENT then
	function ITEM:OnUse(pl)
	end

	ENT.ContextMenuOptions = {
		"Open Bank",
		function(btn)
			local ent = btn.Entity
			if IsValid(ent) then
				RunConsoleCommand("rpg_useitem", ent:GetItemUID())
			end
		end
	}
end
