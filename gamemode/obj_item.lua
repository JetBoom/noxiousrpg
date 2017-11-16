if SERVER then
	util.AddNetworkString("noxrp_itemupdate")
end

local rawget = rawget

Item = {}
Container = Item

ITEM_DESERIALIZE_ENV = {Vector = Vector, Angle = Angle, Item = Item}

local meta = {}

function Item.IsItem(object)
	return getmetatable(object) == meta
end

function meta:__tostring()
	return "Item ["..self.ID.."]["..self:GetDataName().." "..self:GetAmount().."]"
end

-- Two items are equal if and only if they share the same unique ID.
function meta:__eq(other)
	return other ~= nil and Item.IsItem(other) and other.ID == self.ID
end

-- If we index something, first try to get the item value
-- Then try the meta table value (from meta functions)
-- Then finally try the item data table (functions and default values from scripts)
-- This allows us to use dynamic prototyping
function meta:__index(key)
	local raw = rawget(self, key)
	if raw ~= nil then
		return raw
	end

	return meta[key] or GetItemData(rawget(self, "_D"))[key]
end

-- Fetch something from the item prototype, ignoring the current instance and meta table.
function meta:DefaultValue(key)
	return GetItemData(rawget(self, "_D"))[key]
end

-- This is for the Serialize function. It's not a real metamethod.
-- Since the first argument of Item is a data table, this works well for us.
function meta:_serialize()
	return "Item("..Serialize(self, true)..")"
end
meta.Serialize = meta._serialize

-- NonStrict functions here are just for convenience.
function meta:AddItemNonStrict(object, amount, autostack)
	if not object or not self:IsContainer() then return false end

	if Item.IsItem(object) then
		return self:AddItem(object, autostack)
	end

	local objecttype = type(object)

	if objecttype == "string" then
		local item = Item(nil, object, amount)
		if item then
			return self:AddItem(item, autostack)
		end
	elseif type(object) == "Entity" and not object:IsRemoving() and object:GetItem() and self:AddItem(object:GetItem(), autostack) then
		object:Remove()
		return true
	end

	return false
end
meta.GiveItemNonStrict = meta.AddItemNonStrict

function meta:RemoveItemNonStrict(object, amount)
	if not object or not self:IsContainer() then return false end

	if Item.IsItem(object) then
		return self:RemoveItem(object, amount)
	end

	amount = amount or 1

	if type(object) == "string" then
		for _, item in pairs(self:GetChildren()) do
			if item:GetDataName() == object and item:GetAmount() >= amount then
				return self:RemoveItem(item, amount)
			end
		end
	end

	return false
end
meta.TakeItemNonStrict = meta.RemoveItemNonStrict
meta.DestroyItemNonStrict = meta.RemoveItemNonStrict

function meta:HasItemNonStrict(object, amount)
	if amount then
		return self:GetItemAmountNonStrict(object) >= amount
	end

	if not object or not self:IsContainer() then return false end

	if Item.IsItem(object) then
		return self:HasItem(object)
	end

	if type(object) == "string" then
		for _, child in pairs(self:GetChildren(true)) do
			if child:GetDataName() == object or child:IsContainer() and child:HasItemNonStrict(object) then return true end
		end
	end

	return false
end

function meta:GetItemAmountNonStrict(object, inclusive)
	local amount = 0
	if not object or not self:IsContainer() then return amount end

	for _, child in pairs(self:GetChildren(inclusive)) do
		if child:GetDataName() == object then
			amount = amount + child:GetAmount()
		end
	end

	return amount
end
meta.GetItemCountNonStrict = meta.GetItemAmountNonStrict
meta.ItemAmountNonStrict = meta.GetItemAmountNonStrict
meta.ItemCountNonStrict = meta.GetItemAmountNonStrict

-- Returns the total amount of items in this container. inclusive means don't search children.
function meta:GetTotalItemCount(inclusive)
	local amount = 0
	if not self:IsContainer() then return amount end

	for _, child in pairs(self:GetChildren(inclusive)) do
		amount = amount + child:GetAmount()
	end

	return amount
end
meta.TotalItemCount = meta.GetTotalItemCount

