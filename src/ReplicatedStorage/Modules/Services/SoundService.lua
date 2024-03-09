
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundsFolder = ReplicatedStorage:WaitForChild('Assets'):WaitForChild('Sounds')

local function CreateAssetSound( soundId : string ) : Sound
	local rbxassetSound = Instance.new('Sound')
	rbxassetSound.Name = soundId
	rbxassetSound.Looped = false
	rbxassetSound.Playing = false
	rbxassetSound.PlayOnRemove = false
	rbxassetSound.SoundId = soundId
	rbxassetSound.Parent = SoundsFolder
	return rbxassetSound
end

-- // Module // --
local Module = {}

function Module.ResolveSoundToInstance( sound : number | string | Sound ) : Sound?
	if typeof(sound) == 'number' then
		sound = 'rbxassetid://'..tostring(sound)
	end
	if typeof(sound) == 'string' then
		local TargetSound = SoundsFolder:FindFirstChild( sound )
		if not TargetSound and string.find( sound, 'rbxassetid://' ) then
			TargetSound = CreateAssetSound( sound )
		end
		return TargetSound
	end
	if typeof(sound) == 'Instance' then
		return sound
	end
	return nil
end

function Module.CreateSoundAtPosition( sound : number | string | Sound, position : Vector3 ) : (Sound?, Attachment?)
	local targetSound = Module.ResolveSoundToInstance( sound )
	if not targetSound then
		warn('Failed to create sound at position because the sound could not be resolved. ' .. tostring(sound))
		return nil, nil
	end

	local attachment = Instance.new('Attachment')
	attachment.Name = 'sound_'..tostring(sound)
	attachment.WorldCFrame = CFrame.new( position )
	attachment.Parent = workspace.Terrain

	targetSound = targetSound:Clone()
	targetSound.Parent = attachment
	return targetSound, attachment
end

function Module.PlaySoundAtPosition( sound : number | string | Sound, position : Vector3 )
	local soundInstance, attachment = Module.CreateSoundAtPosition( sound, position )
	if not soundInstance then
		return
	end
	soundInstance:Play()
	Debris:AddItem( attachment, soundInstance.TimeLength )
end

return Module
