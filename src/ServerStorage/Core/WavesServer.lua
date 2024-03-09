-- handle inserting waves into queue using enemiesservice and configuration

local RunService = game:GetService("RunService")

local ServerStorage = game:GetService("ServerStorage")
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local WavesConfigModule = ServerModules.Data.WavesConfig

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local NumbersModule = ReplicatedModules.Utility.Numbers

local SystemsContainer = {}

local CurrentWaveIndex = 1
local StartingGracePeriod = 30

-- // Module // --
local Module = {}

function Module.IterateWaves()

	local MapWavesArray = SystemsContainer.MapServer.GetCurrentMapWavesConfig()

	ReplicatedStorage.CurrentWave.Value = 0
	ReplicatedStorage.TotalWaves.Value = #MapWavesArray

	-- grace period
	for second = 0, StartingGracePeriod - 1 do
		local RemainingGrace : number = (StartingGracePeriod - second)
		ReplicatedStorage.TimerValue.Value = 'Grace Period: ' .. NumbersModule.FormatForTimer( RemainingGrace, false )
		task.wait(1)
	end

	-- wave iteration
	for waveIndex, waveData in ipairs( MapWavesArray ) do
		ReplicatedStorage.CurrentWave.Value = waveIndex
		for enemyId : string, spawnDict : {} in pairs(waveData.Enemies) do
			for spawnId : string, spawnData : {} in pairs(spawnDict) do
				SystemsContainer.EnemiesServer.QueueSpawnEnemies( enemyId, spawnId, spawnData.Count, spawnData.Interval )
			end
		end
		for second = 0, waveData.Duration - 1 do
			if SystemsContainer.GameControllerServer.IsGameOver() then
				break
			end
			local RemainingWave : number = (waveData.Duration - second)
			ReplicatedStorage.TimerValue.Value = 'Next Wave in ' .. NumbersModule.FormatForTimer( RemainingWave, false )
			task.wait(1)
		end
		if SystemsContainer.GameControllerServer.IsGameOver() then
			break
		end
	end

	-- game finished
	ReplicatedStorage.TimerValue.Value = 'Game Finished'
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