-- Returns the total amount of item objects in this container. inclusive means don't search children.
function meta:GetTotalItemObjectCount(inclusive)
	local amount = 0
	if not self:IsContainer() then return amount end

	for _, child in pairs(self:GetChildren(inclusive)) do
		amount = amount + 1
	end

	return amount
end
meta.TotalItemObjectCount = meta.GetTotalItemObjectCount
meta.GetItemObjectCount = meta.GetTotalItemObjectCount

-- Attempt to combine with like items in this container. Returns true on success.
function meta:StackWithOthersInContainer(parent)
	parent = parent or self:GetParent()
	if not parent then return false end

	for _, child in pairs(parent:GetChildren(true)) do
		if child:IsStackable() and child:CanStack(self) then
			self:SetAmount(self:GetAmount() + child:GetAmount())
			child:Destroy()
			return true
		end
	end
end

-- Returns the number of item objects we can hold. nil is infinite, which is a bad idea. Remember, this is an OBJECT count.
function meta:GetCapacity()
	-- HACK
	return 100
	-- return self.GetCapacity and self:GetCapacity() or self.ItemCapacity
end

-- Returns the maximum amount of mass we can hold. nil is infinite.
function meta:GetMassCapacity()
	-- HACK
	return nil
	-- return self.GetMassCapacity and self:GetMassCapacity() or self.MassCapacity
end

-- Adds an item to us.
-- Returns true on success.
function meta:AddItem(other, autostack, nosync)
	if self:IsContainer() then
		local capacity = self:GetCapacity()
		if capacity and capacity ~= -1 and capacity <= self:TotalItemObjectCount() then
			return false
		end

		-- TODO: This is bugged.
		--[[local masscapacity = self:GetMassCapacity()
		if masscapacity and masscapacity ~= -1 and masscapacity < (self:GetMass() - self:GetMass(true)) + other:GetMass() then
			return false
		end]]

		other:SetParent(self)

		if autostack then
			other:StackWithOthersInContainer()
		end

		if not nosync then
			self:RadiusSync()
		end

		return true
	--else
		-- TODO: Try stacking
	end

	return false
end

function meta:CanStack(other)
	if other == self then return false end

	local ret = self.CanStackWith and self:CanStackWith(other)
	if ret ~= nil then
		return ret
	end

	-- TODO: better behavior. Check all non-system keys are the same
	return self:GetDataName() == other:GetDataName() and self:GetName() == other:GetName() and self:GetModel() == other:GetModel() and (self.MaxStack == -1 or self.MaxStack >= self:GetAmount() + other:GetAmount())
end

function meta:IsStackable()
	return self.MaxStack == -1 or self.MaxStack >= 2
end

-- If we contain Item other, removes it from this item.
-- Make sure you do something with the item you remove or it may be garbage collected.
-- You can also pass amount as the second argument.
-- Returns true on success.
function meta:RemoveItem(other, amount)
	if other:IsInside(self) then
		if amount and amount < other:GetAmount() then
			other:SetAmount(other:GetAmount() - amount)
		else
			other:SetParent(nil)
		end

		self:RadiusSync()

		return true
	end

	return false
end

-- Is this item inside item other? Checks multiple levels of containers.
function meta:IsInside(other)
	local parent = self:GetParent()
	if parent then
		if parent == other then
			return true
		else
			return parent:IsInside(other)
		end
	end

	return false
end

-- Our dataname. Same as the item's file name in the items folder.
function meta:GetDataName()
	return self._D or "rock"
end

-- Usable? This function should exist both server-side and client-side, even if the function is empty.
function meta:GetUsable()
	return self.OnUse ~= nil
end
meta.IsUsable = meta.GetUsable

-- Change our name. If this is nil then it will use either the item file's name or the dataname.
function meta:SetName(name)
	self.Name = name
end

-- Get our name. Doesn't take in to consideration item amount or grammar.
function meta:GetName()
	return self.Name or self:GetDataName()
end

-- A nice looking name. Instead of "rock" it would display "a rock" or "4 rocks" if GetAmount was 4.
function meta:GetDisplayName()
	return util.NameByAmount(self:GetName(), self:GetAmount())
