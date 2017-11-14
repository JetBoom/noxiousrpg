include("shared.lua")
include("obj_entity_extend_cl.lua")
include("obj_player_extend_cl.lua")

include("cl_postprocess.lua")
include("cl_scoreboard.lua")
include("cl_notice.lua")
include("cl_dermaskin.lua")
include("cl_boneanimlib.lua")
include("cl_talk.lua")
include("cl_floaties.lua")
include("cl_convo.lua")

include("cl_animeditor.lua")

include("vgui/dpersistframe.lua")
include("vgui/dmodelpanel2.lua")
include("vgui/pitem.lua")
include("vgui/pskills.lua")
include("vgui/pcontainer.lua")
include("vgui/photbar.lua")
include("vgui/progressbar.lua")
include("vgui/dvitals.lua")

local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT

if not MySelf then MySelf = NULL end
hook.Add("InistPostEntity", "GetLocal", function()
	hook.Remove("InitPostEntity", "GetLocal")
	MySelf = LocalPlayer()
	gamemode.Call("GotLocalPlayer", MySelf)
	gamemode.Call("HookGetLocal", MySelf)
	RunConsoleCommand("PostPlayerInitialSpawn")
end)

w, h = ScrW(), ScrH()

function BroadcastLua(str)
	RunString(str)
end

concommand.Add("rpg_test_printmyinventory", function(sender, command, arguments)
	PrintTable(MySelf:GetContainer())
end)

concommand.Add("rpg_test_printmyskills", function(sender, command, arguments)
	PrintTable(MySelf.Skills)
end)

function GM:OnWeatherChanged(weatherid, previousid)
	for _, ent in pairs(ents.GetAll()) do
		if ent.OnWeatherChanged then
			pcall(ent.OnWeatherChanged, ent, weatherid, previousid)
		end
	end
end

function GM:SetWeather(weatherid, previousweatherid)
	self.PreviousWeather = previousweatherid or self:GetWeather()
	self.CurrentWeather = weatherid

	gamemode.Call("OnWeatherChanged", weatherid, self.PreviousWeather)
end

function GM:DrawDeathNotice()
end

function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

function GM:HUDWeaponPickedUp(wep)
end

function GM:HUDItemPickedUp(itemname)
end

function GM:HUDAmmoPickedUp(itemname, amount)
end

--[[local InvisibleBone = "ValveBiped.Bip01_Head1"
local HeadTranslates = {}
HeadTranslates["models/zombie/classic.mdl"] = "ValveBiped.Bip01_Spine2"
HeadTranslates["models/zombie/poison.mdl"] = "ValveBiped.Bip01_Spine4"
HeadTranslates["models/zombie/fast.mdl"] = "ValveBiped.HC_BodyCube"
local vector_origin = vector_origin
local vecFull = Vector(1, 1, 1)
local function BuildBonePositions(self)
	local boneid = self:LookupBone(HeadTranslates[string.lower(self:GetModel())] or InvisibleBone)
	if boneid then
		local matrix = self:GetBoneMatrix(boneid)
		if self.ThirdPerson then
			matrix:Scale(vecFull)
		else
			matrix:Scale(vector_origin)
		end
		self:SetBoneMatrix(boneid, matrix)
	end
end]]

function GM:HookGetLocal(pl)
	-- The purpose of this is to call these expensive functions without having to check if LocalPlayer() is valid or not.
	self.Think = self._Think
	self.RenderScreenspaceEffects = self._RenderScreenspaceEffects
	self.HUDShouldDraw = self._HUDShouldDraw
	self.ShouldDrawLocalPlayer = self._ShouldDrawLocalPlayer
	self.ItemReceived = self._ItemReceived
	self.HUDPaint = self._HUDPaint

	pl.Mana = pl.Mana or 0
	pl.ManaBase = pl.ManaBase or CurTime()
	pl.MaxMana = pl.MaxMana or 100
	pl.ManaRegenerate = pl.ManaRegenerate or 0
	--[[pl.Stamina = pl.Stamina or 0
	pl.StaminaBase = pl.StaminaBase or CurTime()
	pl.MaxStamina = pl.MaxStamina or 100
	pl.StaminaRegenerate = pl.StaminaRegenerate or 0]]
	pl.Skills = pl.Skills or {}

	--pl.BuildBonePositions = BuildBonePositions

	pl.m_NextSecondTick = 0
	pl.ViewOffset = 22

	self.PreviousCriminal = pl:IsCriminal()

	local screenscale = BetterScreenScale()
	local VitalsPanel = vgui.Create("DVitals")
	VitalsPanel:AlphaTo(160, 0.5, 0)
	VitalsPanel:SetSize(screenscale * 256, 76)
	VitalsPanel:SetEntity(pl)
	VitalsPanel:AlignBottom(screenscale * 92)
	VitalsPanel:CenterHorizontal()
	self.VitalsPanel = VitalsPanel
