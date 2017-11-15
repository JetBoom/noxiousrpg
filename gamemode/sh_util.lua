function DEBUG(...)
	--print("DEBUG ", ...)
end
VERBOSE = DEBUG

function string.AndSeparate(list)
	local length = #list
	if length <= 0 then return "" end
	if length == 1 then return list[1] end
	if length == 2 then return list[1].." and "..list[2] end

	return table.concat(list, ", ", 1, length - 1)..", and "..list[length]
end

function string.GhostScramble(text)
	local newtext = ""

	for i=1, #text do
		if string.sub(text, i, i) == " " then
			newtext = newtext.." "
		else
			newtext = newtext..(math.random(0, 1) == 1 and "o" or "O")
		end
	end

	return newtext
end

function GetEffectFlagsAndSeparated(flags)
	local list = {}
	for flag, desc in pairs(SPELLENCHANT_EFFECTS) do
		if bit.band(flags, flag) == flag then
			list[#list + 1] = desc
		end
	end
	return string.AndSeparate(list)
end

function ents.GetEntitiesInSphereArea(vCenter, aAngle, fRadius, fWidth, fHeight)
	local tab = {}

	local vForward = aAngle:Forward()

	for _, ent in pairs(ents.FindInSphere(vCenter, fRadius)) do
		local vNearest = ent:NearestPoint(pos)
		if vNearest:Distance(vCenter) <= fRadius then -- Inside the sphere. FindInSphere works differently client and server side so I assume here that it doesn't actually work properly.
			local vToNearest = (vNearest - vCenter):Normalize()
			local aToNearest = vToNearest:Angle()
			if math.abs(math.AngleDifference(aToNearest.yaw, aAngle.yaw)) <= fWidth and math.abs(math.AngleDifference(aToNearest.pitch, aAngle.pitch)) <= fHeight then -- Inside the square.
				tab[#tab + 1] = ent
			end
		end
	end

	return tab
end

function ents.GetEntitiesInRadius(classname, pos, radius, exception)
	local tab = {}

	for _, ent in pairs(ents.FindInSphere(pos, radius)) do
		if ent:GetClass() == classname and ent ~= exception then
			tab[#tab + 1] = ent
		end
	end

	return tab
end

function ents.GetEntitiesInVisibleRadius(classname, pos, radius, exception)
	local tab = {}

	for _, ent in pairs(ents.GetEntitiesInRadius(classname, pos, radius, exception)) do
		local nearest = ent:NearestPoint(pos)
		if TrueVisible(pos, nearest) and (not ent:IsPlayer() or ent:IsFacing(pos)) then
			tab[#tab + 1] = ent
		end
	end

	return tab
end

function ents.GetPlayersInRadius(pos, radius, exception)
	return ents.GetEntitiesInRadius("player", pos, radius, exception)
end

function ents.GetPlayersInVisibleRadius(pos, radius, exception)
	return ents.GetEntitiesInVisibleRadius("player", pos, radius, exception)
end

function IsVisible(posa, posb)
	if posa == posb then return true end
	return not util.TraceLine({start = posa, endpos = posb, mask = MASK_SOLID_BRUSHONLY}).HitWorld
end

function MeleeVisible(posa, posb, _filter)
	return not util.TraceLine({start = posa, endpos = posb, filter = _filter}).Hit
end

function TrueVisible(posa, posb)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("npc_*"))
	filt = table.Add(filt, player.GetAll())

	return not util.TraceLine({start = posa, endpos = posb, filter = filt, mask = MASK_SHOT}).Hit
end

function TrueVisible2(posa, posb, filtent)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("npc_*"))
	filt = table.Add(filt, player.GetAll())
	filt[#filt + 1] = filtent

	return not util.TraceLine({start = posa, endpos = posb, filter = filt}).Hit
end

function ToMinutesSeconds(TimeInSeconds)
	local iMinutes = math.floor(TimeInSeconds / 60.0)
	return string.format("%0d:%02d", iMinutes, math.floor(TimeInSeconds - iMinutes*60))
end

function util.AOrAn(name)
	name = name or "Unknown"

	local sub1 = string.byte(string.sub(string.lower(name), 1, 1))

	if sub1 == 97 or sub1 == 101 or sub1 == 105 or sub1 == 111 or sub1 == 117 then
		return "an "..name
	else
		return "a "..name
	end
end

function util.NameByAmount(name, amount)
	amount = amount or 1
	name = name or "Unknown"

	if amount == 1 then
		return util.AOrAn(name)
	end

	local endchar = string.byte(string.lower(string.sub(name, -1)))
	if endchar == 115 then
		return amount.." "..name.."es"
	elseif endchar == 121 then
		return amount.." "..string.sub(name, 1, -2).."ies"
	else
		return amount.." "..name.."s"
	end
end

function ExplosiveDamage(attacker, inflictor, from, radius, damage, force, distmultiplier, dmgmultiplier, mindamage, damagetype)
	local vCenter

	if from then
		vCenter = from
	elseif inflictor then
		vCenter = inflictor:LocalToWorld(inflictor:OBBCenter())
	else
		vCenter = attacker:LocalToWorld(attacker:OBBCenter())
	end

	damagetype = damagetype or DMGTYPE_FIRE
	distmultiplier = distmultiplier or 1
	dmgmultiplier = dmgmultiplier or 1
	mindamage = mindamage or 1
	force = force or 1
	radius = math.max(radius, 0.1)
	inflictor = inflictor or attacker

	local damagedents = {}

	for _, ent in pairs(ents.FindInSphere(vCenter, radius)) do
		if not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage", ent, attacker) then
			local pass = false
			local eyepos = ent:EyePos()
			local vNearest = ent:NearestPoint(vCenter)
			if TrueVisible(vNearest, vCenter) then
				pass = true
			elseif TrueVisible(eyepos, vCenter) then
				vNearest = eyepos
				pass = true
			end

			if pass then
				local finaldamage = (radius - vCenter:Distance(vNearest) * distmultiplier) / radius
				local entdamage = math.max(damage * finaldamage * dmgmultiplier, mindamage)

				damagedents[ent] = entdamage

				ent:ThrowFromPosition(vCenter, force * finaldamage)
				ent:TakeSpecialDamage(entdamage, damagetype, attacker, inflictor, vNearest)
			end
		end
	end

	util.ScreenShake(vCenter, damage * 17, damage * 10, math.max(0.75, math.min(dmgmultiplier, 2)), radius * 2.5)

	return damagedents
end