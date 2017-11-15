include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Persist = true

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetNoDraw(true)
end

function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setenvironment" or name == "setweather" then
		local _, __, weatherid, interpolate = string.find(args, "(%d+)%s(%d+)")
		if weatherid then
			self:SetWeather(weatherid, interpolate)
		end
		local _, __, weatherid, interpolate = string.find(args, "(.+)%s(%d+)")
		if weatherid and _G[weatherid] then
			self:SetWeather(_G[weatherid], interpolate)
		end
		return true
	end
end

function ENT:SetWeather(weatherid, interpolate)
	gamemode.Call("SetWeather", weatherid, interpolate)
end

function ENT:OnSave(tab)
	tab.CurrentWeather = GAMEMODE.CurrentWeather
	tab.WeatherInterp = GAMEMODE.WeatherInterp
end

function ENT:OnLoaded(tab)
	self:SetWeather(tab.CurrentWeather, math.max(0, tab.WeatherInterp - os.time()))
end
