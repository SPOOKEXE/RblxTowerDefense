
-- start the waves and give players money after they've joined

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local DifficultyConfigModule = ServerModules.Data.DifficultyConfig
local GameConfigModule = ServerModules.Data.GameConfig

local SystemsContainer = {}

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
end

function Module.GetActiveDifficultyConfig() : { }
	assert( Module.DifficultyId, 'No game difficulty has been set yet!' )
	return DifficultyConfigModule.GetConfigFromId( Module.DifficultyId )
end

function Module.DecrementHitpoints( amount : number )
	print('Decrement Global Hitpoints: ', amount)
end

function Module.SetupGameFromConfig( config : { Difficulty : string } )
	warn( 'Loading game config: ' .. HttpService:JSONEncode(config) )
	Module.SetActiveDifficulty( config.Difficulty )
	Module.Ready = true
end

function Module.Start()

	Module.SetupGameFromConfig({
		Difficulty = 'Normal',
	})

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
