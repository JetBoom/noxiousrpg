PixelMaps = {}

PixelMap = {}

local PixelMap = PixelMap
local meta = {__index = PixelMap}

function PixelMap.IsPixelMap(object)
	return getmetatable(object) == meta
end

function meta:GetWidth() return self.Width end
function meta:GetHeight() return self.Height end
function meta:GetLines() return self.Lines end

function meta:AddLine(x1, y1, x2, y2, col)
	self.Lines[#self.Lines + 1] = {x1, y1, x2, y2, col}
end

function meta:AddDot(x, y, col)
	self.Lines[#self.Lines + 1] = {x, y, x, y, col}
end

if CLIENT then
local colDefault = Color(255, 255, 255)
function meta:Draw(x, y, bgcolor)
	x = x or 0
	y = y or 0

	if bgcolor then
		surface.SetDrawColor(bgcolor)
		surface.DrawRect(x, y, self:GetWidth(), self:GetHeight())
	end

	if x == 0 and y == 0 then
		for _, line in pairs(self:GetLines()) do
			surface.SetDrawColor(line[5] or colDefault)
			surface.DrawLine(line[1], line[2], line[3], line[4])
		end
	else
		for _, line in pairs(self:GetLines()) do
			surface.SetDrawColor(line[5] or colDefault)
			surface.DrawLine(x + line[1], y + line[2], x + line[3], y + line[4])
		end
	end
end
meta.Render = meta.Draw
end

function meta:__tostring()
	return "PixelMap"
end

function meta:__eq(other)
	return other ~= nil and PixelMap.IsPixelMap(other) and other.ID == self.ID
end

function PixelMap:new(id, width, height)
	if PixelMaps[id] then return PixelMaps[id] end

	local map = {}
	setmetatable(map, meta)

	map.ID = id
	map.Width = width or 32
	map.Height = height or 32
	map.Lines = {}

	PixelMaps[id] = map

	return map
end

setmetatable(PixelMap, {__call = PixelMap.new})
