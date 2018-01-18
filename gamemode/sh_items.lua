include("sh_items_datastructure.lua")

local items = {}

function GetAllItems()
	return items
end

function RegisterItemWeapon(name, itemtab, base)
	name = name or ITEMNAME
	itemtab = itemtab or ITEM
	local weptab = {}
	weptab.Base = weptab.Base or base
	weptab.PrintName = weptab.PrintName or itemtab.Name
	weptab.WorldModel = weptab.WorldModel or itemtab.Model
	if SWEP then
		for k, v in pairs(SWEP) do
			weptab[k] = v
		end
	end
	weapons.Register(weptab, name)

	return weapons.GetStored(name)
end

function RegisterItemWeaponStatus(name, itemtab, model, move, rotate, attachmentname, modelscale)
	name = name or ITEMNAME
	itemtab = itemtab or ITEM
	model = model or itemtab.Model

	local classname = "status_"..name
	scripted_ents.Register({Type = "anim", Base = "status__base_weapon", Model = model, Move = move, Rotate = rotate, AnimAttachment = attachmentname, ModelScale = modelscale}, classname)
	return scripted_ents.GetStored(classname)
end

function RegisterItemWearableStatus(name, itemtab, model, move, rotate, attachmentname, modelscale)
	name = name or ITEMNAME
	itemtab = itemtab or ITEM
	if model == nil then
		model = itemtab.Model
	end

	local classname = "status_"..name
	scripted_ents.Register({Type = "anim", Base = "status__base_wearable", Model = model, Move = move, Rotate = rotate, AnimAttachment = attachmentname, ModelScale = modelscale}, classname)
	return scripted_ents.GetStored(classname)
end

function RegisterBodyArmor(name, itemtab)
	return RegisterItemWearableStatus(name, itemtab, false)
end

function GetItemData(dataindex, copy)
	if copy then
		return table.CopyNoUserdata(items[dataindex])
	end

	return items[dataindex]
end
ItemData = GetItemData

function RegisterItem(dataname, dataindex, itemdata, basedata)
	if basedata then
		itemdata = itemdata or {}
		for k, v in pairs(basedata) do
			if itemdata[k] == nil then
				itemdata[k] = v
			end
		end
		--itemdata.BaseClass = basedata.ItemData --itemdata.BaseClass = basedata
	end

	items[dataindex] = itemdata
	items[dataname] = itemdata

	_G["ITEM_"..string.upper(dataname)] = dataindex
end

local function GenericItemEntityInitialize(self)
	local itemdata = self:GetItem() or GetItemData(self:GetItemClass())
	if not itemdata then
		ErrorNoHalt("WARNING! - GenericItemInitialize called yet itemdata doesn't exist!")
		return
	end

	self:SetAmount(itemdata.Amount or 1)

	self:SetModel(itemdata.Model)
	if itemdata.PhysicsInitSphere then
		self:PhysicsInitSphere(itemdata.PhysicsInitSphere, itemdata.PhysicsMaterial)
	elseif itemdata.PhysicsInitBoxMins and itemdata.PhysicsInitBoxMaxs then
		self:PhysicsInitBox(itemdata.PhysicsInitBoxMins, itemdata.PhysicsInitBoxMaxs)
		self:SetCollisionBounds(itemdata.PhysicsInitBoxMins, itemdata.PhysicsInitBoxMaxs)
	else
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	self:SetSolid(SOLID_VPHYSICS)

	if itemdata.CollisionGroup then
		self:SetCollisionGroup(itemdata.CollisionGroup)
	else
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER) --self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	end

	if itemdata.UseType then
		self:SetUseType(itemdata.UseType)
	else
		self:SetUseType(SIMPLE_USE)
	end

	if itemdata.Color then
		self:SetColor(itemdata.Color.r, itemdata.Color.g, itemdata.Color.b, itemdata.Color.a)
	end

	if itemdata.Material then
		self:SetMaterial(itemdata.Material)
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		if itemdata.PhysMaterial then
			phys:SetMaterial(itemdata.PhysMaterial)
		end
		phys:SetMass(math.max(1, (itemdata.Mass or 1) * (itemdata.Amount or 1)))
		phys:EnableMotion(true)
		phys:Wake()
	end
end

local function GenericItemEntityUse(self, activator)
	if activator:IsPlayer() then
		activator:ConCommand("rpg_pickupitem "..self:EntIndex())
	end
