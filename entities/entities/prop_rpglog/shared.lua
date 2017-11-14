ENT.Type = "anim"

function ENT:IsLumberjackable()
	return true
end

function ENT:HitByMelee(attacker, weapon, damage, damagetype, hitdata, ...)
	if self:IsLumberjackable() and weapon and weapon.CanLumberjack and weapon:CanLumberjack(self) then
		DEBUG("Log hit by lumberjacking weapon: "..tostring(self).." "..tostring(weapon))

		if not self:OnLumberjacked(attacker, weapon, damage, damagetype) then
			attacker:GlobalHook("OnLumberjacked", self, weapon, damage, damagetype)
		end
	end
end

function ENT:OnLumberjacked(attacker, weapon, damage, damagetype)
	if not self:IsRemoving() then
		self:SetChopsRemaining(self:GetChopsRemaining() - 1)
		self:Destroyed(attacker, weapon, damage, damagetype)
	end
end

function ENT:Destroyed(attacker, weapon, damage, damagetype)
	if self:IsRemoving() then return end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		effectdata:SetEntity(self)
		effectdata:SetNormal(self:GetUp())
	util.Effect("logchoppedinhalf", effectdata)

	if SERVER then
		local chopsremaining = self:GetChopsRemaining()
		if chopsremaining > 0 then
			for i = -1, 2, 2 do
				local ent = ents.Create("prop_rpglog")
				if ent:IsValid() then
					ent:SetPos(self:GetPos())
					ent:SetAngles(self:GetAngles())
					ent:SetChopsRemaining(chopsremaining)
					ent:Spawn()
					ent:Decay(CurTime() + 120)
				end
			end
		else
			for i = -1, 1, 2 do
				local ent = SpawnItem("log")
				if ent:IsValid() then
					ent:SetPos(self:GetPos())
					ent:SetAngles(self:GetAngles())
					ent:Spawn()
					ent:Decay(CurTime() + 120)
				end
			end
		end

		self:Remove()
	end
end

function ENT:SetChopsRemaining(chops)
	self:SetDTInt(0, chops)
end

function ENT:GetChopsRemaining()
	return self:GetDTInt(0)
end
