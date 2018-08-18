TheEyeAddon.Events.Evaluators.COMBAT_LOG = {}
local this = TheEyeAddon.Events.Evaluators.COMBAT_LOG

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local formattedEventInfo = {}
local pairs = pairs
local table = table
local UnitGUID = UnitGUID


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Event Name# #EVENT#COMBAT#NAME#
        #OPTIONAL# #LABEL#Source Unit# #UNIT#
        #OPTIONAL# #LABEL#Destination Unit# #UNIT#
    }
}
]]


this.gameEvents =
{
    "COMBAT_LOG_EVENT_UNFILTERED"
}


function this:InputGroupSetup(inputGroup)
    inputGroup.eventData = formattedEventInfo
end

local function GetValidKeys(inputGroups, rawEventData)
    local unitGUIDs = {} -- @TODO create table that stores the GUIDs for each unitID
    local validKeys = {}
    local subEvent = rawEventData[2]
    local sourceGUID = rawEventData[4]
    local destGUID = rawEventData[8]

    for k,inputGroup in pairs(inputGroups) do
        local sourceUnit = inputGroup.inputValues[2]
        local destUnit = inputGroup.inputValues[3]

        if sourceUnit ~= "_" and unitGUIDs[sourceUnit] == nil then
            unitGUIDs[sourceUnit] = UnitGUID(sourceUnit)
        end
        if destUnit ~= "_" and unitGUIDs[destUnit] == nil then
            unitGUIDs[destUnit] = UnitGUID(destUnit)
        end

        if subEvent == inputGroup.inputValues[1]
            and (sourceUnit == "_" or sourceGUID == unitGUIDs[sourceUnit])
            and (destUnit == "_" or destGUID == unitGUIDs[destUnit])
            then
            table.insert(validKeys, table.concat({ subEvent, sourceUnit, destUnit }))
        end
    end

    return validKeys
end

local function FormatData(rawEventData)
    -- @TODO rework this so formatting is handled by a function in the corresponding
    --  "EventDataFormats." This would allow the data values to be assigned directly to
    --  a table instead of having to create a new one every time.
    local eventDataFormat = this.EventDataFormats[rawEventData[2]]
    local valueNames = eventDataFormat.ValueNames

    for i = 1, #valueNames do
        formattedEventInfo[valueNames[i]] = rawEventData[i]
    end
 
    formattedEventInfo["prefix"] = eventDataFormat["prefix"]
    formattedEventInfo["suffix"] = eventDataFormat["suffix"]
end

function this:GetKeys()
    local rawEventData = { CombatLogGetCurrentEventInfo() }
    local validKeys = GetValidKeys(self.InputGroups, rawEventData)

    if #validKeys > 0 then
        FormatData(rawEventData)
    end

    return validKeys
end

function this:Evaluate(inputGroup)
    -- @DEBUG
    --[[print (formattedEventInfo["event"]
        .. ", sourceUnit: " .. formattedEventInfo["sourceUnit"]
        .. ", destUnit: " .. formattedEventInfo["destUnit"]
        .. ", spellID: " .. tostring(formattedEventInfo["spellID"]))]]
    formattedEventInfo["sourceUnit"] = inputGroup.inputValues[2]
    formattedEventInfo["destUnit"] = inputGroup.inputValues[3]

    return true, formattedEventInfo["event"]
end


