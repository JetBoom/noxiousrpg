local meta = FindMetaTable("Entity")
if not meta then return end

function meta:GetItemByUIDOrDataName(argument)
	local itemid = tonumber(argument)
	return itemid and Items[itemid] or self:GetContainer():GetItemNonStrict(argument)
end

function meta:GetUsableItemByUIDOrDataName(argument)
	local item = self:GetItemByUIDOrDataName(argument)
	if item and item:IsUsableBy(self) then return item end
end

if SERVER then
	function meta:GetItem()
		return self.ItemData or Items[self:GetItemUID()]
	end

	function meta:SetItemUID(uid)
		self:SetDTInt(2, uid)
	end
end

if CLIENT then
	function meta:GetItem()
		return Items[self:GetItemUID()] or self.ItemData
	end

	function meta:SetItemUID(uid)
	end
end
meta.GetContainer = meta.GetItem

function meta:SetItem(item)
	self.ItemData = item
	if item then
		self:SetItemUID(item.ID)
	else
		self:SetItemUID(-1)
	end
end
meta.SetContainer = meta.SetItem

function meta:GetItemUID()
	return self:GetDTInt(2)
end

function meta:IsProjectile()
	return self:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE
end

function meta:GetHeadingTo(target)
	return (target:LocalToWorld(target:OBBCenter()) - self:LocalToWorld(self:OBBCenter())):Normalize()
end

function meta:GetAmount()
	return math.max(1, self:GetDTInt(3))
end

function meta:SetAmount(amount)
	self:SetDTInt(3, amount)
end

function meta:GetNameColor(viewer)
	return COLOR_LIGHTBLUE
end

function meta:TakeSpecialDamage(damage, damagetype, attacker, inflictor, hitpos)
	attacker = attacker or self
	if not attacker:IsValid() then attacker = self end
	inflictor = inflictor or attacker
	if not inflictor:IsValid() then inflictor = attacker end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	dmginfo:SetDamagePosition(hitpos or self:WorldSpaceCenter())
	dmginfo:SetDamageType(damagetype)
	self:TakeDamageInfo(dmginfo)
end

function meta:ThrowFromPosition(pos, force)
	if force == 0 or self:IsProjectile() then return end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):Normalize(), nearest)
		end
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if self.KnockDown and FORCE_KNOCKDOWN <= math.abs(force) then
			self:KnockDown()
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):Normalize())
	end
end

function meta:SetAlpha(a)
	local col = self:GetColor()
	col.a = a
	self:SetColor(col)
end

function meta:SetAlphaModulation(a)
	self:SetAlpha(a * 255)
end

function meta:GetAlpha()
	return self:GetColor().a
end
meta.GetVisibility = meta.GetAlpha

function meta:GetAlphaModulation()
	return self:GetAlpha() / 255
end

function meta:IsOpaque()
	return self:GetAlpha() == 255
end

function meta:IsInvisible()
	return self:GetAlpha() == 0
end

function meta:GetZone()
	return self.m_Zone or "0"
end

function meta:SetZone(zoneid)
	self.m_Zone = zoneid
end

function meta:ClearZone()
	self:SetZone(nil)
end

function meta:AddGold(...)
	return self:AddItem("gold_coin", ...)
end
meta.GiveGold = meta.AddGold

function meta:RemoveGold(...)
	return self:RemoveItem("gold_coin", ...)
end
meta.TakeGold = meta.RemoveGold
meta.DestroyGold = meta.RemoveGold

function meta:HasGold(...)
	return self:HasItem("gold_coin", ...)
end

function meta:GetGold()
	return self:GetItemAmount("gold_coin")
end

function meta:AddItem(...)
	return self:GetContainer():AddItemNonStrict(...)
end
meta.GiveItem = meta.AddItem

function meta:RemoveItem(...)
	return self:GetContainer():RemoveItemNonStrict(...)
end
meta.TakeItem = meta.RemoveItem
meta.DestroyItem = meta.RemoveItem

function meta:HasItem(...)
	return self:GetContainer():HasItemNonStrict(...)
end

function meta:GetItemAmount(...)
	return self:GetContainer():GetItemAmountNonStrict(...)
end
meta.ItemAmount = meta.GetItemAmount

function meta:IsSubmerged()
	return self:WaterLevel() == 3
end

function meta:GetAttachmentByName(name)
	local attachments = self:GetAttachments()
	if not attachments then return nil end

	for attachmentIndex, attachmentName in ipairs(attachments) do
		if attachmentName == name then return self:GetAttachment(attachmentIndex) end
	end
end