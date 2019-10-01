TheEyeAddon.Helpers.Auras = {}
local this = TheEyeAddon.Helpers.Auras

local auraFilters = TheEyeAddon.Data.auraFilters
local GetPropertiesOfType = TheEyeAddon.Managers.Icons.GetPropertiesOfType
local IconsGetFiltered = TheEyeAddon.Managers.Icons.GetFiltered
local select = select
local table = table
local UnitAura = UnitAura


function this.UnitAuraGetBySpellID(sourceUnitExpected, destUnit, spellIDExpected)
    local filter = "HELPFUL"

    local icons = IconsGetFiltered(
    {
        {
            {
                type = "OBJECT_ID",
                value = spellIDExpected,
            },
        },
    })

    if #icons > 0 then
        local CATEGORY = GetPropertiesOfType(icons[1], "CATEGORY")
        if CATEGORY.value == "DAMAGE" then
            filter = "HARMFUL"
        end
    end

    for i = 1, 40 do -- 40 is the maximum number of auras that can be on a unit
        local auraValues = { UnitAura(destUnit, i, filter) }
        local spellID = auraValues[10]

        if spellID ~= nil then
            local sourceUnit = auraValues[7]
            if spellID == spellIDExpected
                and (sourceUnitExpected == "_" or sourceUnit == sourceUnitExpected)
                then
                
                return auraValues
            end
        else
            return nil
        end
    end
end