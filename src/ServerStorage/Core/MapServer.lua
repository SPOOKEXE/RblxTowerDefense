
local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.CurrentMapInstance = nil

function Module.GetSpawnCFrameFromId( spawnId : string ) : CFrame?
	warn('NotImplementedError')
	return nil
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
end

return Module
