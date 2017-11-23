GM.Floaties = {}
local Floaties = GM.Floaties

usermessage.Hook("floatie", function(um)
	local ent = um:ReadEntity()
	local colid = um:ReadChar()
	local text = um:ReadString()

	if ent:IsValid() then
		ent:Floatie(text, colid)
	end
end)

local colBG = Color(0, 0, 0, 255)
hook.Add("PostDrawOpaqueRenderables", "FloatiePostDrawOpaqueRenderables", function()
	if #Floaties == 0 then return end

	surface.SetFont("rpg_notice")

	local done = true
	for _, tab in pairs(Floaties) do
		local ent = tab.Entity
		if ent:IsValid() then
			local delta = tab.EndTime - CurTime()
			if delta > 0 then
				done = false

				delta = math.min(delta, 1)

				local pos = ent:GetPos() + ent:GetUp() * (ent:OBBMaxs().z + delta ^ 2 * 32)
				local ang = (EyePos() - pos):Angle()
				local oldup = ang:Up()
				local oldright = ang:Right()

				local tw, th = surface.GetTextSize(tab.Text)
				local color = ent:GetColor()

				colBG.a = delta * 255 * (color.a / 255)
				tab.Color.a = colBG.a

				ang:RotateAroundAxis(ang:Right(), 270)
				ang:RotateAroundAxis(ang:Up(), 90)
				cam.Start3D2D(pos, ang, delta * 0.75)
					draw.SimpleText(tab.Text, "rpg_notice", tw * -0.5, 0, tab.Color, colBG)
				cam.End3D2D()
			end
		end
	end

	if done then
		Floaties = {}
		GAMEMODE.Floaties = Floaties
	end
end)
