ITEM.DataIndex = 18

ITEM.Base = "gib_base"
ITEM.Model = "models/Gibs/pgib_p3.mdl"
ITEM.Mass = 1

if SERVER then
	function ITEM:OnCreated()
		self.Model = "models/Gibs/pgib_p"..math.random(2, 5)..".mdl"
	end
end

util.PrecacheModel("models/Gibs/pgib_p2.mdl")
util.PrecacheModel("models/Gibs/pgib_p3.mdl")
util.PrecacheModel("models/Gibs/pgib_p4.mdl")
util.PrecacheModel("models/Gibs/pgib_p5.mdl")

ITEM_NW_VAR_NAME("giblet")