this.EventDataFormats =
{
    ENVIRONMENTAL_AURA_APPLIED = { prefix = "ENVIRONMENTAL", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType", "amount" } },
    ENVIRONMENTAL_AURA_APPLIED_DOSE = { prefix = "ENVIRONMENTAL", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType", "amount" } },
    ENVIRONMENTAL_AURA_BROKEN = { prefix = "ENVIRONMENTAL", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType" } },
    ENVIRONMENTAL_AURA_BROKEN_SPELL = { prefix = "ENVIRONMENTAL", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    ENVIRONMENTAL_AURA_REFRESH = { prefix = "ENVIRONMENTAL", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType", "amount" } },
    ENVIRONMENTAL_AURA_REMOVED = { prefix = "ENVIRONMENTAL", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType", "amount" } },
    ENVIRONMENTAL_AURA_REMOVED_DOSE = { prefix = "ENVIRONMENTAL", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "auraType", "amount" } },
    ENVIRONMENTAL_CAST_FAILED = { prefix = "ENVIRONMENTAL", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "failedType" } },
    ENVIRONMENTAL_CAST_START = { prefix = "ENVIRONMENTAL", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_CAST_SUCCESS = { prefix = "ENVIRONMENTAL", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_CREATE = { prefix = "ENVIRONMENTAL", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_DAMAGE = { prefix = "ENVIRONMENTAL", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount", "overkill", "school", "resisted" } },
    ENVIRONMENTAL_DISPEL = { prefix = "ENVIRONMENTAL", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    ENVIRONMENTAL_DISPEL_FAILED = { prefix = "ENVIRONMENTAL", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "extraSpellID", "extraSpellName", "extraSchool" } },
    ENVIRONMENTAL_DRAIN = { prefix = "ENVIRONMENTAL", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount", "powerType", "extraAmount" } },
    ENVIRONMENTAL_DURABILITY_DAMAGE = { prefix = "ENVIRONMENTAL", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_DURABILITY_DAMAGE_ALL = { prefix = "ENVIRONMENTAL", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_ENERGIZE = { prefix = "ENVIRONMENTAL", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    ENVIRONMENTAL_EXTRA_ATTACKS = { prefix = "ENVIRONMENTAL", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount" } },
    ENVIRONMENTAL_HEAL = { prefix = "ENVIRONMENTAL", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount", "overhealing", "absorbed", "critical" } },
    ENVIRONMENTAL_INSTAKILL = { prefix = "ENVIRONMENTAL", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_INTERRUPT = { prefix = "ENVIRONMENTAL", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "extraSpellID", "extraSpellName", "extraSchool" } },
    ENVIRONMENTAL_LEECH = { prefix = "ENVIRONMENTAL", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "amount", "powerType", "extraAmount" } },
    ENVIRONMENTAL_MISSED = { prefix = "ENVIRONMENTAL", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "missType", "isOffHand", "amountMissed" } },
    ENVIRONMENTAL_RESURRECT = { prefix = "ENVIRONMENTAL", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    ENVIRONMENTAL_STOLEN = { prefix = "ENVIRONMENTAL", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    ENVIRONMENTAL_SUMMON = { prefix = "ENVIRONMENTAL", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "environmentalType" } },
    PARTY_KILL = { prefix = "PARTY", suffix = "KILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    RANGE_AURA_APPLIED = { prefix = "RANGE", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    RANGE_AURA_APPLIED_DOSE = { prefix = "RANGE", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    RANGE_AURA_BROKEN = { prefix = "RANGE", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType" } },
    RANGE_AURA_BROKEN_SPELL = { prefix = "RANGE", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    RANGE_AURA_REFRESH = { prefix = "RANGE", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    RANGE_AURA_REMOVED = { prefix = "RANGE", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    RANGE_AURA_REMOVED_DOSE = { prefix = "RANGE", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    RANGE_CAST_FAILED = { prefix = "RANGE", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "failedType" } },
    RANGE_CAST_START = { prefix = "RANGE", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_CAST_SUCCESS = { prefix = "RANGE", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_CREATE = { prefix = "RANGE", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_DAMAGE = { prefix = "RANGE", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overkill", "school", "resisted" } },
    RANGE_DISPEL = { prefix = "RANGE", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    RANGE_DISPEL_FAILED = { prefix = "RANGE", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    RANGE_DRAIN = { prefix = "RANGE", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    RANGE_DURABILITY_DAMAGE = { prefix = "RANGE", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_DURABILITY_DAMAGE_ALL = { prefix = "RANGE", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_ENERGIZE = { prefix = "RANGE", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    RANGE_EXTRA_ATTACKS = { prefix = "RANGE", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount" } },
    RANGE_HEAL = { prefix = "RANGE", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overhealing", "absorbed", "critical" } },
    RANGE_INSTAKILL = { prefix = "RANGE", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_INTERRUPT = { prefix = "RANGE", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    RANGE_LEECH = { prefix = "RANGE", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    RANGE_MISSED = { prefix = "RANGE", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "missType", "isOffHand", "amountMissed" } },
    RANGE_RESURRECT = { prefix = "RANGE", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    RANGE_STOLEN = { prefix = "RANGE", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    RANGE_SUMMON = { prefix = "RANGE", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_AURA_APPLIED = { prefix = "SPELL", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_AURA_APPLIED_DOSE = { prefix = "SPELL", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_AURA_BROKEN = { prefix = "SPELL", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType" } },
    SPELL_AURA_BROKEN_SPELL = { prefix = "SPELL", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_AURA_REFRESH = { prefix = "SPELL", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_AURA_REMOVED = { prefix = "SPELL", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_AURA_REMOVED_DOSE = { prefix = "SPELL", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_CAST_FAILED = { prefix = "SPELL", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "failedType" } },
    SPELL_CAST_START = { prefix = "SPELL", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_CAST_SUCCESS = { prefix = "SPELL", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_CREATE = { prefix = "SPELL", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_DAMAGE = { prefix = "SPELL", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overkill", "school", "resisted" } },
    SPELL_DISPEL = { prefix = "SPELL", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_DISPEL_FAILED = { prefix = "SPELL", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_DRAIN = { prefix = "SPELL", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_DURABILITY_DAMAGE = { prefix = "SPELL", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_DURABILITY_DAMAGE_ALL = { prefix = "SPELL", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_ENERGIZE = { prefix = "SPELL", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    SPELL_EXTRA_ATTACKS = { prefix = "SPELL", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount" } },
    SPELL_HEAL = { prefix = "SPELL", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overhealing", "absorbed", "critical" } },
    SPELL_INSTAKILL = { prefix = "SPELL", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_INTERRUPT = { prefix = "SPELL", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_LEECH = { prefix = "SPELL", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_MISSED = { prefix = "SPELL", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "missType", "isOffHand", "amountMissed" } },
    SPELL_RESURRECT = { prefix = "SPELL", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_STOLEN = { prefix = "SPELL", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_SUMMON = { prefix = "SPELL", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_AURA_APPLIED = { prefix = "SPELL_BUILDING", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_BUILDING_AURA_APPLIED_DOSE = { prefix = "SPELL_BUILDING", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_BUILDING_AURA_BROKEN = { prefix = "SPELL_BUILDING", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType" } },
    SPELL_BUILDING_AURA_BROKEN_SPELL = { prefix = "SPELL_BUILDING", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_BUILDING_AURA_REFRESH = { prefix = "SPELL_BUILDING", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_BUILDING_AURA_REMOVED = { prefix = "SPELL_BUILDING", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_BUILDING_AURA_REMOVED_DOSE = { prefix = "SPELL_BUILDING", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_BUILDING_CAST_FAILED = { prefix = "SPELL_BUILDING", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "failedType" } },
    SPELL_BUILDING_CAST_START = { prefix = "SPELL_BUILDING", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_CAST_SUCCESS = { prefix = "SPELL_BUILDING", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_CREATE = { prefix = "SPELL_BUILDING", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_DAMAGE = { prefix = "SPELL_BUILDING", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overkill", "school", "resisted" } },
    SPELL_BUILDING_DISPEL = { prefix = "SPELL_BUILDING", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_BUILDING_DISPEL_FAILED = { prefix = "SPELL_BUILDING", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_BUILDING_DRAIN = { prefix = "SPELL_BUILDING", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_BUILDING_DURABILITY_DAMAGE = { prefix = "SPELL_BUILDING", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_DURABILITY_DAMAGE_ALL = { prefix = "SPELL_BUILDING", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_ENERGIZE = { prefix = "SPELL_BUILDING", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    SPELL_BUILDING_EXTRA_ATTACKS = { prefix = "SPELL_BUILDING", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount" } },
    SPELL_BUILDING_HEAL = { prefix = "SPELL_BUILDING", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overhealing", "absorbed", "critical" } },
    SPELL_BUILDING_INSTAKILL = { prefix = "SPELL_BUILDING", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_INTERRUPT = { prefix = "SPELL_BUILDING", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_BUILDING_LEECH = { prefix = "SPELL_BUILDING", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_BUILDING_MISSED = { prefix = "SPELL_BUILDING", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "missType", "isOffHand", "amountMissed" } },
    SPELL_BUILDING_RESURRECT = { prefix = "SPELL_BUILDING", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_BUILDING_STOLEN = { prefix = "SPELL_BUILDING", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_BUILDING_SUMMON = { prefix = "SPELL_BUILDING", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_AURA_APPLIED = { prefix = "SPELL_PERIODIC", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_PERIODIC_AURA_APPLIED_DOSE = { prefix = "SPELL_PERIODIC", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_PERIODIC_AURA_BROKEN = { prefix = "SPELL_PERIODIC", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType" } },
    SPELL_PERIODIC_AURA_BROKEN_SPELL = { prefix = "SPELL_PERIODIC", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_PERIODIC_AURA_REFRESH = { prefix = "SPELL_PERIODIC", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_PERIODIC_AURA_REMOVED = { prefix = "SPELL_PERIODIC", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_PERIODIC_AURA_REMOVED_DOSE = { prefix = "SPELL_PERIODIC", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "auraType", "amount" } },
    SPELL_PERIODIC_CAST_FAILED = { prefix = "SPELL_PERIODIC", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "failedType" } },
    SPELL_PERIODIC_CAST_START = { prefix = "SPELL_PERIODIC", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_CAST_SUCCESS = { prefix = "SPELL_PERIODIC", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_CREATE = { prefix = "SPELL_PERIODIC", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_DAMAGE = { prefix = "SPELL_PERIODIC", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overkill", "school", "resisted" } },
    SPELL_PERIODIC_DISPEL = { prefix = "SPELL_PERIODIC", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_PERIODIC_DISPEL_FAILED = { prefix = "SPELL_PERIODIC", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_PERIODIC_DRAIN = { prefix = "SPELL_PERIODIC", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_PERIODIC_DURABILITY_DAMAGE = { prefix = "SPELL_PERIODIC", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_DURABILITY_DAMAGE_ALL = { prefix = "SPELL_PERIODIC", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_ENERGIZE = { prefix = "SPELL_PERIODIC", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    SPELL_PERIODIC_EXTRA_ATTACKS = { prefix = "SPELL_PERIODIC", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount" } },
    SPELL_PERIODIC_HEAL = { prefix = "SPELL_PERIODIC", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "overhealing", "absorbed", "critical" } },
    SPELL_PERIODIC_INSTAKILL = { prefix = "SPELL_PERIODIC", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_INTERRUPT = { prefix = "SPELL_PERIODIC", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool" } },
    SPELL_PERIODIC_LEECH = { prefix = "SPELL_PERIODIC", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "amount", "powerType", "extraAmount" } },
    SPELL_PERIODIC_MISSED = { prefix = "SPELL_PERIODIC", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "missType", "isOffHand", "amountMissed" } },
    SPELL_PERIODIC_RESURRECT = { prefix = "SPELL_PERIODIC", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SPELL_PERIODIC_STOLEN = { prefix = "SPELL_PERIODIC", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SPELL_PERIODIC_SUMMON = { prefix = "SPELL_PERIODIC", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "spellID", "spellName", "spellSchool" } },
    SWING_AURA_APPLIED = { prefix = "SWING", suffix = "AURA_APPLIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType", "amount" } },
    SWING_AURA_APPLIED_DOSE = { prefix = "SWING", suffix = "AURA_APPLIED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType", "amount" } },
    SWING_AURA_BROKEN = { prefix = "SWING", suffix = "AURA_BROKEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType" } },
    SWING_AURA_BROKEN_SPELL = { prefix = "SWING", suffix = "AURA_BROKEN_SPELL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SWING_AURA_REFRESH = { prefix = "SWING", suffix = "AURA_REFRESH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType", "amount" } },
    SWING_AURA_REMOVED = { prefix = "SWING", suffix = "AURA_REMOVED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType", "amount" } },
    SWING_AURA_REMOVED_DOSE = { prefix = "SWING", suffix = "AURA_REMOVED_DOSE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "auraType", "amount" } },
    SWING_CAST_FAILED = { prefix = "SWING", suffix = "CAST_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "failedType" } },
    SWING_CAST_START = { prefix = "SWING", suffix = "CAST_START", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_CAST_SUCCESS = { prefix = "SWING", suffix = "CAST_SUCCESS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_CREATE = { prefix = "SWING", suffix = "CREATE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_DAMAGE = { prefix = "SWING", suffix = "DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount", "overkill", "school", "resisted" } },
    SWING_DISPEL = { prefix = "SWING", suffix = "DISPEL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SWING_DISPEL_FAILED = { prefix = "SWING", suffix = "DISPEL_FAILED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "extraSpellID", "extraSpellName", "extraSchool" } },
    SWING_DRAIN = { prefix = "SWING", suffix = "DRAIN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount", "powerType", "extraAmount" } },
    SWING_DURABILITY_DAMAGE = { prefix = "SWING", suffix = "DURABILITY_DAMAGE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_DURABILITY_DAMAGE_ALL = { prefix = "SWING", suffix = "DURABILITY_DAMAGE_ALL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_ENERGIZE = { prefix = "SWING", suffix = "ENERGIZE", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount", "overEnergize", "powerType", "alternatePowerType" } },
    SWING_EXTRA_ATTACKS = { prefix = "SWING", suffix = "EXTRA_ATTACKS", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount" } },
    SWING_HEAL = { prefix = "SWING", suffix = "HEAL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount", "overhealing", "absorbed", "critical" } },
    SWING_INSTAKILL = { prefix = "SWING", suffix = "INSTAKILL", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_INTERRUPT = { prefix = "SWING", suffix = "INTERRUPT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "extraSpellID", "extraSpellName", "extraSchool" } },
    SWING_LEECH = { prefix = "SWING", suffix = "LEECH", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "amount", "powerType", "extraAmount" } },
    SWING_MISSED = { prefix = "SWING", suffix = "MISSED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "missType", "isOffHand", "amountMissed" } },
    SWING_RESURRECT = { prefix = "SWING", suffix = "RESURRECT", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    SWING_STOLEN = { prefix = "SWING", suffix = "STOLEN", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "extraSpellID", "extraSpellName", "extraSchool", "auraType" } },
    SWING_SUMMON = { prefix = "SWING", suffix = "SUMMON", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags" } },
    UNIT_DIED = { prefix = "UNIT", suffix = "DIED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "recapID", "unconsciousOnDeath" } },
    UNIT_DESTROYED = { prefix = "UNIT", suffix = "DESTROYED", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "recapID", "unconsciousOnDeath" } },
    UNIT_DISSIPATES = { prefix = "UNIT", suffix = "DISSIPATES", ValueNames = { "timestamp", "event", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags", "recapID", "unconsciousOnDeath" } },
}