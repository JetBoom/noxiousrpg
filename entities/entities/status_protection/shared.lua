ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:GetSkillLevel()
	return self:GetDTFloat(0)
end

function ENT:SetSkillLevel(skill)
	self:SetDTFloat(0, skill)
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if self.DieTime > 0 then
		local damage = dmginfo:GetDamage()
		if damage >= 1 then
			local effectdata = EffectData()
				effectdata:SetEntity(owner)
				effectdata:SetOrigin(owner:LocalToWorld(owner:OBBCenter()))
				effectdata:SetStart(owner:NearestPoint(dmginfo:GetDamagePosition()))
				effectdata:SetMagnitude(damage)
			util.Effect("protection_shielded")

			dmginfo:SetDamage(damage * 0.5)

			self.DieTime = 0
		end
	end
end
