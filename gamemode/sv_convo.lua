include("sh_convo.lua")

convo.Conversations = {}

function convo.GetConversation(pl)
	return convo.Conversations[convo.GetConversationID(pl)]
end

function convo.IsActive(pl)
	return convo.GetConversation(pl) ~= nil
end

function convo.Start(pl, ent, convtype, entrypoint)
	convo.End(pl)

	local stored = convo.StoredConversations[convtype]
	if not stored then
		ErrorNoHalt("Conversation type '"..tostring(convtype).."' doesn't exist! Called by "..tostring(ent).." and "..tostring(pl))
		return
	end

	convo.Conversations[convo.GetConvoID(pl)] = {Point = entrypoint or stored.GetEntryPoint and stored.GetEntryPoint(pl, ent) or 0, ConvoType = convtype, Entity = ent} DEBUG("Conversation started "..tostring(ent).." "..tostring(pl))
	convo.Update(pl)
end

function convo.End(pl)
	local conv = convo.GetConversation(pl)
	if conv then
		conv.Point = -1
		convo.Update(pl)

		convo.Conversations[convo.GetConvoID(pl)] = nil DEBUG("Conversation ended "..tostring(ent).." "..tostring(pl))
	end
end

function convo.GetChoices(pl, conv)
	local stored = convo.StoredConversations[conv.ConvoType]

	local pointtab = stored.Points[conv.Point]
	if not pointtab then return {} end

	local choices = pointtab.BuildChoices and pointtab.BuildChoices(pl, conv) or table.Copy(pointtab.Choices) or {}
	if #choices == 0 or not pointtab.DontAutoCreateGoodbye and not stored.DontAutoCreateGoodbye then
		table.insert(choices, convo.DefaultGoodbye)
	end

	return choices
end

function convo.GetText(pl, conv)
	local stored = convo.StoredConversations[conv.ConvoType]

	local pointtab = stored.Points[conv.Point]
	if not pointtab then return "..." end

	return pointtab.BuildText and pointtab.BuildText(pl, conv) or pointtab.Text or "..."
end

function convo.Update(pl)
	local conv = convo.GetConversation(pl)
	if conv then
		if conv.Point == -1 then
			pl:SendLua("convo.CloseFrame()")
			--ent:Talk("Bye.", nil, CONVERSATION_RADIUS)
		else
			local text = convo.GetText(pl, conv)
			local ent = conv.Entity
			local valident = ValidEntity(ent)

			net.Start("rpg_convo_upd")
				net.WriteEntity(valident or NULL)
				net.WriteString(text)
				net.WriteTable(convo.GetChoices(pl, conv))
			net.Send(pl)

			if valident then
				if string.sub(text, 1, 1) == ">" then
					pl:Talk(text, pl, CONVERSATION_RADIUS)
				else
					ent:Talk(text, nil, CONVERSATION_RADIUS)
				end
			end
		end
	end
end

concommand.Add("convo_reply", function(pl, command, arguments)
	local conv = convo.GetConversation(pl)
	if not conv then return end
	local choice = tonumber(arguments[1]) or 1

	local sendalong = {}
	for i = 2, #arguments do
		sendalong[#sendalong + 1] = arguments[i]
	end

	local stored = convo.StoredConversations[conv.ConvoType]
	local choices = convo.GetChoices(pl, conv)
	local chosen = choices[choice]
	if not chosen then return end

	if chosen[1] == CHOICETYPE_POINT then
		local firstletter = string.sub(chosen[3], 1, 1)
		pl:Talk(chosen[3], (firstletter == ">" or firstletter == "(") and pl)

		if chosen[2] == -1 then
			convo.End(pl)
		else
			conv.Point = chosen[2]
			convo.Update(pl)
		end
	end
end)
