
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
		DefaultRig1 = {
			Path0 = { Count = 10, Interval = 1, }
		}
	},

	-> = (Count * Interval) seconds + (custom grace period) seconds
]]
Module.Waves = {

	Map0 = {
		{ -- wave 1
			Duration = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 20, Interval = 1, }
				},
			},
		},
		{ -- wave 2
			Duration = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 20, Interval = 1, }
				},
			},
		},
		{ -- wave 3
			Duration = 60,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 50, Interval = 1, }
				},
			},
		},
		{ -- wave 4
			Duration = 20,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 1, }
				},
			},
		},
		{ -- wave 4
			Duration = 20,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 1, }
				},
			},
		},
		{ -- wave 5
			Duration = 40,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 30, Interval = 1, }
				},
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 2, }
				},
			},
		},
		{ -- wave 6
			Duration = 50,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 60, Interval = 0.8, }
				},
				DefaultRig2 = {
					Path0 = { Count = 30, Interval = 1, }
				},
			},
		},
		{ -- wave 7
			Duration = 55,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 45, Interval = 1, }
				},
				DefaultRig3 = {
					Path0 = { Count = 20, Interval = 1, }
				},
			},
		},
		{ -- wave 8
			Duration = 50,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 45, Interval = 0.8, }
				},
				DefaultRig2 = {
					Path0 = { Count = 45, Interval = 0.9, }
				},
				DefaultRig3 = {
					Path0 = { Count = 45, Interval = 1, }
				},
			},
		},
		{ -- wave 9
			Duration = 40,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.5, }
				},
			},
		},
		{ -- wave 11
			Duration = 25,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 60, Interval = 0.25, }
				},
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, }
				},
			},
		},
		{ -- wave 12
			Duration = 25,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, }
				},
				DefaultBoss = {
					Path0 = { Count = 1, Interval = 1, }
				},
			},
		},
		{ -- wave 13
			Duration = 40,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.5, }
				},
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.5, }
				},
			},
		},
		{ -- wave 14
			Duration = 25,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, }
				},
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.25, }
				},
			},
		},
		{ -- wave 15
			Duration = 40,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 120, Interval = 0.25, }
				},
				DefaultBoss = {
					Path0 = { Count = 20, Interval = 1, }
				},
			},
		},
		{ -- wave 16
			Duration = 80,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 240, Interval = 0.25, }
				},
				DefaultBoss = {
					Path0 = { Count = 60, Interval = 1, }
				},
			},
		},
	},

} :: { [string] : MapWaveConfig }

function Module.GetWaveDataFromId( id : string ) : MapWaveConfig?
	return Module.Waves[id]
end

return Module
