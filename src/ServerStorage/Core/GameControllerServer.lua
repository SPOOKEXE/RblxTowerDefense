
-- start the waves and give players money after they've joined

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local DifficultyConfigModule = ServerModules.Data.DifficultyConfig
local GameConfigModule = ServerModules.Data.GameConfig

local SystemsContainer = {}

local HitpointsValue = Instance.new('IntValue')
HitpointsValue.Name = 'Hitpoints'
HitpointsValue.Value = 1
HitpointsValue.Parent = ReplicatedStorage
local CurrentWaveValue = Instance.new('IntValue')
CurrentWaveValue.Name = 'CurrentWave'
CurrentWaveValue.Value = 0
CurrentWaveValue.Parent = ReplicatedStorage
local TotalWavesValue = Instance.new('IntValue')
TotalWavesValue.Name = 'TotalWaves'
TotalWavesValue.Value = 1
TotalWavesValue.Parent = ReplicatedStorage
local TimerValue = Instance.new('StringValue')
TimerValue.Name = 'TimerValue'
TimerValue.Value = 'Loading Game'
TimerValue.Parent = ReplicatedStorage

-- // Module // --
local Module = {}

Module.Ready = false
Module.DifficultyId = false

function Module.AwaitGameDataLoaded()
	while not Module.Ready do
		task.wait(0.1)
	end
end

function Module.SetActiveDifficulty( difficulty : string )
	local difficultyConfig = DifficultyConfigModule.GetConfigFromId(difficulty)
	assert( difficultyConfig, 'Invalid difficulty config option: ' .. tostring(difficulty) )
	Module.DifficultyId = difficulty
	-- HitpointsValue.Value = difficultyConfig.Hitpoints
end

function Module.GetActiveDifficultyConfig() : { }
	assert( Module.DifficultyId, 'No game difficulty has been set yet!' )
	return DifficultyConfigModule.GetConfigFromId( Module.DifficultyId )
end

function Module.IncrementHitpoints( amount : number )
	HitpointsValue.Value += amount
end

function Module.DecrementHitpoints( amount : number )
	if HitpointsValue.Value <= 0 then
		HitpointsValue.Value = 0
	else
		HitpointsValue.Value -= amount
	end
end

function Module.IsGameOver() : boolean
	return HitpointsValue.Value <= 0
end

function Module.SetupGameFromConfig( config : { Difficulty : string, Map : string, } )
	warn( 'Loading Game Config: ' .. HttpService:JSONEncode(config) )
	Module.SetActiveDifficulty( config.Difficulty )
	SystemsContainer.MapServer.LoadMap( config.Map )
	Module.Ready = true
end

function Module.RunGame()
	SystemsContainer.WavesServer.IterateWaves()
	SystemsContainer.EnemiesServer.ClearSpawnQueue()
	-- SystemsContainer.EnemiesServer.KillAllEnemies()
	if HitpointsValue.Value <= 0 then
		-- dead
		warn('You have Died - Game Over!')
	else
		-- alive
		warn('You have Won - Game Over!')
	end
end

function Module.Start()

	task.spawn(function()
		local StudioTest = { Difficulty = 'Normal', Map = 'Map1', }
		Module.SetupGameFromConfig(StudioTest)
		Module.RunGame()
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
