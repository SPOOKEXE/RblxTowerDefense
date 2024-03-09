
-- // Module // --
local Module = {}

Module.Waves = {

	Map0 = {
		WaveInterval = 30,
		Waves = {
			{ -- wave 1

			},
			{ -- wave 2

			},
		},
	},

}

function Module.GetConfigFromId( id : string ) : {}?
	return Module.Waves[id]
end

return Module
