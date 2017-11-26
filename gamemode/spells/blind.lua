-- TODO
SPELL.Name = "Blind"
SPELL.Description = "The target's vision is temporarally distorted. They may have trouble making out things that aren't near them."
SPELL.CastTime = 1.5
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_ARCANEMAGIC] = 60}
SPELL.UsesTarget = true

SPELL.EffectDuration = 5
SPELL.EffectDurationPerSkillLevel = 2.5 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)
		target:ThoughtAndFloatie("Blinded!", COLID_RED, pl)
	end
end

PRECAST.Base = "status_precast_mystic01"
