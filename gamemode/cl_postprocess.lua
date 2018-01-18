GM.PostProcessingEnabled = true
GM.ColorModEnabled = true

function GM:_RenderScreenspaceEffects()
	if not self.PostProcessingEnabled or render.GetDXLevel() < 80 then return end

	if MySelf:IsGhost() then
		self:GhostRenderScreenspaceEffects()
	end
end

local drawing = false

--local selfclip = false
function GM:PrePlayerDraw(pl)
	-- The entire purpose of this is to not draw the head bone. If I scale it down to 0 then the eye attachment isn't correct.
	--[[if drawing then return end
	if MySelf == pl and not pl.ThirdPerson and pl:OldAlive() and pl:ShouldDrawLocalPlayer() then
		local eyes = EyePos()
		local clipnormal = pl:LocalToWorld(pl:OBBCenter()) - eyes
		clipnormal:Normalize()

		render.EnableClipping(true)
		render.PushCustomClipPlane(clipnormal, clipnormal:Dot(eyes + clipnormal * 4.75))

		selfclip = true
	end]]
end

local matGhost = CreateMaterial("GhostMaterial", "VertexLitGeneric", {["$basetexture"] = "color/white", ["$vertexalpha"] = "1", ["$model"] = "1"})
function GM:PostPlayerDraw(pl)
	if drawing then return end

	--[[if selfclip then
		selfclip = false

		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end]]

	if not drawing and pl:IsGhost() then
		if self:PlayerCanSeeGhost(MySelf, pl) then
			render.SetBlend(0.07)
			render.SetColorModulation(0.8, 0.9, 0.95)
			SetMaterialOverride(matGhost)

			drawing = true
			pl:DrawModel()
			drawing = false

			SetMaterialOverride()
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
		end
	end
end

local tColorModGhost = {
	["$pp_colour_contrast"] = 1.05, --1.25,
	["$pp_colour_colour"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.01,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local fGateColorOffset = 0

function GM:GhostRenderScreenspaceEffects()
	local fRealTime = RealTime()

	if self.ColorModEnabled then
		tColorModGhost["$pp_colour_colour"] = fGateColorOffset - math.sin(fRealTime * 2) * 0.065 -- Color mod is closer to normal when facing a gate.
		DrawColorModify(tColorModGhost)
	end

	fGateColorOffset = 0
	if render.SupportsPixelShaders_2_0() then
		local eyepos = EyePos()
		local vOffset = Vector(math.sin(fRealTime) * 8, math.cos(fRealTime) * 8, math.sin(CurTime()) * 8)
		for _, ent in pairs(ents.FindByClass("point_resurrectiongate")) do
			local pos = ent:LocalToWorld(ent:OBBCenter()) + vOffset
			local distance = eyepos:Distance(pos)
			local dot = (pos - eyepos):GetNormalized():Dot(EyeVector()) - distance * 0.0005
			if dot > 0 then
				fGateColorOffset = math.max(dot * 0.85, fGateColorOffset)

				local srcpos = pos:ToScreen()
				DrawSunbeams(0.8, dot * 6, 0.2, srcpos.x / w, srcpos.y / h)
			end
		end
	end

	-- Personal light only the local player can see.
	if DYNAMICLIGHTING then
		local dlight = DynamicLight(MySelf:EntIndex() + 4096)
		if dlight then
			dlight.Pos = MySelf:EyePos()
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 0.5
			dlight.Size = 128
			dlight.Decay = 512
			dlight.DieTime = CurTime() + 1
		end
	end
end
