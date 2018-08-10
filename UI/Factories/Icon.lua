TheEyeAddon.UI.Factories.Icon = {}
local this = TheEyeAddon.UI.Factories.Icon

local GetItemInfo = GetItemInfo
local GetSpellTexture = GetSpellTexture
local Pool = TheEyeAddon.UI.Pools.Create()
local select = select
local TextureCreate = TheEyeAddon.UI.Factories.Texture.Create


local function GetIconTextureFileID(iconObjectType, iconObjectID)
	local fileID = nil

	if iconObjectType == "SPELL" then
		fileID = GetSpellTexture(iconObjectID)
		if fileID == nil then
			error("Could not find a spell with an ID of " ..
			tostring(iconObjectID) ..
			".")
			return
		end
	elseif iconObjectType == "ITEM" then
		local fileID = select(10, GetItemInfo(iconObjectID))
		if fileID == nil then
			error("Could not find an item with an ID of " ..
			tostring(iconObjectID) ..
			".")
			return
		end
	else
		error("No case exists for an iconObjectType of " ..
		tostring(iconObjectType) ..
		". iconObjectID passed: " ..
		tostring(iconObjectID) ..
		".")
		return
	end

	return fileID
end


function this.Claim(uiObject, parentFrame, displayData)
	local instance = Pool:Claim(uiObject, "Frame", parentFrame, nil, displayData)

	local iconTextureFileID = GetIconTextureFileID(displayData.iconObjectType, displayData.iconObjectID)
	instance.texture = TextureCreate(instance.texture, instance, "BACKGROUND", iconTextureFileID)
	
	return instance
end