
local Module = {}

function Module.ClampToGrid( position : Vector3, grid : number, lockY : boolean )
	return Vector3.new(
		math.round(position.X / grid) * grid,
		lockY and position.Y or (math.floor(position.Y / grid) * grid),
		math.round(position.Z / grid) * grid
	)
end

function Module.GetModelBoundingBoxData( Model : Model | BasePart ) : (CFrame, Vector3)
	if Model:IsA('Model') then
		return Model:GetBoundingBox()
	end
	return Model.CFrame, Model.Size
end

return Module
