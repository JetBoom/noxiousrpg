ITEM.Name = "chunk of ore"
ITEM.Model = Model("models/props_junk/Rock001a.mdl")
ITEM.PhysMaterial = "rock"

function ITEM:SetContents(contents)
	self.Contents = contents
	self:GetItemData().RefreshCharacteristics(self)
end

function ITEM:RefreshCharacteristics()
	if self.Contents then
		local metalinfo = metal.BuildMetalInformation(self.Contents)
		self:SetColor(metalinfo.Color)
		self:SetMaterial(metalinfo.Material)
		self:SetMass(metalinfo.Mass)
	end
end

-- Can stack with exact copies.
function ITEM:CanStack(other)
	if self:GetDataName() == other:GetDataName() and self.Contents and other.Contents then
		for k, v in pairs(self.Contents) do
			if other.Contents[k] ~= v then return false end
		end

		return true
	end

	return false
end
