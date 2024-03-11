
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
			Reward = 10,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 20, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 2
			Duration = 25,
			Reward = 10,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 20, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 3
			Duration = 60,
			Reward = 15,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 50, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 4
			Duration = 20,
			Reward = 15,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 4
			Duration = 20,
			Reward = 15,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 5
			Duration = 40,
			Reward = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 30, Interval = 1, Offset = 0, }
				},
				DefaultRig2 = {
					Path0 = { Count = 10, Interval = 2, Offset = 0, }
				},
			},
		},
		{ -- wave 6
			Duration = 50,
			Reward = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 60, Interval = 0.8, Offset = 0, }
				},
				DefaultRig2 = {
					Path0 = { Count = 30, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 7
			Duration = 55,
			Reward = 25,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 45, Interval = 1, Offset = 0, }
				},
				DefaultRig3 = {
					Path0 = { Count = 20, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 8
			Duration = 50,
			Reward = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 45, Interval = 0.8, Offset = 0, }
				},
				DefaultRig2 = {
					Path0 = { Count = 45, Interval = 0.9, Offset = 0, }
				},
				DefaultRig3 = {
					Path0 = { Count = 45, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 9
			Duration = 40,
			Reward = 25,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.5, Offset = 0, }
				},
			},
		},
		{ -- wave 11
			Duration = 25,
			Reward = 50,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 60, Interval = 0.25, Offset = 0, }
				},
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, Offset = 0, }
				},
			},
		},
		{ -- wave 12
			Duration = 25,
			Reward = 50,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, Offset = 0, }
				},
				DefaultBoss = {
					Path0 = { Count = 1, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 13
			Duration = 40,
			Reward = 50,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.5, Offset = 0, }
				},
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.5, Offset = 0, }
				},
			},
		},
		{ -- wave 14
			Duration = 25,
			Reward = 50,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 60, Interval = 0.25, Offset = 0, }
				},
				DefaultRig4 = {
					Path0 = { Count = 60, Interval = 0.25, Offset = 0, }
				},
			},
		},
		{ -- wave 15
			Duration = 40,
			Reward = 50,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 120, Interval = 0.25, Offset = 0, }
				},
				DefaultBoss = {
					Path0 = { Count = 20, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 16
			Duration = 80,
			Reward = 100,
			Enemies = {
				DefaultRig4 = {
					Path0 = { Count = 240, Interval = 0.25, Offset = 0, }
				},
				DefaultBoss = {
					Path0 = { Count = 60, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 17
			Duration = 80,
			Reward = 100,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 240, Interval = 0.15, Offset = 0, }
				},
				DefaultRig4 = {
					Path0 = { Count = 240, Interval = 0.15, Offset = 0, }
				},
				DefaultBoss = {
					Path0 = { Count = 120, Interval = 0.25, Offset = 0, }
				},
			},
		},
		{ -- wave 18
			Duration = 80,
			Reward = 100,
			Enemies = {
				DefaultRig3 = {
					Path0 = { Count = 360, Interval = 0.125, Offset = 0, }
				},
				DefaultRig4 = {
					Path0 = { Count = 360, Interval = 0.125, Offset = 0, }
				},
				DefaultBoss = {
					Path0 = { Count = 180, Interval = 0.175, Offset = 0, }
				},
			},
		},
		{ -- wave 19
			Duration = 30,
			Reward = 200,
			Enemies = {
				DefaultUltraBoss1 = {
					Path0 = { Count = 5, Interval = 5, Offset = 0, }
				},
			},
		},
		{ -- wave 20
			Duration = 60,
			Reward = 200,
			Enemies = {
				DefaultUltraBoss1 = {
					Path0 = { Count = 60, Interval = 1, Offset = 0, }
				},
			},
		},
	},

	Map1 = {
		{ -- wave 1
			Duration = 25,
			Reward = 10,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 20, Interval = 1, Offset = 0, }
				},
			},
		},
		{ -- wave 2
			Duration = 20,
			Reward = 20,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 15, Interval = 1, Offset = 0, },
					Path1 = { Count = 15, Interval = 1, Offset = 0, },
				},
			},
		},
		{ -- wave 3
			Duration = 25,
			Reward = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 24, Interval = 0.9, Offset = 0, },
					Path1 = { Count = 24, Interval = 0.9, Offset = 0, },
				},
			},
		},
		{ -- wave 4
			Duration = 50,
			Reward = 25,
			Enemies = {
				DefaultRig1 = {
					Path0 = { Count = 48, Interval = 0.9, Offset = 0, },
					Path1 = { Count = 48, Interval = 0.9, Offset = 0, },
				},
			},
		},
		{ -- wave 5
			Duration = 50,
			Reward = 25,
			Enemies = {
				DefaultRig2 = {
					Path0 = { Count = 5, Interval = 1, Offset = 0, },
					Path1 = { Count = 5, Interval = 1, Offset = 0, },
				},
			},
		},
	},

} :: { [string] : MapWaveConfig }

function Module.GetWaveDataFromId( id : string ) : MapWaveConfig?
	return Module.Waves[id]
end

return Module
