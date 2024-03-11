
export type TowerConfig = {
	Name : string,
	Cost : number,

	Model : string,
	ModelScale : number,

	Upgrades : {
		{
			Damage : number,
			AttackInterval : number, -- attacks/second
			Range : number,
			Cost : number,
			VFXAttackIDs : { string },
		}
	},
}

-- // Module // --
local Module = {}

Module.Towers = {

	Wizard = {
		Name = 'Wizard',
		Cost = 50,

		Model = 'Wizard',
		ModelScale = 0.5,

		Upgrades = {
			{ -- first index is the default
				Damage = 2,
				AttackInterval = 1.1,
				Range = 7,
				Cost = 0,
				VFXAttackIDs = { 'Wizard_Attack1', },
			},
			{
				Damage = 5,
				AttackInterval = 1,
				Range = 9,
				Cost = 100,
				VFXAttackIDs = { 'Wizard_Attack1', 'Wizard_Attack2', },
			},
			{
				Damage = 10,
				AttackInterval = 0.9,
				Range = 11,
				Cost = 250,
				VFXAttackIDs = { 'Wizard_Attack1', 'Wizard_Attack2', 'Wizard_Attack3', },
			},
		},
	},

}

function Module.GetConfigFromId( id : string ) : TowerConfig?
	return Module.Towers[id]
end

return Module
