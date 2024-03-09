
export type TowerConfig = {
	Model : string,
	ModelScale : number,
	Cost : number,

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
		Name = 'Wizard',
		Cost = 50,

		Model = 'Wizard',
		ModelScale = 0.5,

		Upgrades = {
			{ -- first index is the default
				Damage = 5,
				AttackSpeed = 1.5,
				Range = 5,
				Cost = -1,
				VFXAttackIDs = { 'Wizard_Attack1', },
			},
			{
				Damage = 10,
				AttackSpeed = 1.2,
				Range = 7,
				Cost = 100,
				VFXAttackIDs = { 'Wizard_Attack1', 'Wizard_Attack2', },
			},
			{
				Damage = 20,
				AttackSpeed = 0.9,
				Range = 9,
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
