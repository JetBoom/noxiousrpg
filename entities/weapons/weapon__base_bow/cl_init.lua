include("shared.lua")

local hud_BowchargeX = CreateClientConVar("rpg_hud_bowcharge_x", 0.5, true, false)
local hud_BowchargeY = CreateClientConVar("rpg_hud_bowcharge_y", 0.6, true, false)

function SWEP:DrawHUD()
	local charge = self:GetCharge()
	if charge <= 0 then return end

	local wid, hei = h * 0.2, h * 0.01
	local x = hud_BowchargeX:GetFloat() * w
	local y = hud_BowchargeY:GetFloat() * h

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(x - wid * 0.5, y, wid, hei)

	surface.SetDrawColor(charge * 255, 0, 255 - charge * 255, 220)
	surface.DrawRect(x - wid * 0.5, y, wid * charge, hei)

	surface.SetDrawColor(60, 60, 60, 220)
	surface.DrawLine(x, y, x, y + hei)
	surface.DrawLine(x - wid * 0.4, y, x - wid * 0.4, y + hei)
	surface.DrawLine(x - wid * 0.2, y, x - wid * 0.2, y + hei)
	surface.DrawLine(x + wid * 0.4, y, x + wid * 0.4, y + hei)
	surface.DrawLine(x + wid * 0.2, y, x + wid * 0.2, y + hei)

	if charge == 1 then
		local brit = math.sin(RealTime() * 8) * 127.5 + 127.5
		surface.SetDrawColor(brit, brit, brit, 255)
	end

	surface.DrawOutlinedRect(x - wid * 0.5, y, wid, hei)
end