end

function GM:_ShouldDrawLocalPlayer()
	return not MySelf:GetRagdollEntity()
end

function GM:_HUDShouldDraw(name)
	if name == "CHudDamageIndicator" then
		return MySelf:Alive()
	--elseif name == "CHudCrosshair" then
		--return not MySelf.ThirdPerson
	end

	return name ~= "CHudHealth" and name ~= "CHudBattery" and name ~= "CHudAmmo" and name ~= "CHudSecondaryAmmo"
end

function ExplosiveEffect(pos, maxrange, damage, dmgtype)
	--ExplosiveDamage(MySelf, MySelf, pos, maxrange, damage, 10, nil, nil, damage, dmgtype)

	local pos2 = pos + Vector(0,0,12)
	for _, pl in pairs(player.GetAll()) do
		local rag = pl:GetRagdollEntity()
		if rag and not rag.Frozen then
			local phys = rag:GetPhysicsObject()
			if phys:IsValid() then
				local physpos = phys:GetPos()
				local dist = physpos:Distance(pos)
				if dist < maxrange then
					for i=0, rag:GetPhysicsObjectCount() do
						local subphys = rag:GetPhysicsObjectNum(i)
						if subphys then
							subphys:Wake()
						end
					end

					if dmgtype == DMGTYPE_FIRE then
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):Normalize(), pos2)
						if not rag.Burnt then
							local effectdata = EffectData()
								effectdata:SetOrigin(physpos)
								effectdata:SetEntity(pl)
							util.Effect("deatheffect_fire", effectdata)
							rag:EmitSound("ambient/fire/mtov_flame2.wav", 65, math.random(105, 110))
						end
					elseif dmgtype == DMGTYPE_ENERGY then
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):Normalize(), pos2)
						if not rag.Electricuted then
							local effectdata = EffectData()
								effectdata:SetOrigin(physpos)
								effectdata:SetEntity(pl)
							util.Effect("deatheffect_electric", effectdata)
						end
					elseif dmgtype == DMGTYPE_COLD then
						phys:ApplyForceOffset(damage * 500 * maxrange / dist * (physpos - pos):Normalize(), pos2)
						local effectdata = EffectData()
							effectdata:SetOrigin(physpos)
							effectdata:SetEntity(pl)
						util.Effect("deatheffect_ice", effectdata)
					else
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):Normalize(), pos2)
					end
				end
			end
		end
	end
end

function GM:Initialize()
	gamemode.Call("CreateFonts")
	gamemode.Call("ParseParticleManifests")
	gamemode.Call("InitializeSoundSets")
	gamemode.Call("LoadHotBars")
	gamemode.Call("CreateHotBar")
end

function GM:CreateFonts()
	--surface.CreateFont("tahoma", 22, 600, true, false, "rpg_notice", true)
	surface.CreateFont("MasonAlternate", 32, 0, true, false, "rpg_notice", true)

	--surface.CreateFont("coolvetica", 24, 500, true, false, "rpg_targetid_item")
	surface.CreateFont("MasonAlternate", 24, 0, true, false, "rpg_targetid_item", true)

	--surface.CreateFont("coolvetica", 24, 0, false, false, "rpg_talk")
	surface.CreateFont("MasonAlternate", 24, 0, true, false, "rpg_talk")

	surface.CreateFont("MasonAlternate", 22, 0, true, false, "rpg_derma_default")
	surface.CreateFont("MasonAlternate", 18, 0, true, false, "rpg_derma_small")

	for i=8, 64, 2 do
		surface.CreateFont("tahoma", i, 300, true, false, "tahoma"..i)
		surface.CreateFont("akbar", i, 300, true, false, "akbar"..i)
		surface.CreateFont("coolvetica", i, 300, true, false, "coolvetica"..i)

		surface.CreateFont("MasonAlternate", i, 300, true, false, "mason"..i)
		surface.CreateFont("SteveHandwriting", i, 300, true, false, "steve"..i)
		surface.CreateFont("Carleton", i, 300, true, false, "carleton"..i)
		surface.CreateFont("Dauphin", i, 300, true, false, "dauphin"..i)
	end
