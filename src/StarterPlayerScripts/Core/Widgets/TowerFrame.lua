
local UserInputService = game:GetService("UserInputService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))
local UserInterfaceModule = LocalModules.Utility.UserInterface

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local TowerSelectFrame = Interface:WaitForChild('TowerFrame')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local TowersConfigModule = ReplicatedModules.Data.Towers

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.IsOpen = nil
Module.WidgetMaid = ReplicatedModules.Modules.Maid.New()

function Module.GetTowerFrame( towerId :string ) : Frame?

	local towerConfig : {} = TowersConfigModule.GetConfigFromId( towerId )
	if not towerConfig then
		return
	end

	local Frame = TowerSelectFrame.Scroll:FindFirstChild( towerId )
	if not Frame then
		Frame = LocalAssets.UI.TemplateTower:Clone()
		Frame.Name = towerId
		Frame.TitleLabel.Text = towerConfig.Name
		Frame.PriceLabel.Text = '$'..tostring(towerConfig.Cost)
		-- viewport / icon

		UserInterfaceModule.CreateActionButton({Parent = Frame}).Activated:Connect(function()
			SystemsContainer.ParentSystems.TowerPlacement.SetTargetPlacement( towerId )
			SystemsContainer.ParentSystems.TowerPlacement.StartPlacement()
		end)

		Frame.Parent = TowerSelectFrame.Scroll
	end
	return Frame
end

function Module.UpdateLoadout()
	if not Module.IsOpen then
		return
	end

	-- load all of the player's towers
	local PlayerLoadout = { 'Wizard' }

	for index, towerId in ipairs( PlayerLoadout ) do
		local Frame = Module.GetTowerFrame( towerId )
		if not Frame then
			continue
		end
		Frame.LayoutOrder = index
		Module.WidgetMaid:Give(Frame)
	end
end

function Module.OpenWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

	Module.UpdateLoadout()
	TowerSelectFrame.Visible = true

end

function Module.CloseWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false

	-- stuff
	TowerSelectFrame.Visible = false
	Module.WidgetMaid:Cleanup()
end

function Module.Start()

	TowerSelectFrame.Visible = false
	Module.OpenWidget()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
