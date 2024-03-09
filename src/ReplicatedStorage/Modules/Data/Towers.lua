
export type TowerConfig = {
	Model : string,
	ModelScale : number,

	Upgrades : {
		{
			Damage : number,
			AttackSpeed : number, -- attacks/second
			Cost : number,
			VFXAttackIDs : { string },
		}
	},
}

-- // Module // --
local Module = {}

Module.Towers = {

	Wizard = {
		Model = 'Wizard',
		ModelScale = 0.5,
		Upgrades = {
			{ -- first index is the default
				Damage = 5,
				AttackSpeed = 1.5,
				Cost = -1,
				VFXAttackIDs = { 'Wizard_Attack1', },
			},
			{
				Damage = 10,
				AttackSpeed = 1.2,
				Cost = 100,
				VFXAttackIDs = { 'Wizard_Attack1', 'Wizard_Attack2', },
			},
			{
				Damage = 20,
				AttackSpeed = 0.9,
				Cost = 250,
				VFXAttackIDs = { 'Wizard_Attack1', 'Wizard_Attack2', 'Wizard_Attack3', },
			},
		},
	},

}

return Module
