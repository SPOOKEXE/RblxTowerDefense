
-- handling the placement of towers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))
local TowersConfigModule = ReplicatedModules.Data.Towers

local RNetModule = ReplicatedModules.Libraries.RNet
local TowerPlacementBridge = RNetModule.Create('TowerPlacement')

local SystemsContainer = {}

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include

-- // Module // --
local Module = {}

function Module.AttemptTowerPlacement( LocalPlayer : Player, towerId : string, placementPosition : Vector3 )
	print( LocalPlayer.Name, towerId, placementPosition )

	local towerConfig = TowersConfigModule.GetConfigFromId( towerId )
	assert( towerConfig, string.format('No config for tower of id %s was found.', towerId) )

	local towerModel = ReplicatedAssets.Towers:FindFirstChild( towerConfig.Model )
	assert( towerModel, string.format('Cannot find the model for tower of id %s', towerId) )

	if LocalPlayer.leaderstats.Cash.Value < towerConfig.Cost then
		return
	end
	LocalPlayer.leaderstats.Cash.Value -= towerConfig.Cost

	local mapModel : Model = workspace.Map:GetChildren()[1]

	raycastParams.FilterDescendantsInstances = { mapModel.Base }
	overlapParams.FilterDescendantsInstances = { workspace.Map, workspace.Towers }

	local verticalRaycast = workspace:Raycast(placementPosition + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), raycastParams)
	if not verticalRaycast then
		print('no ground')
		return
	end

	placementPosition = verticalRaycast.Position

	towerModel = towerModel:Clone()
	towerModel:ScaleTo( towerConfig.ModelScale )

	local _, Size = towerModel:GetBoundingBox()
	local ModelCFrame : CFrame = CFrame.new(placementPosition) * CFrame.new(0, Size.Y/2, 0)
	local collisionParts : {BasePart} = workspace:GetPartBoundsInBox( ModelCFrame, Size, overlapParams )
	local isColliding : boolean = (#collisionParts > 1) or ( #collisionParts == 1 and not table.find( collisionParts, mapModel.Base ) )
	if isColliding then
		towerModel:Destroy()
		print('collisions')
		return
	end

	towerModel:PivotTo( ModelCFrame )
	towerModel.Parent = workspace.Towers

	SystemsContainer.TowerServer.SetupTowerModel( towerModel, towerId, LocalPlayer )
end

function Module.AttemptTowerUpgrade( LocalPlayer : Player, towerUUID : string )

end

function Module.AttemptTowerSell( LocalPlayer : Player, towerUUID : string )

end

function Module.Start()

	TowerPlacementBridge:OnServerEvent(function( LocalPlayer : Player, towerId : string, x : number, y : number, z : number )
		if typeof(towerId) == 'string' and typeof(x) == 'number' and typeof(y) == 'number' and typeof(z) == 'number' then
			Module.AttemptTowerPlacement( LocalPlayer, towerId, Vector3.new(x, y, z) )
		end
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
