--[[
This is probably one of the simplest things ever once I found out about EF_BONEMERGE.
The purpose of this is to allow new animations to be added without having to recompile
all of the player models. Instead, we just have all the human players set to one model
and then parent a non-solid, non-moving prop with EF_BONEMERGE. The end result is default
player models with brand new animations and other stuff.
]]
--[[
local meta = FindMetaTable("Entity")
if not meta then return end

function meta:GetRig()
	return self.m_Rig or NULL
end

function meta:RemoveRig()
	local rig = self:GetRig()
	if rig:IsValid() then rig:Remove() end
	self.m_Rig = nil
end

function meta:CreateRig(mdl)
	self:RemoveRig()

	local ent = ents.Create("prop_modelrig")
	if ent:IsValid() then
		ent:SetModel(mdl)
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:Spawn()

		self.m_Rig = ent
	end
end

-- Better off doing this than rewriting everything.
meta.OldGetModel = meta.GetModel
function meta:GetModel()
	if self:GetRig():IsValid() then
		return self:GetRig():OldGetModel()
	end

	return self:OldGetModel()
end
]]
