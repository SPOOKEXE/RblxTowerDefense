
-- handling all enemies

export type Enemy = {
	ID : string,
	Health : number, -- set to health of enemy via config
	Model : Instance,
	PathPoints : { BasePart },
	PathIndex : number, -- set to 2 when created
	IsUpdating : boolean,
}

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.SpawnEnemies( enemyId : string, spawnId : string, count : number, interval : number )

end

function Module.UpdateEnemies( dt : number )

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
