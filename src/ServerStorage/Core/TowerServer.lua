
-- handling all the tower ai

local CollectionService = game:GetService('CollectionService')

export type Tower = {
	ID : string,
	Team : string,

	Model : Instance,
	NextAttackTick : number,
}

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.RegisterTowerInstance( towerInstance : Instance )

end

function Module.UnRegisterTowerInstance( towerInstance : Instance )

end

function Module.UpdateTower( towerData : Tower )

end

function Module.Start()

	for _, object in ipairs( CollectionService:GetTagged('Tower') ) do
		task.spawn(Module.RegisterTowerInstance, object)
	end
	CollectionService:GetInstanceAddedSignal('Tower'):Connect(Module.RegisterTowerInstance)
	CollectionService:GetInstanceRemovedSignal('Tower'):Connect(Module.UnRegisterTowerInstance)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
