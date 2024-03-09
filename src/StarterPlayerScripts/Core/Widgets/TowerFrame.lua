
local UserInputService = game:GetService("UserInputService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local TowerSelectFrame = Interface:WaitForChild('TowerFrame')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.IsOpen = nil
Module.WidgetMaid = ReplicatedModules.Modules.Maid.New()

function Module.OpenWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

end

function Module.CloseWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false

	-- stuff

	Module.WidgetMaid:Cleanup()
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
