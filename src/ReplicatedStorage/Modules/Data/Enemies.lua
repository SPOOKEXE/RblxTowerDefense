
export type EnemyConfig = {
	Health : number,
	Damage : number,
	Speed : number,

	CurrencyDrop : number,
	HitpointsDrop : number
}

-- // Module // --
local Module = {}

Module.Enemies = {

	DefaultRig = {
		Health = 5,
		Damage = 1,
		Speed = 4,

		CurrencyDrop = 2,
		HitpointsDrop = 0,
	},

}

function Module.GetConfigFromId( id : string ) : EnemyConfig?
	return Module.Enemies[id]
end

return Module
