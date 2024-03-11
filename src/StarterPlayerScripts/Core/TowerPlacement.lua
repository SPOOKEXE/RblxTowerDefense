
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))
local TowersConfigModule = ReplicatedModules.Data.Towers

local RNetModule = ReplicatedModules.Libraries.RNet
local TowerPlacementBridge = RNetModule.Create('TowerPlacement')

local SystemsContainer = {}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local CurrentCamera = workspace.CurrentCamera

local InnerRangeAdornment : CylinderHandleAdornment
local OuterRangeAdornment : CylinderHandleAdornment

-- // Module // --
local Module = {}

Module.CurrentPlacementId = nil
Module.CurrentPlacementModel = nil
Module.CurrentPlacementCFrame = nil

function Module.StopPlacement()
	-- destroy old model
	if Module.CurrentPlacementModel then
		Module.CurrentPlacementModel:Destroy()
	end
	Module.CurrentPlacementModel = nil

	Module.CurrentPlacementId = nil
end

function Module.SetTargetPlacement( towerId : string )
	if Module.CurrentPlacementId == towerId then
		return -- already selected
	end

	local IsPlacing = (Module.CurrentPlacementModel ~= nil)
	Module.StopPlacement()

	-- set new model (if nil, no placement)
	Module.CurrentPlacementId = towerId or nil
	if IsPlacing then
		Module.StartPlacement()
	end
end

function Module.StartPlacement()
	if Module.CurrentPlacementModel or not Module.CurrentPlacementId then
		return
	end

	local towerConfig : {} = TowersConfigModule.GetConfigFromId( Module.CurrentPlacementId )
	if not towerConfig then
		warn(string.format('No tower config for id %s was found.', tostring(Module.CurrentPlacementId)))
		return
	end

	local towerModel : Model? = ReplicatedAssets.Towers:FindFirstChild( towerConfig.Model )
	if not towerModel then
		warn(string.format('No tower model for id %s was found.', tostring(Module.CurrentPlacementId)))
		return
	end

	local TowerRange : number = towerConfig.Upgrades[1].Range
	InnerRangeAdornment.Radius = (TowerRange - 0.01)
	OuterRangeAdornment.InnerRadius = (TowerRange - 0.01)
	OuterRangeAdornment.Radius = TowerRange

	local placementModel : Model = towerModel:Clone()
	placementModel:ScaleTo( towerConfig.ModelScale )

	for _, basePart : BasePart in ipairs( placementModel:GetDescendants() ) do
		if basePart:IsA('BasePart') then
			basePart.CanCollide = false
			basePart.CanTouch = false
			basePart.CanQuery = false
			basePart.Anchored = true
			basePart.CollisionGroup = 'PlayerCharacters'
		end
	end

	placementModel.Parent = workspace

	Module.CurrentPlacementModel = placementModel
end

function Module.UpdateCurrentlyPlacing( _ : number )
	InnerRangeAdornment.Visible = (Module.CurrentPlacementModel ~= nil)
	OuterRangeAdornment.Visible = (Module.CurrentPlacementModel ~= nil)
	if not Module.CurrentPlacementModel then
		return
	end

	raycastParams.FilterDescendantsInstances = { workspace.Map }

	local mouseRay : Ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	local rayResult : RaycastParams = workspace:Raycast( mouseRay.Origin, mouseRay.Direction * 100, raycastParams )
	if rayResult then
		local MouseCFrame : CFrame = CFrame.new(rayResult.Position)
		local _, Size = Module.CurrentPlacementModel:GetBoundingBox()
		InnerRangeAdornment.CFrame = MouseCFrame * CFrame.Angles( math.rad(90), 0, 0 )
		OuterRangeAdornment.CFrame = InnerRangeAdornment.CFrame

		local ModelCFrame : CFrame = MouseCFrame * CFrame.new(0, Size.Y/2, 0)
		Module.CurrentPlacementModel:PivotTo( ModelCFrame )

		overlapParams.FilterDescendantsInstances = { workspace.Map, workspace.Towers }

		local mapModel : Model = workspace.Map:GetChildren()[1]
		local collisionParts : {BasePart} = workspace:GetPartBoundsInBox( ModelCFrame, Size, overlapParams )

		local isColliding : boolean = (#collisionParts > 1) or ( #collisionParts == 1 and not table.find( collisionParts, mapModel.Base ) )
		Module.CurrentPlacementColliding = isColliding
		if isColliding then
			InnerRangeAdornment.Color3 = Color3.fromRGB(151, 6, 6)
			OuterRangeAdornment.Color3 = Color3.fromRGB(55, 3, 3)
		else
			InnerRangeAdornment.Color3 = Color3.fromRGB(13, 105, 172)
			OuterRangeAdornment.Color3 = Color3.fromRGB(7, 58, 94)
			Module.CurrentPlacementCFrame = ModelCFrame
		end
	end
end

function Module.Start()

	RunService.Heartbeat:Connect(Module.UpdateCurrentlyPlacing)

	UserInputService.InputBegan:Connect(function(inputObject, _)
		if inputObject.KeyCode == Enum.KeyCode.Q then
			Module.StopPlacement()
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			if Module.CurrentPlacementId and Module.CurrentPlacementCFrame and not Module.CurrentPlacementColliding then
				local Position : Vector3 = Module.CurrentPlacementCFrame.Position
				-- print( Module.CurrentPlacementId, Position )
				TowerPlacementBridge:FireServer( Module.CurrentPlacementId, Position.X, Position.Y, Position.Z )
			end
		end
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	local Terrain = workspace:WaitForChild('Terrain')

	InnerRangeAdornment = Instance.new('CylinderHandleAdornment')
	InnerRangeAdornment.Name = 'InnerRadius'
	InnerRangeAdornment.AlwaysOnTop = true
	InnerRangeAdornment.Height = 0.01
	InnerRangeAdornment.Color3 = Color3.fromRGB(13, 105, 172)
	InnerRangeAdornment.Transparency = 0.7
	InnerRangeAdornment.InnerRadius = 0
	InnerRangeAdornment.Radius = 4.99
	InnerRangeAdornment.ZIndex = 0
	InnerRangeAdornment.Visible = false
	InnerRangeAdornment.Adornee = Terrain
	InnerRangeAdornment.Parent = Terrain

	OuterRangeAdornment = Instance.new('CylinderHandleAdornment')
	OuterRangeAdornment.Name = 'OuterRadius'
	OuterRangeAdornment.AlwaysOnTop = true
	OuterRangeAdornment.Height = 0.1
	OuterRangeAdornment.Color3 = Color3.fromRGB(7, 58, 94)
	OuterRangeAdornment.Transparency = 0.7
	OuterRangeAdornment.InnerRadius = 4.99
	OuterRangeAdornment.Radius = 5
	OuterRangeAdornment.ZIndex = 0
	InnerRangeAdornment.Visible = false
	OuterRangeAdornment.Adornee = Terrain
	OuterRangeAdornment.Parent = Terrain
end

return Module
