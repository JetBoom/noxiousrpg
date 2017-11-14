ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("nox/protecton.wav")
ENT.EndSound = Sound("nox/protectoff.wav")

ENT.DamageMultipliers = {}

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local dmgtype = dmginfo:GetDamageType()
	if self.DamageMultipliers[dmgtype] then
		dmginfo:SetDamage(dmginfo:GetDamage() * self.DamageMultipliers[dmgtype])
	end
end

function ENT:GetSkillLevel()
	return self:GetDTFloat(0)
end

function ENT:SetSkillLevel(skill)
	self:SetDTFloat(0, skill)
end
