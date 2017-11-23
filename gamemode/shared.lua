GAMEMODEFOLDER = "noxiousrpg"

GM.Name = "Codename: NoXiousNet RPG"
GM.Author = "JetBoom"
GM.Email = "williammoodhe@gmail.com"
GM.Website = "www.noxiousnet.com"
GM.Credits = {
{"William \"JetBoom\" Moodhe", "http://www.noxiousnet.com (williammoodhe@gmail.com)", "Project Lead / Programmer"}
}

include("sh_hack.lua")

include("sh_globals.lua")

include("sh_soundset.lua")

include("sh_items_datastructure.lua")
include("obj_entity_extend.lua")
include("obj_player_extend.lua")
include("obj_npc_extend.lua")
include("obj_weapon_extend.lua")
include("obj_item.lua")
include("sh_util.lua")
include("sh_metallurgy.lua")
include("sh_alchemy.lua")
include("sh_animations.lua")
include("sh_colors.lua")
include("sh_zones.lua")
include("sh_stats.lua")
include("sh_items.lua")
include("sh_spells.lua")
include("sh_voicesets.lua")
include("sh_guilds.lua")
include("sh_monsters.lua")
include("sh_flora.lua")
--include("sh_playerrigs.lua")

TEAM_HUMAN = 1010
team.SetUp(TEAM_HUMAN, "Humans", Color(20, 120, 255, 255), true)
TEAM_MONSTER = 1
team.SetUp(TEAM_MONSTER, "Monsters", Color(255, 20, 20, 255), false)

GM.TestMode = true

