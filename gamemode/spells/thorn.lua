SPELL.Name = "Thorn"
SPELL.Description = "Solidifies air in to a concentrated needle."
SPELL.CastTime = 0.75
SPELL.Mana = 5
SPELL.SkillRequirements = {[SKILL_AEROMAGIC] = 0}
SPELL.PrecastStatus = "precast_"..SPELLNAME

SPELL.ProjectileDamage = 3
SPELL.ProjectileDamagePerSkill = 0.01
SPELL.ProjectileSpeed = 2000

if SERVER then
	function SPELL:OnCasted(pl, target)
		if target and not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		local ent = ents.Create("projectile_thorn")
		if ent:IsValid() then
			ent:SetPos(pl:EyePos())
			ent:SetAngles(pl:EyeAngles())
			ent:SetOwner(pl)
			ent:SetSkillLevel(pl:GetSkill(self.Skill))
			ent:Spawn()
			pl:GlobalHook("PlayerCreatedSpellProjectile", ent, self)

			if target then
				ent:Launch(ent:GetHeadingTo(target))
			else
				ent:Launch(pl:GetAimVector())
			end
			pl:GlobalHook("PlayerLaunchedSpellProjectile", ent, self)
		end
	end

	scripted_ents.Register({
		Base = "status__base_precast",
		Type = "anim",
		SpellData = SPELL
	}, "status_precast_"..SPELLNAME)
end

if CLIENT then
	local matGlow = Material("sprites/glow04_noz")
	scripted_ents.Register({
		Base = "status__base_precast",
		Type = "anim",
		SpellData = SPELL,

		Initialize = function(self)
			self.BaseClass.Initialize(self)
			self.AmbientSound = CreateSound(self, "nox/energyhum1.wav")
			self.Seed = math.Rand(0, 10)
			self:SetRenderBounds(Vector(-92, -92, -92), Vector(92, 92, 92))
		end,

		Think = function(self)
			self.AmbientSound:PlayEx(0.8, math.sin(RealTime()) + 100)
			self.BaseClass.Think(self)
		end,

		Draw = function(self)
			local owner = self:GetOwner()
			if owner:IsValid() then
				render.SetMaterial(matGlow)
				local size = math.abs(math.sin((RealTime() + self.Seed) * 8) * 64) + 4
				render.DrawSprite(owner:GetCastPos(), size, 32, color_white)
			end
		end,

		OnRemove = function(self)
			self.BaseClass.OnRemove(self)
			self.AmbientSound:Stop()
		end
	}, "status_precast_"..SPELLNAME)
end