end

-- Amount in this item.
function meta:GetAmount()
	return self.Amount or 1
end

-- Sets the amount. Does not check against MaxStack. That should be done on a case-by-case basis.
function meta:SetAmount(amount)
	assert(type(amount) == "number", "SetAmount expects a number.")

	if self.Amount ~= amount then
		self.Amount = amount

		if amount <= 0 then
			self:Destroy()
		else
			self:RadiusSync()
		end
	end
end

function meta:SetModel(mdl)
	if self.Model ~= mdl then
		self.Model = mdl
		self:RadiusSync()
	end
end

function meta:GetModel()
	return self.Model
end

-- Gets every item under us.
function meta:GetChildren(thisonly)
	local tab = {}

	if self:IsContainer() then
		for _, item in pairs(self:GetContainer()) do
			tab[#tab + 1] = item
			if not thisonly and item:IsContainer() then
				table.Add(tab, item:GetChildren())
			end
		end
	end

	return tab
end

-- If this item is a container, does it hold Item other? Searches any children containers as well.
function meta:ContainsItem(other)
	if self:IsContainer() then
		for _, item in pairs(self:GetContainer()) do
			if other == item or item:ContainsItem(other) then
				return true
			end
		end
	end

	return false
end

-- Is this item a container?
function meta:IsContainer()
	return self.Container ~= nil
end

-- Returns our container if we have one.
function meta:GetContainer()
	return self.Container
end

-- This isn't really used anywhere else.
function meta:GetItem(object)
	if self:ContainsItem(object) then return object end
end

-- Search for an item by Item or DataName.
function meta:GetItemNonStrict(object, bInclusive)
	if not self:IsContainer() then return end

	if Item.IsItem(object) then
		return self:GetItem(object)
	end

	if type(object) == "string" then -- Asking for a DataName. Just return the first entry we get (if any).
		for _, item in pairs(self:GetContainer()) do
			if item:GetDataName() == object then
				return item
			end
		end

		if not bInclusive then
			-- Not found in this level, search children.
			for _, item in pairs(self:GetContainer()) do
				local ret = item:GetItem(object)
				if ret then return ret end
			end
		end
	elseif type(object) == "number" then -- Asking for a UID. Return the global item only if we contain it.
		return self:GetItem(Items[object])
	end
end

-- Gets the entity that contains us. It can be that we're the entity's item or we're contained in a container the entity owns.
function meta:GetRootEntity()
	local root = self:GetRootOrSelf()
	for _, ent in pairs(ents.GetAll()) do
		if ent:GetItem() == root then
			return ent
		end
	end

	return NULL
end
meta.GetRootOwner = meta.GetRootEntity

-- Items don't hold pointers to their entity. You usually don't need to call this.
function meta:GetEntity()
	for _, ent in pairs(ents.GetAll()) do
		if ent:IsValid() and ent:GetContainer() == self then
			return ent
		end
	end

	return NULL
end
meta.GetOwner = meta.GetEntity

function meta:SetDroppable(droppable)
	if droppable == false then
		self.Undroppable = true
	else
		self.Undroppable = nil
	end
	self:RadiusSync()
end

function meta:GetDroppable()
	if self.Undroppable then return false end

	--[[local itemdata = self:GetItemData()
	if itemdata.IsDroppable then
		local ret = itemdata.IsDroppable(item)
		if ret ~= nil then return ret end
	end]]

	return true
end
meta.IsDroppable = meta.GetDroppable

-- Move the item around in a container. Nothing to do with entities.
function meta:Move(x, y)
	self.X = math.Clamp(math.ceil(x), 0, 2048)
	self.Y = math.Clamp(math.ceil(y), 0, 2048)

	self:RadiusSync()
end

function meta:InRange(ent)
	local entpos = ent:IsPlayer() and ent:NewEyePos() or ent:EyePos()
	local owner = self:GetRootEntity()
	if owner == ent then return true end

	return owner:IsValid() and owner:NearestPoint(entpos):Distance(entpos) < ITEM_USABLEDISTANCE
end

-- TODO: This needs to be better.
function meta:InView(ent)
	local entpos = ent:IsPlayer() and ent:NewEyePos() or ent:EyePos()
	local owner = self:GetRootEntity()
	if owner == ent then return true end

	return owner:IsValid() and not util.TraceLine({start = entpos, endpos = owner:NearestPoint(entpos), mask = MASK_SOLID_BRUSHONLY}).Hit
end

function meta:InRangeAndView(ent)
	local entpos = ent:IsPlayer() and ent:NewEyePos() or ent:EyePos()
	local owner = self:GetRootEntity()
	if owner == ent then return true end

	if owner:IsValid() then
		local nearest = owner:NearestPoint(entpos)
		return nearest:Distance(entpos) < ITEM_USABLEDISTANCE
		and not util.TraceLine({start = entpos, endpos = nearest, mask = MASK_SOLID_BRUSHONLY}).Hit
	end

	return false
end

-- Can this player interact with us?
function meta:IsUsableBy(pl)
	if not pl:Alive() or not self:InRangeAndView(pl) then return false end

	local owner = self:GetRootEntity()

	if self.WearableSlot then
		return owner:IsValid() and (owner == pl or owner:GetOwner() == pl)
	end

	return not owner:IsValid() or not owner:IsPlayer() or owner == pl
end

-- Can this player drop us from our current container?
function meta:IsDroppableBy(pl)
	return self:IsMoveableBy(pl)
	and not self.Bound and not self.Cursed
end

-- Can this player view us?
function meta:IsViewableBy(pl)
	return self:InRangeAndView(pl)
end

-- Can this player move us within the current container?
function meta:IsMoveableBy(pl)
	if self.LockedDown or self.Moveable == false or not pl:Alive() or not self:InRangeAndView(pl) then return false end

	local owner = self:GetRootEntity()

	if owner.LockedDown then return false end -- Can't move an item that has their entity locked down.

	return not owner:IsValid() or -- Item in no container??
	not owner:IsPlayer() or -- Entity in the open.
	owner == pl -- In our player inventory.
	and not self.Hidden -- Can't move hidden items.
end

-- Can this player transfer us to the new container?
function meta:IsTransferableBy(pl, newcontainer)
	return newcontainer ~= nil
	and self.ID ~= newcontainer.ID -- Can't transfer ourself to ourself.
	and not self:ContainsItem(newcontainer) -- Can't transfer ourself to a container we contain.
	and self:IsMoveableBy(pl) and newcontainer:IsUsableBy(pl) -- Can't transfer something we can't move.
	and not self.Bound and not self.Cursed -- Can't transfer items with these special flags.
end

-- Creates an entity and sets this Item object to that entity.
-- Ironically, this doesn't actually call :Spawn() on the entity. That must be done yourself.
function meta:SpawnEntity()
	local curent = self:GetEntity()
	if curent:IsValid() then
		return curent
	end

	local class = self:GetEntityClass()
	if scripted_ents.GetStored(class) then
		local ent = ents.Create(class)
		if ent:IsValid() then
			self:SetParent(nil) -- Entities can never be in a container.
			ent:SetItem(self)
			return ent
		end
	end

	return NULL
end
meta.Spawn = meta.SpawnEntity
meta.SpawnItem = meta.SpawnEntity

-- Sets our color then forwards it to our entity.
function meta:SetColor(col)
	self.Color = col

	local ent = self:GetEntity()
	if ent:IsValid() then ent:SetColor(col) end

	self:Sync()
end

-- Sets our material then forwards it to our entity.
function meta:SetMaterial(mat)
	self.Material = mat

	local ent = self:GetEntity()
	if ent:IsValid() then ent:SetMaterial(mat) end

	self:Sync()
end

-- Sets our mass then forwards it to our entity.
function meta:SetMass(mass)
	self.Mass = mass

	local ent = self:GetEntity()
	if ent:IsValid() then
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(math.max(2, mass * self:GetAmount()))
		end
	end

	self:Sync()
end

function SpawnItem(class, amount)
	return Item(nil, class, amount):Spawn()
end

-- Returns a copy of this item. The only thing changed is the UID.
function meta:Copy()
	local data = table.Copy(self)
	data.ID = nil
	return Item(data)
end

local function DoOnContentsChanged(root, item)
	if root and item and Item.IsItem(root) and Item.IsItem(item) and root.OnContentsChanged then
		root:OnContentsChanged(item)
	end
end
function meta:CallParentContentsChanged()
	local root = self:GetRoot()
	if root and Item.IsItem(root) and root:IsContainer() and root.OnContentsChanged then
		timer.Simple(0, function() DoOnContentsChanged(root, self) end)
	end
end

-- Gets the biggest container that ultimately contains us.
function meta:GetRoot()
	local parent = self:GetParent()
	if parent then
		return parent:GetRoot() or parent
	end

	--[[local parent = self:GetParent()
	if parent then
		local ret = parent:GetParent()
		if ret then return ret end

		return parent
	end]]
end

function meta:GetRootOrSelf()
	return self:GetRoot() or self
end

if SERVER then
-- Sync this item with the owner, if they're a player.
-- Optionally allows you to specify a player instead of sending to the owner.
function meta:Synchronize(pl)
	pl = pl or self:GetRootEntity()
	if pl:IsValid() and pl:IsPlayer() then
		net.Start("noxrp_itemupdate")
			net.WriteString(self:Serialize())
		net.Send(pl)
	end
end
meta.Synch = meta.Synchronize
meta.Syncronize = meta.Synchronize
meta.Sync = meta.Syncronize

-- Syncs with every single client on the server. Probably shouldn't be used that much.
function meta:GlobalSync()
	net.Start("noxrp_itemupdate")
		net.WriteString(self:Serialize())
	net.Broadcast()
end

-- This is mostly used for syncing to anyone who can POTENTIALLY be looking at us. It's a bad workaround until a system is made to decide who is looking at an item at any given time.
function meta:RadiusSync(radius)
	if self:IsContainer() or self:GetParent() then -- Don't send unless we're in a container or we are a container.
		local rootentity = self:GetRootEntity()
		if rootentity:IsValid() then
			if rootentity:IsPlayer() then -- In a player inventory, only sync to that person.
				self:Synchronize(rootentity)
			else
				for _, pl in pairs(ents.FindInSphere(rootentity:GetPos(), radius or 1024)) do
					if pl:IsPlayer() then
						self:Synchronize(pl)
					end
				end
			end
		end
	end
end
end

if CLIENT then
function meta:Synchronize(pl)
end
meta.Synch = meta.Synchronize
meta.Syncronize = meta.Synchronize
meta.Sync = meta.Syncronize
meta.GlobalSync = meta.Synchronize
meta.RadiusSync = meta.Synchronize
end

-- Utility to get our entity class, if we had one.
function meta:GetEntityClass()
	return "item_"..self:GetDataName()
end

-- Returns our itemdata. This is what you get from the scripts in the items folder.
function meta:GetItemData()
	return GetItemData(rawget(self, "_D"))
end

-- Destroys this item. If it's a container, destroys any children.
-- If we have an entity, the entity is removed.
function meta:Destroy()
	self:SetParent(nil)
	for _, item in pairs(self:GetChildren(true)) do
		item:Destroy()
	end

	self:CallParentContentsChanged()

	self:RemoveEntity()
end
meta.Remove = meta.Destroy

-- Returns the data of our baseclass if we have one.
function meta:GetBaseClass()
	return GetItemData(self.Base)
end

function meta:RemoveEntity()
	self:CallParentContentsChanged()

	local ent = self:GetEntity()
	if ent:IsValid() and not ent:IsCharacter() then
		ent:Remove()
	end
end

function meta:RemoveAllEntities()
	self:RemoveEntity()
	for _, child in pairs(self:GetChildren()) do
		child:RemoveEntity()
	end
end

function meta:OnRootEntityChanged()
	self:RemoveAllEntities()
	self:RadiusSync()
end

-- Sets our parent Item to parent.
-- parent must be a container.
-- This function will also remove us from our current container, if we have one.
-- Removes our entity if we have one.
-- Returns true on success.
function meta:SetParent(parent)
	local curparent = self:GetParent()
	if curparent == parent then return true end -- Skip it all if the new parent is the same as our current.

	if parent and not parent:IsContainer() then return false end -- Either the parent is nothing or a container.

	local oldentity = self:GetRootEntity()

	if parent then
		self.Parent = parent.ID
		self:RemoveEntity()
	else
		self.Parent = nil
	end

	if curparent then
		curparent.Container[self.ID] = nil
		curparent:RadiusSync()
	end

	if parent then
		parent.Container[self.ID] = self

		-- Might be our first time being in a container. Randomize the display position if so.
		if not self.X then
			self.X = math.random(0, 400)
			self.Y = math.random(0, 400)
		end

		parent:RadiusSync()
	end

	if curparent ~= parent then
		if curparent and curparent.OnContentsChanged then
			curparent:OnContentsChanged(self)
		end

		if parent and parent.OnContentsChanged then
			parent:OnContentsChanged(self)
		end

		if self.OnParentChanged then
			self:OnParentChanged(parent, curparent)
		end
	end

	if self:GetRootEntity() ~= oldentity then
		self:OnRootEntityChanged()
	end

	return true
end

-- Returns the Item object that holds us, if any.
function meta:GetParent()
	if self.Parent then
		return Items[self.Parent]
	end
end

-- Returns the TOTAL mass of this item.
-- This includes the mass of any children if we're a container as well as our own mass.
function meta:GetMass(onlyself)
	if onlyself or not self:IsContainer() then return self.Mass end

	local mass = self.Mass

	for _, child in pairs(self:GetChildren()) do
		mass = mass + child:GetMass()
	end

	return mass
end

function meta:IsMelee()
	local swep = weapons.GetStored(self:GetDataName())
	return swep and swep.Base and string.sub(swep.Base, 1, 18) == "weapon__base_melee"
end

function meta:IsRanged()
	return self:IsBow() or self:IsStaff()
end

if CLIENT then
	-- Returns an item panel for this item.
	function meta:GetItemPanel(parent)
		return ItemPanel(self, parent)
	end
	meta.ItemPanel = meta.GetItemPanel

	net.Receive("noxrp_itemupdate", function(len)
		gamemode.Call("ItemReceived", Deserialize(net.ReadString(), ITEM_DESERIALIZE_ENV))
	end)
end

-- Use Item([data], [dataname], [amount]) instead of this Item.new. Handled by the __call metamethod below.
-- All 3 arguments are optional.
-- Returns an Item object on success, otherwise returns nil.
-- If an Item already exists with data's UID then it returns the existing Item object (can't be more than one Item object using the same UID).
function Item:new(data, dataname, amount)
	local item

	local bIsNew = false
	if data and data.ID and Items[data.ID] ~= nil then
		item = Items[data.ID]
		for k, v in pairs(item) do
			item[k] = nil
		end
		--[[for k, v in pairs(item) do
			if data[k] == nil then
				item[k] = nil
			end
		end]]
	else
		item = {}
	end

	if data then
		for k, v in pairs(data) do
			item[k] = v
		end
	end

	bIsNew = item._C == nil

	item.ID = item.ID or GetUID()
	item._D = item._D or dataname or "__base"

	setmetatable(item, meta)

	local itemdata = GetItemData(item._D)
	if not itemdata then
		if bIsNew then
			ErrorNoHalt("Missing item prototype for "..item._D..". Changing to generic item.")
		else
			ErrorNoHalt("Missing item prototype for "..item._D..". Changing to generic item. Do NOT delete or rename item scripts!!!")
		end

		item._D = "__base"
		itemdata = GetItemData("__base")
	end

	if bIsNew then
		item._C = os.time()

		--[[local copydata = GetItemData(dataname, true)
		if copydata then
			for k, v in pairs(copydata) do
				item[k] = v
			end
		end]]

		if 0 < itemdata.MaxStack then
			item:SetAmount(math.min(itemdata.MaxStack, item:GetAmount() or amount))
		else
			item:SetAmount(item.Amount or amount or 1)
		end

		if item.OnCreated then
			item:OnCreated()
		end
	end

	Items[item.ID] = item

	return item
end

setmetatable(Item, {__call = Item.new})
