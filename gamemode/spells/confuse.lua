SPELL.Name = "Confuse"
SPELL.Description = "The target's movement is temporarally distorted."
SPELL.CastTime = 2
SPELL.Mana = 40
SPELL.SkillRequirements = {[SKILL_ARCANEMAGIC] = 60}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.EffectDuration = 5
SPELL.EffectDurationPerSkillLevel = 2.5 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)
		target:GiveStatus("confusion", self.EffectDuration + self.EffectDurationPerSkillLevel * pl:GetSkill(self.Skill))
		target:ThoughtAndFloatie("Confused!", COLID_RED, pl)
	end
end

RegisterPrecast("mystic01")