end

function GM:ShutDown()
end

function GM:InitPostEntity()
end

function GM:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume)
end

function GM:ItemReceived(item)
end

function GM:_ItemReceived(item)
	VERBOSE(item, item.ID, item:GetEntity(), item:GetRootEntity())

	-- If this item is a container and has an owner, try to attach it to a player.
	local owneruid = item.Owner
	if owneruid then
		for _, pl in pairs(player.GetAll()) do
			if pl:UniqueID() == owneruid then
				pl:SetContainer(item)
				break
			end
		end
	end

	-- If we're viewing a container, refresh that container
	local curpanel = pContainer[item.ID]
	if curpanel and curpanel:IsValid() and curpanel:IsVisible() then
		MakepContainer(item)
	end
end

usermessage.Hook("updskill", function(um)
	if MySelf:IsValid() then
		MySelf:SetSkill(um:ReadShort(), um:ReadFloat())
	end
end)

usermessage.Hook("SLM", function(um)
	MySelf.Mana = um:ReadFloat()
	MySelf.ManaBase = um:ReadFloat()
end)

--[[usermessage.Hook("SLS", function(um)
	MySelf.Stamina = um:ReadFloat()
	MySelf.StaminaBase = um:ReadFloat()
end)]]

GM.m_PreviousCriminal = false
function GM:CheckCriminalState()
	if MySelf:IsCriminal() then
		if not self.m_PreviousCriminal then
			self.m_PreviousCriminal = true
			self:AddNotify2("You are now considered a criminal!~sambient/alarms/klaxon1.wav", COLOR_RED, true)
		end
	elseif self.m_PreviousCriminal then
		self.m_PreviousCriminal = false
		self:AddNotify2("You are no longer considered a criminal.~sweapons/physgun_off.wav", COLOR_LIGHTBLUE, true)
	end
end

function GM:_Think()
	if CurTime() >= MySelf.m_NextSecondTick then
		MySelf.m_NextSecondTick = CurTime() + 1
		MySelf:SecondTick()
	end

	MySelf:Think()
end

-- Not active in GM:Think()
--function GM:GhostThink()
--end

local vcamyaw = 180
local function VanityCam(pl, origin, angles, fov)
	if pl:KeyDown(IN_MOVELEFT) then
		vcamyaw = vcamyaw - FrameTime() * 45
	elseif pl:KeyDown(IN_MOVERIGHT) then
		vcamyaw = vcamyaw + FrameTime() * 45
	end

	angles:RotateAroundAxis(angles:Up(), vcamyaw)
	return {origin = origin + angles:Forward() * -64, angles = angles}
end

concommand.Add("vanitycam", function(sender, command, arguments)
	VANITYCAM = not VANITYCAM

	if VANITYCAM then
		hook.Add("CalcView", "VanityCam", VanityCam)
	else
		hook.Remove("CalcView", "VanityCam")
	end
end)

-- Edited to allow a fourth argument, the local camera position.
-- Do NOT use the local camera position sent by the client for distance and sanity checks!!!
function GM:CallScreenClickHook(bDown, mousecode, AimVector)
	local idown
	if bDown then
		idown = 1
	else
		idown = 0
	end

	local CameraPos = GetCameraPos()
	RunConsoleCommand("cnc", idown, mousecode, AimVector.x, AimVector.y, AimVector.z, CameraPos.x, CameraPos.y, CameraPos.z)
	hook.Call("ContextScreenClick", GAMEMODE, AimVector, mousecode, bDown, LocalPlayer(), CameraPos)
end

concommand.Add("_rpg_setviewoffset", function(pl, command, arguments)
	local viewoffset = tonumber(arguments[1])
	if not viewoffset then return end
	local thirdperson = tonumber(arguments[2]) == 1

	pl.ViewOffset = math.Clamp(viewoffset, -22, 22)
	pl.ThirdPerson = thirdperson

	-- This is for hats and stuff.
	NOX_VIEW = thirdperson

	RunConsoleCommand("_rpg_setviewoffsetsync", viewoffset, inoxview)
end)

