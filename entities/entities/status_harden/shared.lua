ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("")
ENT.EndSound = Sound("")

ENT.DamageMultiplier = 0.85

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local dmgtype = dmgtype:GetDamageType()
	if dmgtype == DMGTYPE_CUTTING or dmgtype == DMGTYPE_IMPACT or dmgtype == DMGTYPE_PIERCING then
		dmginfo:SetDamage(dmginfo:GetDamage() * self.DamageMultiplier)
	end
end
