
-- handling all the tower ai

local RunService = game:GetService("RunService")
local CollectionService = game:GetService('CollectionService')

local ServerStorage = game:GetService("ServerStorage")
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local DamageModule = ServerModules.Modules.DamageModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RNetModule = ReplicatedModules.Libraries.RNet
local TowerVFXBridge = RNetModule.Create('TowerVFX')

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
		if (closestDistance and dist > closestDistance) or (dist > range) then
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

	local closestEnemy, _ = FindClosestEnemyToPosition( towerData.Model:GetPivot().Position, upgradeData.Range )
	if not closestEnemy then
		return
	end

	local Humanoid = closestEnemy:FindFirstChildWhichIsA('Humanoid')
	if not Humanoid then
		return
	end

	-- attack
	if tick() < towerData.NextAttackTick then
		return
	end
	towerData.NextAttackTick = tick() + upgradeData.AttackInterval

	-- print( towerData.ID, upgradeData.VFXAttackIDs[towerData.AttackIndex], towerData.Model:GetFullName() )
	TowerVFXBridge:FireAllClients( towerData.Model, upgradeData.VFXAttackIDs[towerData.AttackIndex], closestEnemy, upgradeData.AttackInterval )

	towerData.AttackIndex += 1
	if towerData.AttackIndex > #upgradeData.VFXAttackIDs then
		towerData.AttackIndex = 1
	end

	task.delay(0.4, function()
		if Humanoid.Health > 0 then
			if towerData.Owner then
				DamageModule.TagHumanoid( Humanoid, towerData.Owner )
			end
			Humanoid.Health -= upgradeData.Damage
		end
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
