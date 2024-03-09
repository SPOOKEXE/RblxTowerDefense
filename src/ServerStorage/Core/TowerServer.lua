
-- handling all the tower ai

local RunService = game:GetService("RunService")
local CollectionService = game:GetService('CollectionService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local TowersConfigModule = ReplicatedModules.Data.Towers

export type Tower = {
	ID : string,
	Model : Instance,
	Level : number,
	Owner : Player?,

	NextAttackTick : number,
	AttackIndex : number,
}

local SystemsContainer = {}

local ActiveTowerInstances : {Tower} = {}

local function IsPointInCircle( center : Vector2, radius : number, point : Vector2 ) : boolean
	local dx : number = (point.X - center.X)
	local dy : number = (point.Y - center.Y)
	return (dx * dx) + (dy * dy) < (radius * radius)
end

local function FindClosestEnemyToPosition( position : Vector3, range : number ) : ( Instance?, number? )
	local closest = nil
	local closestDistance = nil
	for _, model in ipairs( CollectionService:GetTagged('EnemyNPC') ) do
		local humanoid = model:FindFirstChildWhichIsA('Humanoid')
		if (not humanoid) or humanoid.Health <= 0 then
			continue
		end
		local myPosition : Vector3 = model:GetPivot().Position
		local dist = (myPosition - position).Magnitude
		if (closestDistance and dist > closestDistance) or (closestDistance > range) then
			continue
		end
		closest = model
		closestDistance = dist
	end
	return closest, closestDistance
end

-- // Module // --
local Module = {}

function Module.SetupTowerModel( towerModel : Instance, towerId : string, owner : Player? )

	towerModel:SetAttribute('Owner', owner.Name or nil)
	towerModel:SetAttribute('ID', towerId)
	towerModel:SetAttribute('Level', 1)

	local towerConfig = TowersConfigModule.GetConfigFromId( towerId )
	assert( towerConfig, 'Could not find config for tower of id: ' .. tostring( towerId ) )

	local Data = {
		ID = towerId,
		Model = towerModel,
		Owner = owner,
		Level = 1,

		NextAttackTick = 0,
		AttackIndex = 1,
	}

	table.insert(ActiveTowerInstances, Data)

end

function Module.UpdateTower( towerData : Tower )

	local towerConfig = TowersConfigModule.GetConfigFromId( towerData.ID )
	local upgradeData = towerConfig.Upgrades[ towerData.Level ]

	local ClosestEnemy, _ = FindClosestEnemyToPosition( towerData.Model:GetPivot().Position, upgradeData.Range )
	if not ClosestEnemy then
		return
	end

	local deltaPosition : Vector3 = (ClosestEnemy:GetPivot().Position - towerData.Model:GetPivot().Position)
	if not IsPointInCircle( Vector2.new(), upgradeData.Range, Vector2.new( deltaPosition.X, deltaPosition.Z)  ) then
		return
	end

	-- attack
	if towerData.NextAttackTick < tick() then
		return
	end
	towerData.NextAttackTick = tick() + upgradeData.AttackInterval

	print( towerData.Model, towerData.ID, towerData.AttackIndex )
	-- TowerVFXBridge:FireAllClients( towerData.Model, towerData.ID, towerData.AttackIndex )

	towerData.AttackIndex += 1
	if towerData.AttackIndex > #towerConfig.VFXAttackIDs then
		towerData.AttackIndex = 1
	end

	task.delay(0.4, function()
		ClosestEnemy.Humanoid.Health -= towerConfig.Damage
	end)

end

function Module.Start()

	RunService.Heartbeat:Connect(function(_)
		local index = 1
		while index <= #ActiveTowerInstances do
			local towerData : Tower = ActiveTowerInstances[index]
			if not towerData.Model or not towerData.Model:IsDescendantOf(workspace) then
				table.remove(ActiveTowerInstances, index)
				continue
			end
			index += 1
			if towerData.IsUpdating then
				continue
			end
			towerData.IsUpdating = true
			task.spawn(function()
				Module.UpdateTower(towerData)
				towerData.IsUpdating = false
			end)
		end
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
