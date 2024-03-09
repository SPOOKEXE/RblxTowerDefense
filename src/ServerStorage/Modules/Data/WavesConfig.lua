
export type EnemySpawnData = {
	[string] : {
		[string] : {
			Count : number,
			Interval : number?
		},
	}
}

export type MapWaveConfig = {
	{
		Duration : number,
		Enemies : EnemySpawnData
	}
}

-- // Module // --
local Module = {}

--[[
	Wave Duration = max( for_all_enemies(Count * Interval) )

	Enemies = {
		DefaultRig = {
			Path0 = { Count = 10, Interval = 1, }
		}
	},

	-> = (Count * Interval) seconds + (custom grace period) seconds
]]
Module.Waves = {

	Map0 = {
		{ -- wave 1
			Duration = 15,
			Enemies = {
				DefaultRig = {
					Path0 = { Count = 10, Interval = 1, }
				}
			},
		},
		{ -- wave 2
			Duration = 25,
			Enemies = {
				DefaultRig = {
					Path0 = { Count = 20, Interval = 1, }
				}
			},
		},
		{ -- wave 3
			Duration = 35,
			Enemies = {
				DefaultRig = {
					Path0 = { Count = 30, Interval = 1, }
				}
			},
		},
		{ -- wave 4
			Duration = 30,
			Enemies = {
				DefaultRig = {
					Path0 = { Count = 30, Interval = 0.8, }
				}
			},
		},
		{ -- wave 5
			Duration = 30,
			Enemies = {
				DefaultRig = {
					Path0 = { Count = 30, Interval = 0.8, }
				}
			},
		},
	},

} :: { [string] : MapWaveConfig }

function Module.GetWaveDataFromId( id : string ) : MapWaveConfig?
	return Module.Waves[id]
end

return Module