function GM:CalcView(pl, origin, angles, fov, znear, zfar)
	if pl:OldAlive() then
		if pl:ShouldDrawLocalPlayer() then
			origin = pl:GetCameraPos(origin, angles)

			if not pl.ThirdPerson then
				local attach = pl:GetNamedAttachment("eyes")
				if attach then
					angles.roll = angles.roll + math.Clamp(attach.Ang.roll * 0.2, -25, 25)
				end
			end
		elseif pl:GetRagdollEntity() then
			local rpos, rang = pl:GetRagdollEyes()
			if rpos then
				origin = rpos
				angles = rang
			end
		end

		if pl:IsGhost() then
			fov = fov + math.abs(math.sin(RealTime() * 0.5)) * 7
		end
	end

	return self.BaseClass.CalcView(self, pl, origin, angles, fov, znear, zfar)
end

function GM:PlayerBindPress(pl, bind, wasin)
	if not wasin then return end

	if bind == "slot0" then
		if pl.ThirdPerson then
			if pl.ViewOffset == 22 then
				RunConsoleCommand("_rpg_setviewoffset", 0, 1)
			elseif pl.ViewOffset == 0 then
				RunConsoleCommand("_rpg_setviewoffset", -22, 1)
			else
				RunConsoleCommand("_rpg_setviewoffset", 0, 0)
			end
		else
			RunConsoleCommand("_rpg_setviewoffset", 22, 1)
		end

		return true
	elseif bind:sub(1, 4) == "slot" then
		local i = tonumber(bind:sub(5))
		if i and i >= 1 and i <= HOTBAR_CELLCOUNT and self.HotBar and self.HotBar:IsValid() then
			self.HotBar:HotBarPressed(i)
		end

		return true
	end
end

function GM:ToggleContext(force)
	if force ~= nil then
		self.ContextOn = force
	else
		self.ContextOn = not self.ContextOn
	end

	if self.ContextOn then
		gui.EnableScreenClicker(true)
		RestoreCursorPosition()
	else
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
	end
end

function GM:OnContextMenuClose()
	self:ToggleContext(false)
end

function GM:OnContextMenuOpen()
	self:ToggleContext(true)
end

