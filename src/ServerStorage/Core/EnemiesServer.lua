
-- handling all enemies in the tower defense

export type Enemy = {
	UUID : string,
	ID : string,
	Health : number, -- set to health of enemy via config
	Model : Instance,
	PathPoints : { BasePart },
	TargetPathIndex : number, -- set to 2 when created
	IsUpdating : boolean,
	Destroyed : boolean,
	_Maid : { Give : ({}, ...any) -> nil, Cleanup : ({}) -> nil, }
}

export type SpawnQueueItem = {
	Count : number,
	Interval : number,
	SpawnId : string,
	NextSpawnTick : number,
}

local PhysicsService = game:GetService('PhysicsService')
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService('Players')
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local MaidClassModule = ReplicatedModules.Modules.Maid
local EnemiesConfigModule = ReplicatedModules.Data.Enemies
local MoveToModule = ReplicatedModules.Utility.MoveTo

local DefaultSpawnInterval : number = 2

local SystemsContainer = {}

local function SetCharacterCollisionGroup( character : Instance, group : string )
	local Descendants : {Instance} = character:GetDescendants()
	table.insert(Descendants, character)
	for _, basePart : BasePart in ipairs( Descendants ) do
		if basePart:IsA('BasePart') then
			basePart.CollisionGroup = group
		end
	end
end

-- // Module // --
local Module = {}

Module.SpawnQueue = {} :: { [string] : SpawnQueueItem}
Module.ActiveEnemyUnits = {} :: {Enemy}

function Module.GetWorkspaceCamera() : Camera
	local Camera = workspace:FindFirstChildWhichIsA('Camera')
	if not Camera then
		Camera = Instance.new('Camera')
		Camera.Parent = workspace
	end
	return Camera
end

function Module.QueueSpawnEnemies( enemyId : string, spawnId : string, count : number, interval : number? )
	local enemyConfig = EnemiesConfigModule.GetConfigFromId(enemyId)
	assert( enemyConfig, 'Could not find enemy of id: '..tostring(enemyId) )

	local waypoints : {BasePart} = SystemsContainer.MapServer.GetWaypointsFromId( spawnId )
	assert( waypoints, 'There is no active map or the spawn id is invalid: ' .. tostring(spawnId) )

	-- check spawn queue for the enemyId
	if not Module.SpawnQueue[enemyId] then
		Module.SpawnQueue[enemyId] = { }
	end

	-- check if same enemies are spawning at the spawn location
	local spawnInterval : number = typeof(interval) ~= 'nil' and interval or DefaultSpawnInterval
	local SpawnData = Module.SpawnQueue[enemyId][spawnId]
	if SpawnData then
		SpawnData.Count += count
		SpawnData.Interval = spawnInterval
		SpawnData.SpawnId = spawnId
	else -- otherwise create new spawn data for that spawn location
		Module.SpawnQueue[enemyId][spawnId] = {
			Count = count,
			Interval = spawnInterval,
			SpawnId = spawnId,
			NextSpawnTick = 0,
		}
	end
end

function Module.GetEnemyModelFromObjectName( objectName : string ) : Instance?
	return ReplicatedAssets.Enemies:FindFirstChild(objectName)
end

function Module.CreateEnemyAt( enemyId, spawnId )

	local difficultyConfig = SystemsContainer.GameControllerServer.GetActiveDifficultyConfig()
	assert( difficultyConfig, 'Game difficulty has not been set yet.' )

	local enemyConfig = EnemiesConfigModule.GetConfigFromId(enemyId)
	assert( enemyConfig, 'Could not find enemy of id: '..tostring(enemyId) )

	local waypoints : {BasePart} = SystemsContainer.MapServer.GetWaypointsFromId( spawnId )
	assert( waypoints, 'No waypoints were found for spawn of id: ' .. tostring(spawnId) )

	local P0 : Vector3 = waypoints[1].Position
	local P1 : Vector3 = waypoints[2].Position
	local SpawnCFrame : CFrame = CFrame.lookAt( P0, Vector3.new(P1.X, P0.Y, P1.Z) ) -- look towards the second node.

	local UniqueId = HttpService:GenerateGUID(false)

	local EnemyHealth : number = math.round(enemyConfig.MaxHealth * difficultyConfig.Multipliers.EnemyHealth)
	local EnemyWalkSpeed : number = enemyConfig.WalkSpeed

	local EnemyNPC : Model = ReplicatedAssets.ServerEnemy:Clone()
	EnemyNPC.Name = tostring(enemyId)..'_'..tostring(UniqueId)
	EnemyNPC.Humanoid.MaxHealth = EnemyHealth
	EnemyNPC.Humanoid.Health = EnemyHealth
	EnemyNPC.Humanoid.WalkSpeed = EnemyWalkSpeed
	EnemyNPC:SetAttribute('UUID', UniqueId)
	EnemyNPC:SetAttribute('ID', enemyId)
	EnemyNPC:SetAttribute('SpawnId', spawnId)
	EnemyNPC:ScaleTo( enemyConfig.ModelScale )
	EnemyNPC:PivotTo( SpawnCFrame )
	EnemyNPC.Parent = workspace--Module.GetWorkspaceCamera()

	SetCharacterCollisionGroup(EnemyNPC, 'Enemies')
	CollectionService:AddTag(EnemyNPC, 'EnemyNPC')

	local EnemyMaid = MaidClassModule.New()

	EnemyMaid:Give(function()
		CollectionService:RemoveTag(EnemyNPC, 'EnemyNPC')
	end)

	local Data : Enemy = {
		UUID = UniqueId,
		ID = enemyId,
		SpawnId = spawnId,
		Health = enemyConfig.Health, -- set to health of enemy via config
		Model = EnemyNPC,
		PathPoints = waypoints,
		TargetPathIndex = 2, -- set to 2 when created
		Destroyed = false,
		IsUpdating = false,
		_Maid = EnemyMaid,
	}

	EnemyMaid:Give(EnemyNPC.Humanoid.Died:Connect(function()
		Data.Destroyed = true
	end))

	EnemyMaid:Give(EnemyNPC.Destroying:Connect(function()
		Data.Destroyed = true
	end))

	table.insert(Module.ActiveEnemyUnits, Data)
