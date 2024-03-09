
-- // Module // --
local Module = {}

Module.Difficulties = {

	Easy = {
		StartingCurrency = 100,
		Hitpoints = 150,
		Multipliers = {
			EnemyHealth = 0.5,
		},
	},

	Normal = {
		StartingCurrency = 50,
		Hitpoints = 100,
		Multipliers = {
			EnemyHealth = 1,
		},
	},

	Hard = {
		StartingCurrency = 50,
		Hitpoints = 50,
		Multipliers = {
			EnemyHealth = 1.5,
		},
	},

	Insane = {
		StartingCurrency = 50,
		Hitpoints = 20,
		Multipliers = {
			EnemyHealth = 2,
		},
	},

}

return Module