local texHealthBar = surface.GetTextureID("gui/gradient_down")
function GM:DrawHealthBar(x, y, width, height, name, inbartext, namecolor, health, maxhealth)
	if self.NoHUD then return end

	local screenscale = BetterScreenScale()
	local wid = screenscale * width
	local hei = screenscale * height

	if name then
		draw.SimpleText(name, "TargetID", x, y, namecolor, color_black, TEXT_ALIGN_CENTER)
		y = y + draw.GetFontHeight("TargetID") + 2
	end

	x = x - wid * 0.5

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(x, y, wid, hei)
	surface.SetDrawColor(namecolor.r, namecolor.g, namecolor.b, namecolor.a)
	surface.SetTexture(texHealthBar)
	local wid2 = wid * (health / maxhealth)
	surface.DrawTexturedRect(x, y, wid2, hei)
	surface.SetDrawColor(namecolor.r, namecolor.g, namecolor.b, namecolor.a * 0.1)
	surface.DrawRect(x, y, wid2, hei)
	surface.SetDrawColor(30, 30, 30, 255)
	surface.DrawOutlinedRect(x, y, wid, hei)
	surface.SetDrawColor(20, 20, 20, 255)
	surface.DrawOutlinedRect(x + 1, y + 1, wid - 2, hei - 2)
	surface.SetDrawColor(10, 10, 10, 255)
	surface.DrawOutlinedRect(x + 2, y + 2, wid - 4, hei - 4)

	if inbartext then
		draw.SimpleText(inbartext, "TargetID", x + wid * 0.5, y + hei * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

-- Overrides the mouse pos functions so it returns the center of the screen instead of 0 when the mouse isn't on.
function MousePos()
	local mx, my = gui.MousePos()
	if mx == 0 and my == 0 then
		return w * 0.5, h * 0.5
	end

	return mx, my
end

function MouseX()
	local mx, my = gui.MousePos()
	if mx == 0 and my == 0 then
		return w * 0.5
	end

	return mx
end

function MouseY()
	local mx, my = gui.MousePos()
	if mx == 0 and my == 0 then
		return h * 0.5
	end

	return my
end

function GM:_HUDPaint()
	if self.NoHUD then return end

	w, h = ScrW(), ScrH()

	self:PaintNotes()
	self:PaintTargetID()

	if not self.MovieHUD then
		self:PaintHUD()
	end
end

function GM:PaintTargetID()
	local eyetrace = EyeTrace()
	local eyeent = eyetrace.Entity
	if eyeent:IsValid() then
		if eyeent.PaintTargetID then
			eyeent:PaintTargetID(eyeent, eyetrace)
		elseif eyeent:IsCharacter() then
			self:PaintTargetIDCharacter(eyeent, eyetrace)
		else
			local itemdata = eyeent:GetItem() or eyeent:GetDefaultItemData()
			if itemdata then
				draw.WordBox(util.NameByAmount(itemdata.Name, eyeent:GetAmount()), "rpg_targetid_item", MouseX(), MouseY() + 16, color_white, color_black_alpha90, TEXT_ALIGN_CENTER)
			end
		end
	end
end

function GM:PaintTargetIDCharacter(eyeent, eyetrace)
	local col = eyeent:GetNameColor(MySelf)

	local x, y = MousePos()

	self:DrawHealthBar(x, y, 150, 16, eyeent:RPGName(MySelf), nil, col, eyeent:Health(), eyeent:GetMaxHealth())

	local guild = eyeent:GetGuild()
	if guild and guild.Name then
		draw.SimpleText(guild.Name, "DefaultBold", x, y + 40 * BetterScreenScale(), col, COLOR_BLACK, TEXT_ALIGN_CENTER)
	end
end

function GM:PaintHUD()
end

function GM:OnSkillsReceived()
end

function GM:OnInventoryReceived(ent)
	if pContainer[ent] and pContainer[ent]:IsValid() and pContainer[ent]:IsVisible() then
		MakepContainer(ent)
	end
end

function GM:HUDPaintBackground()
end

function GM:CreateMove(cmd)
end

function GM:PostProcessPermitted(str)
	return false
end

function GM:PlayerSpawn(pl)
	pl.SpawnTime = CurTime()

	pl:ResetData()
end

function GetCameraPos()
	return MySelf:GetCameraPos()
end

function EyeTrace(length, mask)
	local pos = GetCameraPos()
	return util.TraceLine({start = pos, endpos = pos + (length or MOUSE_TRACEDISTANCE) * MySelf:GetCursorAimVector(), mask = mask or MASK_SOLID, filter = MySelf})
end

usermessage.Hook("PlayerSpawn", function(um)
	local pl = um:ReadEntity()
	if pl:IsValid() then
		gamemode.Call("PlayerSpawn", pl)
	end
end)

usermessage.Hook("recinfo", function(um)
	local ent = um:ReadEntity()
	if ent:IsValid() and ent.Info then
		ent:Info(um)
	end
end)

NDB.AddContentsCallback(LONGSTRING_UPDATEALLZONES, function(contents)
	local tab = GetAllZones()

	for k, v in pairs(tab) do
		tab[k] = nil
	end

	for k, v in pairs(Deserialize(contents)) do
		tab[k] = v
	end
end)

NDB.AddContentsCallback(LONGSTRING_UPDATESKILLS, function(contents)
	for k, v in pairs(Deserialize(contents)) do
		MySelf:SetSkill(k, v)
	end
	gamemode.Call("OnSkillsReceived")
end)

-- DEBUG stuff

local matGenericGlow = Material("sprites/glow04_noz")
function GenericSprite(pos, size)
	size = size or 32
	render.SetMaterial(matGenericGlow)
	render.DrawSprite(pos, size, size, color_white)
end

local matGenericLine = Material("effects/laser1")
function GenericLine(pos2, pos2, size)
	size = size or 8
	render.SetMaterial(matGenericLine)
	render.DrawBeam(pos1, pos2, size, 1, color_white)
end

effects.Register({Init = function(self, data)
	local emitter = ParticleEmitter(data:GetOrigin())
	emitter:SetNearClip(24, 32)
	local particle = emitter:Add("sprites/glow04_noz", data:GetOrigin())
	particle:SetStartSize(8)
	particle:SetEndSize(128)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetDieTime(0.5)
end, Think = function(self) return false end, Render = function(self) end}, "genericexplosion")