function GM:InitializeSoundSets()
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing9.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_sharp1.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_STONE, "rpgsounds/impact_stone1.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_WOOD, "rpgsounds/impact_wood10.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_EARTH, "rpgsounds/impact_earth1.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_METAL, "rpgsounds/impact_metal5.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL, "physics/metal/metal_sheet_impact_bullet2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_1, SOUNDSUBSET_MELEE_HIT_GLASS, "physics/glass/glass_impact_bullet1.wav")

	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing10.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_sharp2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_STONE, "rpgsounds/impact_stone1.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_WOOD, "rpgsounds/impact_wood14.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_EARTH, "rpgsounds/impact_earth2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_METAL, "rpgsounds/impact_metal15.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL, "physics/metal/metal_sheet_impact_bullet2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_2, SOUNDSUBSET_MELEE_HIT_GLASS, "physics/glass/glass_impact_bullet1.wav")

	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing11.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_sharp3.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_STONE, "rpgsounds/impact_stone7.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_WOOD, "rpgsounds/impact_wood2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_EARTH, "rpgsounds/impact_earth3.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_METAL, "rpgsounds/impact_metal15.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_HOLLOWMETAL, "physics/metal/metal_grate_impact_hard3.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_3, SOUNDSUBSET_MELEE_HIT_GLASS, "physics/glass/glass_impact_bullet2.wav")

	soundset.Add(SOUNDSET_MELEE_SHARP_4, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing12.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_4, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_sharp4.wav")

	soundset.Add(SOUNDSET_MELEE_SHARP_5, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing2.wav")
	soundset.Add(SOUNDSET_MELEE_SHARP_5, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_sharp5.wav")

	soundset.Add(SOUNDSET_MELEE_AXE_1, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing4.wav")
	soundset.Add(SOUNDSET_MELEE_AXE_1, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_axe1.wav")

	soundset.Add(SOUNDSET_MELEE_AXE_2, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing14.wav")
	soundset.Add(SOUNDSET_MELEE_AXE_2, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_axe2.wav")

	soundset.Add(SOUNDSET_MELEE_AXE_3, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing7.wav")
	soundset.Add(SOUNDSET_MELEE_AXE_3, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_axe3.wav")

	soundset.Add(SOUNDSET_MELEE_AXE_4, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing8.wav")
	soundset.Add(SOUNDSET_MELEE_AXE_4, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_axe4.wav")

	soundset.Add(SOUNDSET_MELEE_AXE_5, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing2.wav")
	soundset.Add(SOUNDSET_MELEE_AXE_5, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_axe5.wav")

	soundset.Add(SOUNDSET_MELEE_BLUNT_1, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing5.wav")
	soundset.Add(SOUNDSET_MELEE_BLUNT_1, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_blunt1.wav")

	soundset.Add(SOUNDSET_MELEE_BLUNT_2, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing13.wav")
	soundset.Add(SOUNDSET_MELEE_BLUNT_2, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_blunt2.wav")

	soundset.Add(SOUNDSET_MELEE_BLUNT_3, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing6.wav")
	soundset.Add(SOUNDSET_MELEE_BLUNT_3, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_blunt3.wav")

	soundset.Add(SOUNDSET_MELEE_BLUNT_4, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing1.wav")
	soundset.Add(SOUNDSET_MELEE_BLUNT_4, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_blunt4.wav")

	soundset.Add(SOUNDSET_MELEE_BLUNT_5, SOUNDSUBSET_MELEE_SWING, "rpgsounds/swing3.wav")
	soundset.Add(SOUNDSET_MELEE_BLUNT_5, SOUNDSUBSET_MELEE_HIT_FLESH, "rpgsounds/impact_flesh_blunt5.wav")
end

function GM:PlayerShouldTakeDamage(victim, attacker)
	return not victim:IsGhost() and (not attacker:IsPlayer() or hook.Call("PlayerCanHarm", GAMEMODE, attacker, victim))
end

function GM:PlayerSpray(pl)
	return not pl:Alive()
end

function GM:PlayerCanHarm(attacker, victim)
	return zone.CanDoHostileAction(attacker, victim)
end
GM.PlayerCanHurt = GM.PlayerCanHarm

function GM:PlayerCanHelp(target, helper)
	return zone.CanDoHelpfulAction(helper, target)
end

function GM:GetSkillInterval(curskill)
	return math.max(SKILLS_INTERVAL, math.ceil(10 - curskill) * 0.1)
end

function GM:PlayerCanGetUp(pl)
	return pl:Alive() and not pl.Stunned and pl:GetVelocity():Length() < 300
end

function GM:PlayerCanSeeGhost(pl, other)
	return pl == other or pl:IsGhost() or other:GetGhost():IsPublicVisible()
end

function GM:KeyPress(pl, key)
end

function GM:EntityCreated(ent)
	if not ent.Created then
		ent.Created = CurTime()
	end
end

function GM:EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if attacker == inflictor and attacker:IsProjectile() and dmginfo:GetDamageType() == DMG_CRUSH then -- Fixes projectiles doing physics-based damage.
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
		return
	end

	if dmginfo:GetDamageType() == DMGTYPE_ENERGY then
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 + ent:WaterLevel() * 0.125))
	end

	if ent:IsWeapon() or ent.m_IsStatus then return end -- Weapons and status entities only process damage for their owners.

	zone.ProcessDamage(ent, attacker, inflictor, dmginfo)

	if ent.ProcessDamage then
		ent:ProcessDamage(attacker, inflictor, dmginfo)
	end
end

-- Move is very costly so if there are any status entities that want to change something here, it needs to be coded in this function directly.
function GM:Move(pl, move)
	if pl:WaterLevel() <= 1 and not pl:IsOnGround() then -- Lower the stupid air control of the engine.
		move:SetSideSpeed(move:GetSideSpeed() * 0.15)
		move:SetForwardSpeed(move:GetForwardSpeed() * 0.15)
	end

	if pl.KnockedDown and CurTime() % 1 < 0.85 then -- Lower friction on the ground while knocked down.
		pl:SetGroundEntity(NULL)
	end

	if pl:CallMonsterFunction("Move", move) then return end

	if pl:IsFrozen() then -- Soft frozen?
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
		move:SetForwardSpeed(0)
		move:SetSideSpeed(0)
	else
		if pl.status_confusion and pl.status_confusion:IsValid() then
			move:SetSideSpeed(move:GetSideSpeed() * -1)
			move:SetForwardSpeed(move:GetForwardSpeed() * -1)
		end

		local speed = move:GetForwardSpeed()
		local sidespeed = move:GetSideSpeed()
		if speed < -88 then
			move:SetForwardSpeed(math.min(-88, speed * 0.75))

			if sidespeed < -88 then
				move:SetSideSpeed(math.min(-88, sidespeed * 0.75))
			elseif 88 < sidespeed then
				move:SetSideSpeed(math.max(88, sidespeed * 0.75))
			end
		end

		if pl.Precast then
			move:SetSideSpeed(move:GetSideSpeed() * 0.6)
			move:SetForwardSpeed(move:GetForwardSpeed() * 0.6)
		end
	end

	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:IsValid() then
		return wep:Move(move)
	end
end

local oneday = TIME_DAY
function GM:GetSunTime()
	return CurTime() * TIME_DILATION % oneday / oneday
end

function GM:GetTime()
	return CurTime() * TIME_DILATION % oneday
end

function GM:GetWeather()
	return self.CurrentWeather or WEATHER_DEFAULT
end

function GM:IsWeather(weatherid)
	return bit.band(self:GetWeather(), weatherid) == weatherid
end

function GM:GetPreviousWeather()
	return self.PreviousWeather or WEATHER_DEFAULT
end

function GM:OnWeatherChanged(weatherid, previousweatherid)
	for _, ent in pairs(ents.GetAll()) do
		if ent.OnWeatherChanged then
			pcall(ent.OnWeatherChanged, ent, weatherid, previousweatherid)
		end
	end
end

function GM:GetSpellDifficulty(spell, skillid, victim)
	return (spell.SkillRequirements[skillid] + 10) * SKILLS_RMAX
end

function GM:PlayerShouldSkillUp(pl, ent)
	return pl ~= ent and pl:IsValid() and pl:IsPlayer() and not pl:IsSkillLocked() and ent:IsValid() and ent:IsCharacter() and gamemode.Call("PlayerShouldTakeDamage", ent, pl)
end

function GM:PlayerHasSkill(pl, skillid)
	return 0 < pl:GetSkill()
end

function GM:ShouldCollide(enta, entb)
	local snca = enta.ShouldNotCollide
	if snca and snca(enta, entb) then return false end

	local sncb = entb.ShouldNotCollide
	if sncb and sncb(entb, enta) then return false end

	--[[if enta.ShouldNotCollide and enta:ShouldNotCollide(entb) or entb.ShouldNotCollide and entb:ShouldNotCollide(enta) then
		return false
	end]]

	return true
end

function GM:PlayerSkillChanged(pl, skillid, amount)
	if not pl:IsMonster() then
		pl:OnSkillChanged(skillid, amount)
	end
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	local amount
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		amount = 520 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		amount = 500
	else
		amount = 350
	end

	return pl:CallMonsterFunction("PlayerStepSoundTime", iType, bWalking, amount) or amount
end

function GM:GetFallDamage(pl, fallspeed)
	--[[local damage = pl:StatusWeaponHook1("GetFallDamage", fallspeed) or fallspeed * 0.04
	return pl:CallMonsterFunction("AlterFallDamage", damage, fallspeed) or damage]]
	return 0
end

function GM:OnPlayerHitGround(pl, inwater, hitfloater, speed)
	if pl:IsGhost() or pl:StatusWeaponHook3("OnPlayerHitGround", inwater, hitfloater, speed) or pl:CallMonsterFunction("OnPlayerHitGround", inwater, hitfloater, fallspeed) then return true end

	if SERVER then
		local damage = (0.03 * (speed - 550)) ^ 1.5
		if on_floater then damage = damage / 2 end

		if math.floor(damage) > 0 then
			pl:TakeNonLethalDamage(damage, DMG_FALL, game.GetWorld(), game.GetWorld())
			--pl:EmitSound("player/damage"..math.random(1, 3)..".wav", pl:GetPos(), 50 + math.Clamp(damage * 2, 0, 30), 100)
			pl:EmitSound("player/pl_fallpain"..(math.random(0, 1) == 1 and 3 or 1)..".wav")
		end
	end

	return true
end

function GM:GetGameDescription()
	return self.Name
end

function GM:PhysgunPickup(pl, ent)
	return false
end

function GM:PlayerConnect(name, address, steamid)
end

function GM:PhysgunDrop(pl, ent)
end

function GM:SetupMove(pl, move)
end

function GM:FinishMove(pl, move)
end

function GM:GetMaxHealth(vitality, strength)
	return 50 + math.floor(vitality * 0.4 + strength * 0.1)
end

--[[function GM:GetMaxStamina(skill)
	return 25 + skill * 0.75
end

function GM:GetStaminaRegeneration(skill)
	return 1 + skill * 0.005
end]]

function GM:GetMaxMana(skill)
	return 10 + skill * 0.9
end

function GM:GetManaRegeneration(skill)
	return 1.5 + skill * 0.005
end

function GM:GetPlayerSpeed(skill)
	return 225 + skill * 0.5
end

function GM:GetPlayerJumpPower(skill)
	return 225 + skill * 0.75
end

function GM:ScalePlayerDamage(pl, hitgroup, dmginfo)
end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)
end

-- Camera pos is sent by the client, it is NOT safe to use in important calculations!
function GM:ContextScreenClick(aimvec, mc, pressed, pl, camerapos)
	local tr = util.TraceLine({start = camerapos, endpos = camerapos + aimvec * MOUSE_TRACEDISTANCE, filter = pl, mask = MASK_SOLID})
	local ent = tr.Entity
	if ent and ent:IsValid() and ent.ContextScreenClick then
		ent:ContextScreenClick(aimvec, mc, pressed, pl, tr, camerapos)
	end
end

-- DEBUG stuff

function GenericExplosion(pos)
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("genericexplosion", effectdata)
end
