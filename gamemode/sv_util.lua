local lightningid = 0
local colLightningDefault = Color(21, 106, 234)
function UTIL_LightningStrike(entorpos, intensity, lifetime, color)
	intensity = intensity or 1
	lifetime = lifetime or 0.4
	color = color or colLightningDefault

	local hitent = type(entorpos) == "Vector" and NULL or entorpos
	local shotpos
	local toppos
	local bottompos
	if hitent:IsValid() then
		shotpos = hitent:GetPos()
		bottompos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0, 0, -10000), filter = hitent, mask = COLLISION_GROUP_DEBRIS}).HitPos
		toppos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0, 0, 10000), filter = hitent, mask = COLLISION_GROUP_DEBRIS}).HitPos
	else
		shotpos = entorpos
		bottompos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0, 0, -10000), mask = COLLISION_GROUP_DEBRIS}).HitPos
		toppos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0, 0, 10000), mask = COLLISION_GROUP_DEBRIS}).HitPos
	end

	local targetname = "templighttarget"..lightningid
	lightningid = lightningid + 1

	local tempent = ents.Create("info_target")
	if tempent:IsValid() then
		tempent:SetPos(bottompos)
		tempent:SetName(targetname)
		tempent:Spawn()
		if hitent:IsValid() then
			tempent:SetParent(hitent)
		end
		tempent:Fire("kill", "", lifetime)
	end

	local laser = ents.Create("env_laser")
	if laser:IsValid() then
		laser:SetPos(toppos)
		laser:SetKeyValue("renderamt", "255")
		laser:SetKeyValue("rendercolor", color.r.." "..color.g.." "..color.b)
		laser:SetKeyValue("width", 30 * intensity)
		laser:SetKeyValue("texture", "Effects/laser1.vmt")
		laser:SetKeyValue("TextureScroll", "1")
		laser:SetKeyValue("damage", "0")
		laser:SetKeyValue("renderfx", "0")
		laser:SetKeyValue("LaserTarget", targetname)
		laser:SetKeyValue("NoiseAmplitude", 4 * intensity)
		laser:SetKeyValue("spawnflags", "33")
		laser:Spawn()
		laser:SetOwner(pl)
		laser:Fire("kill", "", lifetime)
	end
	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", 250 * intensity)
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", math.ceil(6 * intensity))
		effect2:SetKeyValue("beamcount_max", math.ceil(10 * intensity))
		effect2:SetKeyValue("thick_min", 20 * intensity)
		effect2:SetKeyValue("thick_max", 50 * intensity)
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(bottompos + Vector(0, 0, 32))
		effect2:Spawn()
		if hitent:IsValid() then
			effect2:SetParent(hitent)
		end
		effect2:Fire("DoSpark", "", lifetime * 0.33)
		effect2:Fire("DoSpark", "", lifetime * 0.66)
		effect2:Fire("DoSpark", "", lifetime)
		effect2:Fire("kill", "", lifetime + 0.05)
	end
	local effectdata = EffectData()
		effectdata:SetOrigin(bottompos)
	util.Effect("lightning", effectdata, true, true)
	util.ScreenShake(bottompos, math.random(10, 30), 150.0, 0.75, 150)
end
