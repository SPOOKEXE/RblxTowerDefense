
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local AnimationService = ReplicatedModules.Services.AnimationService

local RNetModule = ReplicatedModules.Libraries.RNet
local TowerVFXBridge = RNetModule.Create('TowerVFX')

local SystemsContainer = {}

type VFXFunction = ( Model, Humanoid, Instance, number? ) -> nil

local AnimationMatrix = {

	Wizard = {
		Attack = AnimationService.ResolveAnimationValue('rbxassetid://16693979286'),
	},

}

-- // Module // --
local Module = {}

Module.VFXAttacks = {

	Wizard_Attack1 = function( model : Model, humanoid : Humanoid, target : Instance, _ : number )
		local LoadedAnimation = humanoid.Animator:LoadAnimation( AnimationMatrix.Wizard.Attack )
		LoadedAnimation:Play()

		local Orb1 : Attachment = ReplicatedAssets.VFX.WizardAttack1.Attachment0:Clone()
		Orb1.WorldCFrame = model.RightHand.CFrame
		Orb1.Parent = workspace.Terrain

		local conn; conn = RunService.Heartbeat:Connect(function(dt : number)
			local _, Size = model:GetBoundingBox()
			local Dir : Vector3 = CFrame.lookAt( Orb1.WorldCFrame.Position, (target:GetPivot()* CFrame.new(0, Size.Y/2, 0)).Position ).LookVector
			Orb1.WorldCFrame = Orb1.CFrame + (Dir * 13 * dt) -- n is the projectile speed
		end)

		local dist = (target:GetPivot().Position - Orb1.WorldCFrame.Position).Magnitude
		while target:IsDescendantOf(workspace) and dist > 0.5 do
			task.wait()
			dist = (target:GetPivot().Position - Orb1.WorldCFrame.Position).Magnitude
		end

		conn:Disconnect()
		Orb1:Destroy()

		-- TODO: blast effect
	end,

	Wizard_Attack2 = function( model : Model, humanoid : Humanoid, target : Instance, duration : number )

	end,

	Wizard_Attack3 = function( model : Model, humanoid : Humanoid, target : Instance, duration : number )

	end,

} :: { [string] : VFXFunction }

function Module.RunTowerVFX( model : Model, attackId : string, target : Instance, duration : number? )
	local Humanoid : Humanoid = model:FindFirstChildWhichIsA('Humanoid')
	if not Humanoid then
		return
	end

	local func : VFXFunction = Module.VFXAttacks[ attackId ]
	if func then
		task.spawn( func, model, Humanoid, target, duration or 1 )
	else
		warn('Could not find VFX of id: ' .. tostring(attackId))
	end
end

function Module.Start()
	TowerVFXBridge:OnClientEvent(Module.RunTowerVFX)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
