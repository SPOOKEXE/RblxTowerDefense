
export type EnemyConfig = {
	Model : string,
	MaxHealth : number,
	WalkSpeed : number,

	Damage : number,
	CurrencyDrop : number,
	HitpointsDrop : number,

	ModelScale : number,
}

-- // Module // --
local Module = {}

Module.Enemies = {

	DefaultRig = {
		Model = 'TemplateRig',
		MaxHealth = 5,
		WalkSpeed = 16,

		Damage = 1,
		CurrencyDrop = 2,
		HitpointsDrop = 0,

		ModelScale = 0.5,
	},

}

function Module.GetConfigFromId( id : string ) : EnemyConfig?
	return Module.Enemies[id]
end

return Module
