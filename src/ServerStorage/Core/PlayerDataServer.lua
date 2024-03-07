
-- player data for the tower defense
-- append win/lose to their results and teleport them
-- back to lobby after game with their results to be displayed

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