end

function Module.UpdateEnemy( enemyData : Enemy )
	local enemyConfig = EnemiesConfigModule.GetConfigFromId( enemyData.ID )
	if enemyData.TargetPathIndex > #enemyData.PathPoints then
		enemyData.Destroyed = true
		SystemsContainer.GameControllerServer.DecrementHitpoints( enemyConfig.Damage or 1 )
		-- warn('Enemy has reached the end! Decrement hitpoints.')
	end

	-- move to the next target node
	local TargetPoint : BasePart? = enemyData.PathPoints[ enemyData.TargetPathIndex ]
	if not TargetPoint then
		return -- no target point
	end

	local LastTargetPosition : Vector3 = enemyData.PathPoints[ enemyData.TargetPathIndex-1 ].Position
	local Direction = (TargetPoint.Position - LastTargetPosition).Unit

	local TargetPosition : Vector3 = TargetPoint.Position + (Direction * 0.7)

	local success : boolean = MoveToModule.MoveToLoop( enemyData.Model.Humanoid, enemyData.Model.HumanoidRootPart, TargetPosition, nil )
	-- did not finish the path in-time; let the loop update again.
	if not success then
		return
	end

	-- increment target index by 1
	enemyData.TargetPathIndex += 1
end

function Module.UpdateEnemies( _ : number )
	local index = 1
	while index <= #Module.ActiveEnemyUnits do
		local data = Module.ActiveEnemyUnits[index]
		-- check if unit is destroyed
		if data.Destroyed then
			data._Maid:Cleanup()
			data.Model:Destroy()
			table.remove(Module.ActiveEnemyUnits, index)
			continue
		end
		-- check if unit is updating already
		index += 1
		if data.IsUpdating then
			continue
		end
		-- update the unit
		data.IsUpdating = true
		task.spawn(function()
			Module.UpdateEnemy( data )
			data.IsUpdating = false
		end)
	end
end

function Module.SpawnQueueUpdate()
	-- update the spawn queue
	-- for each enemy id, for each spawn location, spawn if can and cleanup the table as it goes
	for enemyId, spawnsDict in pairs( Module.SpawnQueue ) do
		local totalSpawns : number = 0
		for spawnId, spawnData in pairs( spawnsDict ) do
			-- check if there is any enemies to spawn
			if spawnData.Count == 0 then
				spawnsDict[spawnId] = nil
				continue
			end
			-- there are enemies that still need to spawn, increment counter
			totalSpawns += 1
			-- check if the next enemy can spawn
			if tick() < spawnData.NextSpawnTick then
				continue
			end
			-- spawn the enemy
			spawnData.Count -= 1
			Module.CreateEnemyAt( enemyId, spawnId )
			spawnData.NextSpawnTick = tick() + spawnData.Interval
		end
		-- cleanup empty enemyId queues
		if totalSpawns == 0 then
			Module.SpawnQueue[enemyId] = nil
		end
	end
end

function Module.KillAllEnemies()
	for _, enemyUnit in ipairs( Module.ActiveEnemyUnits ) do
		enemyUnit.Destroyed = true
	end
end

function Module.ClearSpawnQueue()
	Module.SpawnQueue = {}
end

function Module.Start()

	workspace.ChildAdded:Connect(function(child)
		local TargetPlayer = Players:GetPlayerFromCharacter( child )
		if TargetPlayer then
			SetCharacterCollisionGroup( child, 'PlayerCharacters' )
		end
	end)

	RunService.Heartbeat:Connect(Module.UpdateEnemies)

	task.spawn(function()
		while true do
			task.wait(0.1)
			Module.SpawnQueueUpdate()
		end
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	PhysicsService:RegisterCollisionGroup('PlayerCharacters')
	PhysicsService:RegisterCollisionGroup('Enemies')
	PhysicsService:CollisionGroupSetCollidable('PlayerCharacters', 'Enemies', false)
	PhysicsService:CollisionGroupSetCollidable('PlayerCharacters', 'PlayerCharacters', false)
	PhysicsService:CollisionGroupSetCollidable('Enemies', 'Enemies', false)
end

return Module
