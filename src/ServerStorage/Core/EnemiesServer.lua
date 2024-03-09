
-- handling all enemies in the tower defense

export type Enemy = {
	ID : string,
	Health : number, -- set to health of enemy via config
	Model : Instance,
	PathPoints : { BasePart },
	PathIndex : number, -- set to 2 when created
	IsUpdating : boolean,
}

local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local EnemiesConfigModule = ReplicatedModules.Data.Enemies

local DefaultSpawnInterval : number = 2

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.SpawnQueue = {}

function Module.QueueSpawnEnemies( enemyId : string, spawnId : string, count : number, interval : number )
	local enemyConfig = EnemiesConfigModule.Enemies.GetConfigFromId(enemyId)
	assert( enemyConfig, 'Could not find enemy of id: '..tostring(enemyId) )

	local currentMap = SystemsContainer.MapServer.GetSpawnCFrameFromId( spawnId )
	assert( currentMap, 'There is no active map.' )

	-- check spawn queue for the enemyId
	if not Module.SpawnQueue[enemyId] then
		Module.SpawnQueue[enemyId] = { }
	end

	-- check if same enemies are spawning at the spawn location
	local SpawnData = Module.SpawnQueue[enemyId][spawnId]
	if SpawnData then
		SpawnData.Count += count
		SpawnData.Interval += interval
		SpawnData.Spawn += spawnId
	else -- otherwise create new spawn data for that spawn location
		Module.SpawnQueue[enemyId][spawnId] = {
			Count = count,
			Interval = interval,
			Spawn = spawnId,
			NextSpawnTick = 0,
		}
	end
end

function Module.CreateEnemyAt( enemyId, spawnId )

	local enemyConfig = EnemiesConfigModule.Enemies.GetConfigFromId(enemyId)
	assert( enemyConfig, 'Could not find enemy of id: '..tostring(enemyId) )

	local currentMap = SystemsContainer.MapServer.GetSpawnCFrameFromId( spawnId )
	assert( currentMap, 'There is no active map.' )



end

function Module.UpdateEnemies( dt : number )

end

function Module.SpawnQueueUpdate()
	-- update the spawn queue
	-- for each enemy id, for each spawn location, spawn if can and cleanup the table as it goes
	for enemyId, spawnsDict in pairs( Module.SpawnQueue ) do
		local totalSpawns : number = 0
		for spawnId, spawnData in pairs( spawnsDict ) do
			-- check if there is any enemies to spawn
			if spawnData.Count == 0 then
				spawnsDict[spawnId] = nil
				continue
			end
			-- there are enemies that still need to spawn, increment counter
			totalSpawns += 1
			-- check if the next enemy can spawn
			if tick() < spawnData.NextSpawnTick then
				continue
			end
			-- spawn the enemy
			spawnData.Count -= 1
			Module.CreateEnemyAt( enemyId, spawnId )
			spawnData.NextSpawnTick = tick() + spawnData.Interval
		end
		-- cleanup empty enemyId queues
		if totalSpawns == 0 then
			Module.SpawnQueue[enemyId] = nil
		end
	end
end

function Module.Start()

	task.spawn(function()
		while true do
			task.wait(0.1)
			Module.SpawnQueueUpdate()
		end
	end)

	RunService.Heartbeat:Connect(Module.UpdateEnemies)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
