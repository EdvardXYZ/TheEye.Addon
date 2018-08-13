TheEyeAddon.Events.Evaluators.UNIT_THREAT_SITUATION_CHANGED = {}
local this = TheEyeAddon.Events.Evaluators.UNIT_THREAT_SITUATION_CHANGED
this.name = "UNIT_THREAT_SITUATION_CHANGED"

local UnitThreatSituation = UnitThreatSituation


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Unit# #UNIT#
        #OPTIONAL# #LABEL#Other Unit# #UNIT#
    }
}
]]


this.reevaluateEvents =
{
    UNIT_THREAT_SITUATION_UPDATE = true
}
this.gameEvents =
{
    "UNIT_THREAT_SITUATION_UPDATE",
}


local function CalculateCurrentValue(inputValues)
    local otherUnit = inputValues[2]
    local threatSituation

    if otherUnit == "_" then
        threatSituation = UnitThreatSituation(inputValues[1])
    else
        threatSituation = UnitThreatSituation(inputValues[1], otherUnit)
    end

    return threatSituation or -1
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:Evaluate(inputGroup, event)
    local threatSituation = CalculateCurrentValue(inputGroup.inputValues)

    if inputGroup.currentValue ~= threatSituation then
        inputGroup.currentValue = threatSituation
        return true, this.name, threatSituation
    end
end