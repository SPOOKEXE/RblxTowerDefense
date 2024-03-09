
local ServerStorage = game:GetService("ServerStorage")
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local WavesConfigModule = ServerModules.Data.WavesConfig

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.CurrentMapInstance = nil
Module.CurrentMapID = nil

function Module.GetCurrentMapWavesConfig() : {}
	assert( Module.CurrentMapID, 'No map is currently selected.' )
	return WavesConfigModule.GetWaveDataFromId( Module.CurrentMapID )
end

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

	Module.CurrentMapID = mapId
	Module.CurrentMapInstance = workspace.Map0 -- temporary
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	Module.LoadMap( 'Map0' )
end

return Module
