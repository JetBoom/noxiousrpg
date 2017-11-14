ENT.Type = "anim"

function ENT:IsPersistent()
	return true
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_FIRE then
		dmginfo:SetDamage(dmginfo:GetDamage() * 2)
	end

	self:SetLumberjackingHealth(self:GetLumberjackingHealth() - dmginfo:GetDamage())

	if self:GetLumberjackingHealth() <= 0 then
		self:Destroyed(attacker, weapon, damage, damagetype)
	end
end

function ENT:IsLumberjackable()
	return true
end

function ENT:HitByMelee(attacker, weapon, damage, damagetype, hitdata, ...)
	if self:IsLumberjackable() and weapon and weapon.CanLumberjack and weapon:CanLumberjack(self) then
		attacker:GlobalHook("OnLumberjacked", self, weapon, damage, damagetype)
	end
end

function ENT:Destroyed(attacker, weapon, damage, damagetype)
	if self:IsRemoving() then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		effectdata:SetEntity(self)
	util.Effect("treedestroyed", effectdata)

	if SERVER then
		-- TODO: Random pieces of wood?

		self:Remove()
	end
end

function ENT:SetLumberjackingHealth(health)
	self:SetDTFloat(0, health)
end

function ENT:GetLumberjackingHealth()
	return self:GetDTFloat(0)
end

function ENT:SetMaxLumberjackingHealth(health)
	self:SetDTFloat(1, health)
end

function ENT:GetMaxLumberjackingHealth()
	return self:GetDTFloat(1)
end

util.PrecacheModel("models/props_foliage/tree_stump01.mdl")