end

local function ContextScreenClick(self, aimvec, mc, pressed, pl, tr, camerapos)
	if not pl:IsValid() or not pl:Alive() or MOUSE_TRACEDISTANCE < pl:EyePos():Distance(self:NearestPoint(pl:EyePos())) then return end

	if pressed then
		if mc == MOUSE_LEFT then
			if self.DMenu and self.DMenu:Valid() then
				self.DMenu:Remove()
				self.DMenu = nil
			end

			local eyepos = pl:NewEyePos()
			if self.UnlimitedContextMenuRange or self:NearestPoint(eyepos):Distance(eyepos) <= (self.ContextMenuRange or ITEM_USABLEDISTANCE) then
				if self.BuildContextMenu then
					self.DMenu = self:BuildContextMenu()
				elseif self.ContextMenuOptions then
					local menu = DermaMenu()
					menu:SetPos(MousePos())
					for i = 1, #self.ContextMenuOptions, 2 do
						local panel = menu:AddOption(self.ContextMenuOptions[i], self.ContextMenuOptions[i + 1])
						panel.Entity = self
					end
					menu:AddSpacer()
					menu:AddOption("Do nothing")
					menu:MakePopup()
					self.DMenu = menu
				end
			end
		elseif mc == MOUSE_RIGHT then
			RunConsoleCommand("rpg_pickupitem", self:EntIndex())
		end
	end
end

local function onreceive_parent(item, oldvalue)
	-- hack to call SetParent properly
	local newvalue = item.Parent
	item.Parent = oldvalue
	item:SetParent(newvalue)
end

local function onreceive_slot(item, oldvalue)
	local curparent = item:GetParent()
	if parent and parent.IsContainer and parent.OnContentsChanged then
		parent:OnContentsChanged(item)
	end
end

local function Register()
	if not ITEM.DataIndex then
		ErrorNoHalt(string.format("WARNING - Item %s does not have a unique ITEM.DataIndex!!!", ITEMNAME))
		ITEM.DataIndex = 65534
	end

	ITEM.__nwvars = {}

	ITEM.DataName = ITEMNAME
	ITEM.Mass = ITEM.Mass or 1
	ITEM.Name = ITEM.Name or string.gsub(ITEMNAME, "_", " ")

	ENT.Type = ENT.Type or "anim"

	if ITEM.MaxStack == nil then
		ITEM.MaxStack = 1
	end

	ITEM_NW_VAR("ContainerSlot", "UInt", 0, 8, onreceive_slot)
	ITEM_NW_VAR("Parent", "UInt", 0, 32, onreceive_parent)
	ITEM_NW_VAR("Mass", "UInt", ITEM.Mass, 8) -- Nothing should be heavier than 255

	if ITEM.MaxStack > 1 then
		ITEM_NW_VAR("Amount", "UInt", 1, math.ceil(math.log(ITEM.MaxStack, 2) + 1)) -- Automatically uses only enough bits to represent the max stack.
	end

	if SERVER then
		ENT.Initialize = ENT.Initialize or GenericItemEntityInitialize
		ENT.Use = ENT.Use or GenericItemEntityUse
	end
	if CLIENT then
		ENT.ContextScreenClick = ENT.ContextScreenClick or ContextScreenClick
	end

	RegisterItem(ITEMNAME, ITEM.DataIndex, ITEM, items[ITEM.Base])
	if ITEM.Base then
		ENT.Base = "item_"..ITEM.Base
	end

	ENT.Moveable = ITEM.Moveable

	scripted_ents.Register(ENT, "item_"..ITEMNAME)
end

do
local itemfiles = file.Find("noxiousrpg/gamemode/items/*.lua", "LUA")
table.sort(itemfiles, function(a, b)
	local aisbase = string.find(a, "base") ~= nil
	local bisbase = string.find(b, "base") ~= nil

	if aisbase and bisbase then
		return a < b
	elseif aisbase then
		return true
	end

	return false
end)

for _, itemname in ipairs(itemfiles) do
	itemname = string.sub(itemname, 1, -5)

	ITEMNAME = itemname
	ITEM = {}
	ENT = {}
	SWEP = {}

	include("items/"..itemname..".lua")
	AddCSLuaFile("items/"..itemname..".lua")

	Register()

	ITEMNAME = nil
	ITEM = nil
	ENT = nil
	SWEP = nil
end

print(#itemfiles.." items from files registered.")
end
