
local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.CurrentMapInstance = nil

function Module.GetWaypointsFromId( spawnId : string ) : {BasePart}?
	assert( Module.CurrentMapInstance, 'No map is currently selected.' )
	local Items = Module.CurrentMapInstance.Paths[spawnId]:GetChildren()
	table.sort(Items, function(a, b)
		return tonumber(a.name) < tonumber(b.Name) -- ascending order (lowest to highest)
	end)
	return Items
end

function Module.ClearMap()
	if Module.CurrentMapInstance then
		Module.CurrentMapInstance:Destroy()
	end
	Module.CurrentMapInstance = nil

end

function Module.LoadMap( mapId : string )
	Module.ClearMap() -- clears the current map if found

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	Module.CurrentMapInstance = workspace.Map0 -- temporary
end

return Module
