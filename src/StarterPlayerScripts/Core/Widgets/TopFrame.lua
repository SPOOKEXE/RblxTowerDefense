
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local leaderstats = LocalPlayer:WaitForChild('leaderstats')
local CashValue = leaderstats:WaitForChild('Cash')

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local TopFrame = Interface:WaitForChild('TopFrame')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local CurrentWaveValue = ReplicatedStorage:WaitForChild('CurrentWave')
local TotalWavesValue = ReplicatedStorage:WaitForChild('TotalWaves')
local TimerValue = ReplicatedStorage:WaitForChild('TimerValue')
local HitpointsValue = ReplicatedStorage:WaitForChild('Hitpoints')

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

	TopFrame.WaveNumber.Text = string.format('Wave: %s/%s', tostring(CurrentWaveValue.Value), tostring(TotalWavesValue.Value))
	TopFrame.TimerValue.Text = TimerValue.Value
	TopFrame.Hitpoints.Text = 'Hitpoints: '..tostring(HitpointsValue.Value)
	TopFrame.Currency.Text = 'Cash: ' .. tostring(CashValue.Value)

	Module.WidgetMaid:Give(CashValue.Changed:Connect(function()
		TopFrame.Currency.Text = 'Cash: ' .. tostring(CashValue.Value)
	end))

	Module.WidgetMaid:Give(HitpointsValue.Changed:Connect(function()
		TopFrame.Hitpoints.Text = 'Hitpoints: '..tostring(HitpointsValue.Value)
	end))

	Module.WidgetMaid:Give(CurrentWaveValue.Changed:Connect(function()
		TopFrame.WaveNumber.Text = string.format('Wave: %s/%s', tostring(CurrentWaveValue.Value), tostring(TotalWavesValue.Value))
	end))

	Module.WidgetMaid:Give(TotalWavesValue.Changed:Connect(function()
		TopFrame.WaveNumber.Text = string.format('Wave: %s/%s', tostring(CurrentWaveValue.Value), tostring(TotalWavesValue.Value))
	end))

	Module.WidgetMaid:Give(TimerValue.Changed:Connect(function()
		TopFrame.TimerValue.Text = TimerValue.Value
	end))

	TopFrame.Visible = true
end

function Module.CloseWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false
	TopFrame.Visible = false
	Module.WidgetMaid:Cleanup()
end

function Module.Start()
	TopFrame.Visible = false
	Module.OpenWidget()
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
