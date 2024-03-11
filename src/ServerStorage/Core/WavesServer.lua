-- handle inserting waves into queue using enemiesservice and configuration

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local NumbersModule = ReplicatedModules.Utility.Numbers

local SystemsContainer = {}

local GRACE_PERIOD : number = 15

-- // Module // --
local Module = {}

function Module.IterateWaves()

	local MapWavesArray = SystemsContainer.MapServer.GetCurrentMapWavesConfig()

	ReplicatedStorage.CurrentWave.Value = 0
	ReplicatedStorage.TotalWaves.Value = #MapWavesArray

	-- grace period
	for second = 0, GRACE_PERIOD - 1 do
		local RemainingGrace : number = (GRACE_PERIOD - second)
		ReplicatedStorage.TimerValue.Value = 'Grace Period: ' .. NumbersModule.FormatForTimer( RemainingGrace, false )
		task.wait(1)
	end

	-- wave iteration
	for waveIndex, waveData in ipairs( MapWavesArray ) do
		ReplicatedStorage.CurrentWave.Value = waveIndex
		for enemyId : string, spawnDict : {} in pairs(waveData.Enemies) do
			for spawnId : string, spawnData : {} in pairs(spawnDict) do
				task.delay(spawnData.Delay or 0, function()
					SystemsContainer.EnemiesServer.QueueSpawnEnemies( enemyId, spawnId, spawnData.Count, spawnData.Interval )
				end)
			end
		end
		for second = 0, (waveData.Duration - 1) do
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
		-- reward players for finishing the round
		for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
			LocalPlayer.leaderstats.Cash.Value += (waveData.Reward or 25)
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
