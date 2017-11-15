CHOICETYPE_POINTBUTTON = 0
CHOICETYPE_POINT = CHOICETYPE_POINTBUTTON
CHOICETYPE_SLIDER = 1
CHOICETYPE_TEXTENTRY = 2

convo = {}
conversation = convo

convo.DefaultGoodbye = {CHOICETYPE_POINTBUTTON, -1, "Goodbye"}

function convo.GetConversationID(pl)
	return pl:UniqueID()
end
convo.GetConvoID = convo.GetConversationID

convo.StoredConversations = {
	["test"] = {
		Points = {
			[0] = {
				BuildText = function(pl, conv) return "Hello, "..pl:Name()..". This is a test conversation." end,
				--Text = "Hello!",
				Choices = {
					{CHOICETYPE_POINT, 1, "OK."},
					{CHOICETYPE_POINT, 2, "Tell me more."}
				}
			},
			[1] = {
				Text = "This should only have one choice: \"Goodbye\". It's automatically created."
			},
			[2] = {
				Text = "Did you know this is static text? It never changes. The choices are dynamic though.",
				BuildChoices = function(pl, conv)
					return {
						{CHOICETYPE_POINT, -1, os.time()},
						{CHOICETYPE_POINT, -1, pl:EntIndex()}
					}
				end
			}
		}
	},
	["test2"] = {
		Points = {
			[0] = {
				BuildText = function(pl, conv) return "Hello, "..pl:Name()..". This is another test conversation! It tests the self-thought and self-action character (>), the preemptive-action characters (things in between paranthesis), and actual physical things happening from a conversation." end,
				Choices = {
					{CHOICETYPE_POINT, 1, "(Punch them right in the face.)"},
					{CHOICETYPE_POINT, 2, "Okay."}
				}
			},
			[1] = {
				BuildText = function(pl, conv)
					pl:EmitSound("ambient/voices/citizen_punches2.wav")
					pl:TakeDamage(5, conv.Entity)
					return "> You take a swing at them. They avoid your punch and slap you across the face."
				end,
				Choices = {
					{CHOICETYPE_POINT, 3, "(...)"}
				}
			},
			[2] = {
				Text = "This should bring you back to the first choice in the conversation.",
				Choices = {
					{CHOICETYPE_POINT, 0, "Alright."}
				}
			},
			[3] = {
				Text = "Good try, faggot.",
				BuildChoices = function(pl, conv)
					return {
						{CHOICETYPE_POINT, -1, "Sayonara!"},
						{CHOICETYPE_POINT, -1, "Smell ya later!"},
						{CHOICETYPE_POINT, -1, "(Walk away)"}
					}
				end
			}
		}
	},
	["banker"] = {				-- The unique ID of the conversation.
		Points = {
			[0] = {					-- The default entry point is 0.
				Text = "How can I help you?", -- You can also use BuildText as a function(pl, conv) return somestring end
				Choices = { -- Choices from this point are...
					{CHOICETYPE_POINTBUTTON, 1, "What is my balance?"}, -- Choosing this goes to point 1.
					{CHOICETYPE_POINTBUTTON, 2, "I want to deposit gold."}, -- Goes to point 2
					{CHOICETYPE_POINTBUTTON, 3, "I want to widthdraw gold."}, -- Goes to point 3
					{CHOICETYPE_POINTBUTTON, -1, "Goodbye"} -- -1 ends the conversation. Goodbye is the text displayed as a choice (again, can be text or a function).
				}
			},
			[1] = {
				BuildText = function(pl, conv) return "Your current balance is "..pl:GetMoney().."." end,
				Choices = {
					{CHOICETYPE_POINTBUTTON, 0, "I have something else to ask."},
					{CHOICETYPE_POINTBUTTON, -1, "Goodbye"}
				}
			},
			[2] = {
				Text = "How much do you want to deposit?",
				Choices = {
					{CHOICETYPE_SLIDER, 0, 10000, 0, "Gold to deposit"},
					{CHOICETYPE_POINTBUTTON, 5, "That much"},
					{CHOICETYPE_POINTBUTTON, 0, "Uhh.. nevermind."},
					{CHOICETYPE_POINTBUTTON, -1, "Goodbye"}
				}
			}
		},
		DontAutoCreateGoodbye = true -- The 'goodbye' answer should be created manually. Otherwise it's on every screen.
	}
}
