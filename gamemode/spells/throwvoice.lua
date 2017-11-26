--TODO
SPELL.Name = "Throw Voice"
SPELL.Description = "The caster can throw their voice to make it appear that other beings or objects are speaking. The mana lost depends on distance and the amount of sound being thrown. Others that are looking closely at you may be able to spot your trickery."
SPELL.CastTime = 3
SPELL.Mana = 10
SPELL.SkillRequirements = {[SKILL_ARCANEMAGIC] = 30}
SPELL.UsesTarget = true

SPELL.EffectRange = 1024
SPELL.EffectManaPerCharacter = 0.5
SPELL.EffectDistanceMultiplier = 2

if SERVER then
	function SPELL:OnCasted(pl, target)
		if not target or not gamemode.Call("PlayerCanHarm", pl, target) then return true end

		pl:HarmfulAction(target)
	end
end

PRECAST.Base = "status_precast_mystic01"
