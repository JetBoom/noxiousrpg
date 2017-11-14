-- TODO
SPELL.Name = "Deafen"
SPELL.Description = "The target is temporarally deafened. They will not be able to hear anyone else talking."
SPELL.CastTime = 1.5
SPELL.Mana = 20
SPELL.SkillRequirements = {[SKILL_ARCANEMAGIC] = 60}
SPELL.PrecastStatus = "precast_"..SPELLNAME
SPELL.UsesTarget = true

SPELL.EffectRange = 1024
SPELL.EffectDuration = 10
SPELL.EffectDurationPerSkillLevel = 5 * SKILLS_RMAX

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)
		target:ThoughtAndFloatie("Deafened!", COLID_RED, pl)
	end
end

RegisterPrecast("mystic01")
