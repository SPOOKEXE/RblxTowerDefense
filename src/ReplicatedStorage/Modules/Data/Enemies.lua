
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

	DefaultRig1 = {
		Model = 'TemplateRig',
		MaxHealth = 2,
		WalkSpeed = 9,

		Damage = 1,
		CurrencyDrop = 1,
		HitpointsDrop = 0,

		ModelScale = 0.5,
	},

	DefaultRig2 = {
		Model = 'TemplateRig',
		MaxHealth = 4,
		WalkSpeed = 9,

		Damage = 1,
		CurrencyDrop = 2,
		HitpointsDrop = 0,

		ModelScale = 0.5,
	},

	DefaultRig3 = {
		Model = 'TemplateRig',
		MaxHealth = 6,
		WalkSpeed = 10,

		Damage = 1,
		CurrencyDrop = 2,
		HitpointsDrop = 0,

		ModelScale = 0.5,
	},

	DefaultRig4 = {
		Model = 'TemplateRig',
		MaxHealth = 8,
		WalkSpeed = 10,

		Damage = 1,
		CurrencyDrop = 2,
		HitpointsDrop = 0,

		ModelScale = 0.4,
	},

	DefaultBoss = {
		Model = 'TemplateBoss',
		MaxHealth = 12,
		WalkSpeed = 11,

		Damage = 10,
		CurrencyDrop = 10,
		HitpointsDrop = 0,

		ModelScale = 0.6,
	},

	DefaultUltraBoss1 = {
		Model = 'TemplateBoss',
		MaxHealth = 76,
		WalkSpeed = 10,

		Damage = 50,
		CurrencyDrop = 25,
		HitpointsDrop = 0,

		ModelScale = 0.8,
	},

}

function Module.GetConfigFromId( id : string ) : EnemyConfig?
	return Module.Enemies[id]
end

return Module
