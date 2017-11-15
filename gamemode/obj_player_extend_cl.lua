local meta = FindMetaTable("Player")
if not meta then return end

function meta:CustomGesture(gesture)
	self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, gesture)
end
usermessage.Hook("cusges", function(um)
	local ent = um:ReadEntity()
	local gesture = um:ReadShort()
	if ent:IsValid() then
		ent:CustomGesture(gesture)
	end
end)

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetRenderAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

function meta:SecondTick()
	self:CallMonsterFunction("SecondTick")
end

function meta:SimulateItemRemove(ent, id, amount)
end

function meta:SetCriminal(tim)
	self:SetNetworkedFloat("crimtime", math.min(tim, CurTime() + CRIMINAL_MAXIMUM))
end

function meta:OpenInventory()
	RunConsoleCommand("rpg_requestinventory", MySelf:EntIndex())
	MakepContainer(MySelf:GetContainer())
end

function meta:CloseInventory()
	local containerpanel = self:GetContainerPanel()
	if containerpanel and containerpanel:Valid() then
		containerpanel:Close()
	end
end

function meta:ToggleInventory()
	local containerpanel = self:GetContainerPanel()
	if containerpanel and containerpanel:Valid() and containerpanel:IsVisible() then
		self:CloseInventory()
	else
		self:OpenInventory()
	end
end

function meta:OpenSkills()
	MakepSkills(MySelf)
end

function meta:CloseSkills()
	local containerpanel = self.m_SkillPanel
	if containerpanel and containerpanel:Valid() then
		containerpanel:Close()
	end
end

function meta:ToggleSkills()
	local containerpanel = self.m_SkillPanel
	if containerpanel and containerpanel:Valid() and containerpanel:IsVisible() then
		self:CloseSkills()
	else
		self:OpenSkills()
	end
end

function meta:CreatePlayerCorpse()
end

function meta:SetMaxHealth(num)
	num = math.ceil(num)
	self:SetDTInt(3, num)
	if num < self:Health() then
		self:SetHealth(num)
	end
end

function meta:SetMaxMana(amount, regeneration)
	self.MaxMana = amount
	self.ManaRegenerate = regeneration
end

--[[function meta:SetMaxStamina(amount, regeneration)
	self.MaxStamina = amount
	self.StaminaRegenerate = regeneration
end]]

function meta:SendLua(str)
	if self == MySelf then
		RunString(str)
	end
end

function meta:HostileAction(ent)
end
meta.HarmfulAction = meta.HostileAction

function meta:BeneficialAction(ent)
end
meta.HelpfulAction = meta.BeneficialAction

function meta:UpdateSkills()
end

function meta:SetSkill(skillid, amount)
	local old = self:GetSkill(skillid)
	if old ~= amount then
		self.Skills[skillid] = amount
		gamemode.Call("PlayerSkillChanged", self, skillid, amount)
	end
end

--[[function meta:SetStamina(stamina)
	self.Stamina = stamina
	self.StaminaBase = CurTime()
end]]

--[[function meta:UpdateStamina()
end]]

function meta:SetMana(mana)
	self.Mana = mana
	self.ManaBase = CurTime()
end

function meta:UpdateMana()
end

meta.OldGetMaxHealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	return math.max(1, self:GetDTInt(3))
end

function meta:KnockDown(tim)
end

local function empty() end
meta.RemoveStatus = meta.RemoveStatus or empty
meta.GiveStatus = meta.GiveStatus or empty
meta.DrawWorldModel = meta.DrawWorldModel or empty
meta.DrawViewModel = meta.DrawViewModel or empty
