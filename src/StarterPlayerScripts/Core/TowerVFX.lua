
local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.VFXAttacks = {

	Wizard_Attack1 = function( model : Model, humanoid : Humanoid, target : Instance, duration : number )

	end,

	Wizard_Attack2 = function( model : Model, humanoid : Humanoid, target : Instance, duration : number )

	end,

	Wizard_Attack3 = function( model : Model, humanoid : Humanoid, target : Instance, duration : number )

	end,

}

function Module.RunTowerVFX( model : Model, attackId : string, target : Instance, duration : number )
	local func = Module.VFXAttacks[ attackId ]
	if func then
		task.spawn( func, model, model.Humanoid, target, duration )
	else
		warn( 'Could not find VFX of id: ' .. tostring(attackId) )
	end
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
