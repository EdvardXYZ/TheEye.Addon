TheEyeAddon.UI.Factories.Group = {}
local this = TheEyeAddon.UI.Factories.Group

local Pool = TheEyeAddon.UI.Pools.Create()


function this.Claim(uiObject, parentFrame, displayData)
	local instance = Pool:Claim(uiObject, "Frame", parentFrame, nil, displayData.DimensionTemplate)
	
	return instance
end