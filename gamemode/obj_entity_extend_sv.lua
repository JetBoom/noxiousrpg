local meta = FindMetaTable("Entity")
if not meta then return end

function meta:ChatBubble(text, radius, filter)
	if self.PlayVoiceGroup and text:sub(1, 1) ~= ">" then
		self:PlayVoiceGroup(VOICEGROUP_TALK)
	end

	radius = radius or TALK_RADIUS

	net.Start("chatbubble")
	net.WriteEntity(self)
	net.WriteFloat(radius)
	net.WriteString(text)
	net.Send(filter or self:GetChatBubbleFilter(radius))
end
util.AddNetworkString("chatbubble")

function meta:GetChatBubbleFilter(radius)
	radius = radius or CHATBUBBLE_RADIUS
	radius = radius * radius

	local eyepos = self:EyePos()
	local tab = {}
	for _, pl in pairs(player.GetAll()) do
		if pl == self or pl:EyePos():DistToSqr(eyepos) <= radius then
			tab[#tab + 1] = pl
		end
	end

	return tab
end

function meta:Floatie(text, colid, rec)
	net.Start("rpg_floatie")
	net.WriteEntity(self)
	net.WriteString(text)
	net.WriteUInt(colid, 4)
	net.Send(rec)
end

-- TODO: Have a maximum amount of decaying objects. If the limit is reached then start removing things. Sort by decay time left, lowest gets top priority.

local DecayingItems = {}
hook.Add("Tick", "RemoveDecayingItems", function()
	local ct = CurTime()
	for ent, tim in pairs(DecayingItems) do
		if ent:IsValid() then
			if tim <= ct then
				DecayingItems[ent] = nil
				--if not ent.Persist and not (ent.IsPersistent and ent:IsPersistent()) then
					SafeRemoveEntity(ent)
				--end
			end
		else
			DecayingItems[ent] = nil
		end
	end
end)

function meta:GetDecay()
	return DecayingItems[self]
end

function meta:SetDecay(tim)
	DecayingItems[self] = tim
end
meta.Decay = meta.SetDecay

function meta:ResetDecay()
	self:Decay(CurTime() + (self:GetItem() and self:GetItem().DecayTime or self.DecayTime or ITEM_DECAYTIME))
end

function meta:ClearDecay()
	DecayingItems[self] = nil
end
meta.CancelDecay = meta.ClearDecay

function meta:RemoveAllProjectiles()
	for _, ent in pairs(ents.FindByClass("projectile_*")) do
		if ent:GetOwner() == self then
			ent:Remove()
		end
	end
end

function meta:DropEverything(noblessed)
	-- TODO
end

function meta:LaunchSpellProjectile(spelldata, target)
	local isplayer = self:IsPlayer()
	if isplayer and target and not gamemode.Call("PlayerCanHarm", pl, target) then return true end

	if not spelldata.ProjectileClass then return end

	local ent = ents.Create(spelldata.ProjectileClass)
	if ent:IsValid() then
		local ang = self:EyeAngles()
		ent:SetPos(self:EyePos())
		ent:SetAngles(ang)
		ent:SetOwner(self)
		ent:Spawn()
		ent:SetSkillLevel(self:GetSkill(spelldata.Skill))
		if isplayer then
			self:GlobalHook("PlayerCreatedSpellProjectile", ent, spelldata)
		end

		if target then
			ent:Launch(ent:GetHeadingTo(target))
		else
			ent:Launch(ang:Forward())
		end

		if isplayer then
			self:GlobalHook("PlayerLaunchedSpellProjectile", ent, spelldata)
		end
	end
end
