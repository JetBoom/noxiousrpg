ENT.Type = "anim"

function ENT:IsPersistent()
	return true
end

function ENT:IsLumberjackable()
	return true
end

function ENT:HitByMelee(attacker, weapon, damage, damagetype, hitdata, ...)
	if self:IsLumberjackable() and weapon and weapon.CanLumberjack and weapon:CanLumberjack(self) then
		if arg[1] and arg[1] == STATE_AXE_CHARGEATTACK then
			damage = damage ^ 2
			DEBUG("Lumberjacking charge attack damage: "..damage)
		end

		DEBUG("Tree hit by lumberjacking weapon: "..tostring(self).." "..tostring(weapon).." "..tostring(attacker).." Damage: "..damage)

		if not self:OnLumberjacked(attacker, weapon, damage, damagetype) then
			attacker:GlobalHook("OnLumberjacked", self, weapon, damage, damagetype)
		end
	end
end

function ENT:OnLumberjacked(attacker, weapon, damage, damagetype)
	self:SetLumberjackingHealth(self:GetLumberjackingHealth() - damage)

	if SERVER and self:GetLumberjackingHealth() <= 0 then
		self:Destroyed(attacker, weapon, damage, damagetype)
	end
end

function ENT:Destroyed(attacker, weapon, damage, damagetype)
	if self:IsRemoving() then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		effectdata:SetEntity(self)
		effectdata:SetNormal(self:GetUp())
	util.Effect("treedestroyed", effectdata)

	if SERVER then
		-- TODO: EP2 model so needs to be included in downloadurl.
		local ent = ents.Create("prop_treestump")
		if ent:IsValid() then
			ent:SetPos(self:GetPos())
			ent:SetAngles(self:GetAngles())
			ent:Spawn()
			ent:Decay(CurTime() + 600)
		end

		local ent = ents.Create("prop_rpglog")
		if ent:IsValid() then
			ent:SetPos(self:GetPos() + self:GetUp() * 64)
			ent:SetAngles(self:GetAngles())
			ent:SetChopsRemaining(3)
			ent:Spawn()
			ent:Decay(CurTime() + 120)
		end

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
