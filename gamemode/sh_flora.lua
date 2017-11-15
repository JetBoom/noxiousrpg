-- TODO: Zones have region types and trees use different models / effects?

GM.TreeModels = {
	Model("models/props_foliage/tree_deciduous_01a.mdl"),
	Model("models/props_foliage/tree_deciduous_02a.mdl"),
	Model("models/props_foliage/tree_deciduous_03a.mdl"),
	Model("models/props_foliage/tree_deciduous_03b.mdl")
}

GM.LogModels = {
	Model("models/props_docks/dock01_pole01a_128.mdl"),
	Model("models/props_docks/dock02_pole02a_256.mdl"),
	Model("models/props_docks/dock02_pole02a.mdl")
}

function GM:GetRandomTreeModel()
	return self.TreeModels[math.random(1, #self.TreeModels)]
end

function GM:GetLogModel(stage)
	return self.LogModels[math.Clamp(stage or 1, 1, #self.LogModels)]
end
