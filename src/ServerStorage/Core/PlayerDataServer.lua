
-- player data for the tower defense
-- append win/lose to their results and teleport them
-- back to lobby after game with their results to be displayed

local Players = game:GetService("Players")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.OnPlayerAdded( LocalPlayer : Player )

	local leaderstats = Instance.new('Folder')
	leaderstats.Name = 'leaderstats'
	leaderstats.Parent = LocalPlayer

	local TotalKillsValue = Instance.new('IntValue')
	TotalKillsValue.Name = 'Total Kills'
	TotalKillsValue.Value = 0
	TotalKillsValue.Parent = leaderstats

	local CashValue = Instance.new('IntValue')
	CashValue.Name = 'Cash'
	CashValue.Value = 50
	CashValue.Parent = leaderstats

end

function Module.OnPlayeRemoving( LocalPlayer : Player )

end

function Module.Start()

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.spawn(Module.OnPlayerAdded, LocalPlayer)
	end
	Players.PlayerAdded:Connect(Module.OnPlayerAdded)

	Players.PlayerRemoving:Connect(Module.OnPlayeRemoving)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
