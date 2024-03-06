
local CharacterDataModule = require(script.Parent.Parent.Data.CharacterData)

local function SetupCharacterAccessory( AccessoryInstance )
	AccessoryInstance.Name = ''
	for _, BasePart in ipairs( AccessoryInstance:GetDescendants() ) do
		if BasePart:IsA("BasePart") then
			BasePart.Anchored = false
			BasePart.CanCollide = false
			BasePart.CanTouch = false
			BasePart.CanQuery = false
			BasePart.Massless = true
		end
	end
end

-- // Module // --
local Module = {}

function Module.ClearCosmeticsAccessories( Model )
	for _, item in ipairs( Model:GetChildren() ) do
		if item:GetAttribute('CosmeticAccessory') and item:IsA('Accessory') then
			item:Destroy()
		end
	end
end

function Module.ClearCosmetics( Model )
	for _, item in ipairs( Model:GetChildren() ) do
		if item:GetAttribute('CosmeticAccessory') then
			item:Destroy()
		end
	end
	local Face = Model:FindFirstChild('Head') and Model.Head:FindFirstChildWhichIsA("Decal")
	if Face and Face:GetAttribute('CosmeticAccessory') then
		Face:Destroy()
	end
end

function Module.ApplyCosmeticData( Model, CosmeticData )

	for category, value in pairs( CosmeticData ) do
		-- update changed items
		local Reference = CharacterDataModule.Options[ category ]
		local Item = Reference and Reference:FindFirstChild( value )
		if not Item then
			warn("Cannot find accessory named " .. tostring(value) .. " for category " .. tostring(category))
			continue -- unable to equip it
		end
		if category == "Hair1" or category == "Hair2" then
			-- update accessories
			Item = Item:Clone()
			SetupCharacterAccessory( Item )
			local Constraint = Instance.new('RigidConstraint')
			Constraint.Attachment0 = Item.Handle.HairAttachment
			Constraint.Attachment1 = Model.Head.HairAttachment
			Constraint.Parent = Item.Handle
			Item.Parent = Model
			-- CharacterAccessoryMaidInstance:Give(Item)
		elseif category == "Face" then
			-- update face
			local OldFace = Model.Head:FindFirstChildWhichIsA("Decal")
			if OldFace then
				OldFace.Texture = Item.Texture
			else
				OldFace = Item:Clone()
				OldFace.Parent = Model.Head
			end
		elseif category == "Clothes" then
			-- update shirt
			local ShirtSource = Item:FindFirstChildWhichIsA("Shirt")
			local ShirtDestination = Model:FindFirstChildWhichIsA("Shirt")
			if ShirtSource and ShirtDestination then
				ShirtDestination.ShirtTemplate = ShirtSource.ShirtTemplate
			elseif ShirtSource and not ShirtDestination then
				ShirtSource:Clone().Parent = Model
			end
			-- update pants
			local PantsSource = Item:FindFirstChildWhichIsA("Pants")
			local PantsDestination = Model:FindFirstChildWhichIsA("Pants")
			if PantsSource and PantsDestination then
				PantsDestination.PantsTemplate = PantsSource.PantsTemplate
			elseif PantsSource and not PantsDestination then
				PantsSource:Clone().Parent = Model
			end
		end
		Item:SetAttribute('CosmeticAccessory', true)
	end

end

return Module
