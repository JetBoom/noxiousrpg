SPELL.Name = "Thread of Fate"
SPELL.Description = "Fires a Thread of Fate. These threads tie you between yourself and a target which you then have a short time to cast any instantaneous-effect spells. Upon successfuly hitting a target, the mana used to cast the thread is restored."
SPELL.CastTime = 0.5
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_VOIDMAGIC] = 0}

SPELL.ProjectileSpeed = 1200

if SERVER then
	function SPELL:OnCasted(pl)
		local ent = ents.Create("projectile_threadoffate")
		if ent:IsValid() then
			ent:SetPos(pl:EyePos())
			ent:SetOwner(pl)
			ent:Spawn()
			ent:SetSkillLevel(pl:GetSkill(self.Skill))
			pl:GlobalHook("PlayerCreatedSpellProjectile", ent, self)

			ent:Launch(pl:GetAimVector())

			pl:GlobalHook("PlayerLaunchedSpellProjectile", ent, self)
		end
	end
end

PRECAST.Base = "status_precast_mystic01"
