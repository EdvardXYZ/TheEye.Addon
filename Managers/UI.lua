TheEye.Core.Managers.UI = {}
local this = TheEye.Core.Managers.UI

local DebugLogEntryAdd = TheEye.Core.Managers.Debug.LogEntryAdd
local groupers = {}
local moduleComponentNames =
{
    ACTIVE = "ActiveGroup",
    COOLDOWN = "CooldownGroup",
    ROTATION = "RotationGroup",
    SITUATIONAL = "SituationalGroup",
}
local playerSpec
local table = table


this.Modules =
{
    CastBars = {},
    EncounterAlerts = {},
    IconGroups = {},
    TargetFrames = {},
}


function this.Initialize()
    this.gameEvents =
    {
        "ADDON_LOADED",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_SPECIALIZATION_CHANGED",
    }
    TheEye.Core.Managers.Events.Register(this)

    this.inputValues = { --[[addonName]] "TheEye.Core" }
    TheEye.Core.Managers.Evaluators.ListenerRegister("ADDON_LOADED", this)
    
    CastingBarFrame:UnregisterAllEvents()
end

function this.FormatData(uiObject)
    local key = table.concat(uiObject.tags, "_")
    uiObject.key = key
    TheEye.Core.UI.Objects.Instances[key] = uiObject

    local searchableTags = {}
    local tags = uiObject.tags
    for i = 1, #tags do
        searchableTags[tags[i]] = true
    end
    uiObject.tags = searchableTags
end

function this.UIObjectSetup(uiObject)
    local components = TheEye.Core.UI.Components
    local pairs = pairs

    this.currentUIObject = uiObject
    
    uiObject.Deactivate = function()
        for componentKey,_ in pairs(uiObject) do
            local component = components[componentKey]
            local componentInstance = uiObject[componentKey]
            if component ~= nil and componentInstance ~= nil then
                componentInstance:Deactivate()
            end
        end
    end

    for componentKey,_ in pairs(uiObject) do
        local component = components[componentKey]
        local componentInstance = uiObject[componentKey]
        if component ~= nil and componentInstance.wasSetup == nil then
            this.currentComponent = componentInstance
            componentInstance.key = componentKey

            component.Setup(componentInstance, uiObject)
            componentInstance.wasSetup = true
        end
    end
end

function this.GrouperAdd(uiObject, setupFunction)
    local grouperKey = uiObject.tags[1]
    
    groupers[grouperKey] =
    {
        UIObject = uiObject,
        Setup = setupFunction,
    }
end

function this.ModuleAdd(key, module)
    this.Modules[key][module.type] = module
end

local function GrouperUIObjectSetup(uiObject)
    this.FormatData(uiObject)
    this.UIObjectSetup(uiObject)
end

local function IconGroupUIObjectSetup(iconGroupData, maxIcons)
    local parentKey = groupers[iconGroupData.grouper].UIObject.key

    local uiObject =
    {
        Child =
        {
            parentKey = parentKey,
        },
        EnabledState =
        {
            ValueHandler =
            {
                validKeys = { [2] = true },
            },
            ListenerGroup =
            {
                Listeners =
                {
                    {
                        eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                        inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                        value = 2,
                    },
                },
            },
        },
        Frame =
        {
            Dimensions = iconGroupData.Dimensions
        },
        PriorityRank =
        {
            ValueHandler =
            {
                validKeys = { [0] = iconGroupData.grouperPriority, }
            },
        },
        VisibleState =
        {
            ValueHandler =
            {
                validKeys = { [0] = true },
            },
        }
    }

    -- Key
    if iconGroupData.instanceID == nil then
        iconGroupData.instanceID = string.sub(tostring(uiObject), 13, 19)
    end
    uiObject.instanceID = iconGroupData.instanceID
    uiObject.tags = { "GROUP", iconGroupData.instanceID }
    this.FormatData(uiObject)

    -- Group Component
    uiObject.Group =
    {
        instanceID = iconGroupData.instanceID,
        instanceType = iconGroupData.type,
        Filters = iconGroupData.Filters,
        IconDimensions = iconGroupData.IconDimensions,
        PriorityDisplayers = iconGroupData.PriorityDisplayers,
        childArranger = TheEye.Core.Helpers.ChildArrangers[iconGroupData.Group.childArranger],
        maxDisplayedChildren = maxIcons,
        sortActionName = iconGroupData.Group.sortActionName,
        sortValueComponentName = iconGroupData.Group.sortValueComponentName,
    }
    uiObject[moduleComponentNames[iconGroupData.type]] = uiObject.Group

    -- Setup
    this.UIObjectSetup(uiObject)
    
    local icons = uiObject[moduleComponentNames[iconGroupData.type]].Icons
    for i = 1, #icons do
        local iconUIObject = icons[i].UIObject
        iconUIObject.IconData = icons[i]
        this.FormatData(iconUIObject)
        this.UIObjectSetup(iconUIObject)

        -- DEBUG
        -- EnabledState
        local validKeys = iconUIObject.EnabledState.ValueHandler.validKeys
        local formattedValidKeys = {}
        for k,v in pairs(validKeys) do
            table.insert(formattedValidKeys, k)
            table.insert(formattedValidKeys, ", ")
        end
        table.remove(formattedValidKeys, #formattedValidKeys)
        DebugLogEntryAdd("TheEye.Core.Managers.UI", "IconGroupUIObjectSetup: EnabledState Valid Keys", iconUIObject, iconUIObject.EnabledState, table.concat(formattedValidKeys))
        
        local listeners = iconUIObject.EnabledState.ListenerGroup.Listeners
        for i = 1, #listeners do
            DebugLogEntryAdd("TheEye.Core.Managers.UI", "IconGroupUIObjectSetup: EnabledState Listeners", iconUIObject, iconUIObject.EnabledState, listeners[i].eventEvaluatorKey, table.concat(listeners[i].inputValues), listeners[i].value)
        end

        -- VisibleState
        validKeys = iconUIObject.VisibleState.ValueHandler.validKeys
        formattedValidKeys = {}
        for k,v in pairs(validKeys) do
            table.insert(formattedValidKeys, k)
            table.insert(formattedValidKeys, ", ")
        end
        table.remove(formattedValidKeys, #formattedValidKeys)
        DebugLogEntryAdd("TheEye.Core.Managers.UI", "IconGroupUIObjectSetup: VisibleState Valid Keys", iconUIObject, iconUIObject.VisibleState, table.concat(formattedValidKeys))

        listeners = iconUIObject.VisibleState.ListenerGroup.Listeners
        for i = 1, #listeners do
            DebugLogEntryAdd("TheEye.Core.Managers.UI", "IconGroupUIObjectSetup: VisibleState Listeners", iconUIObject, iconUIObject.VisibleState, listeners[i].eventEvaluatorKey, table.concat(listeners[i].inputValues), listeners[i].value)
        end
    end

    return uiObject
end

local function CastBarUIObjectSetup(castBarData)
    local parentKey = groupers[castBarData.grouper].UIObject.key

    local uiObject =
    {
        Child =
        {
            parentKey = parentKey,
        },
        EnabledState =
        {
            ValueHandler =
            {
                validKeys = { [2] = true },
            },
            ListenerGroup =
            {
                Listeners =
                {
                    {
                        eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                        inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                        value = 2,
                    },
                },
            },
        },
        Frame =
        {
            Dimensions = castBarData.Dimensions
        },
        PriorityRank =
        {
            ValueHandler =
            {
                validKeys = { [0] = castBarData.grouperPriority, }
            },
        },
        VisibleState = castBarData.VisibleState,
    }

    if castBarData.unit == "player" then
        uiObject.PlayerCast = { unit = castBarData.unit }
    elseif castBarData.unit == "target" then
        uiObject.TargetCast = { unit = castBarData.unit }
    else
        print("DEBUG: unknown component for cast bar with a unit type of " .. castBarData.unit .. ".")
    end

    -- Key
    if castBarData.instanceID == nil then
        castBarData.instanceID = string.sub(tostring(uiObject), 13, 19)
    end
    uiObject.tags = { "CAST", castBarData.instanceID }
    this.FormatData(uiObject)

    this.UIObjectSetup(uiObject)
end

local function EncounterAlertUIObjectSetup(encounterAlertData)
    local parentKey = groupers[encounterAlertData.grouper].UIObject.key

    local uiObject =
    {
        Child =
        {
            parentKey = parentKey,
        },
        EnabledState =
        {
            ValueHandler =
            {
                validKeys = { [2] = true },
            },
            ListenerGroup =
            {
                Listeners =
                {
                    {
                        eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                        inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                        value = 2,
                    },
                },
            },
        },
        EncounterAlert = {},
        Frame =
        {
            Dimensions = encounterAlertData.Dimensions
        },
        PriorityRank =
        {
            ValueHandler =
            {
                validKeys = { [0] = encounterAlertData.grouperPriority, }
            },
        },
        VisibleState =
        {
            ValueHandler =
            {
                validKeys = { [2] = true },
            },
            ListenerGroup =
            {
                Listeners =
                {
                    {
                        eventEvaluatorKey = "DBM_ANNOUNCEMENT_ELAPSED_TIME_CHANGED",
                        comparisonValues =
                        {
                            value = 2,
                            type = "LessThan",
                        },
                        value = 2,
                    },
                },
            },
        },
    }

    -- Key
    if encounterAlertData.instanceID == nil then
        encounterAlertData.instanceID = string.sub(tostring(uiObject), 13, 19)
    end
    uiObject.tags = { "ENCOUNTER_ALERT", encounterAlertData.instanceID }
    this.FormatData(uiObject)

    this.UIObjectSetup(uiObject)
end

local function TargetFrameUIObjectSetup(targetFrameData)
    local parentKey = groupers["TOP"].UIObject.key

    local uiObject =
    {
        Child =
        {
            parentKey = parentKey,
        },
        EnabledState =
        {
            ValueHandler =
            {
                validKeys = { [2] = true },
            },
            ListenerGroup =
            {
                Listeners =
                {
                    {
                        eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                        inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                        value = 2,
                    },
                },
            },
        },
        Frame =
        {
            Dimensions = targetFrameData.Dimensions
        },
        PriorityRank =
        {
            ValueHandler =
            {
                validKeys = { [0] = targetFrameData.grouperPriority, }
            },
        },
        TargetFrame =
        {
            unit = targetFrameData.unit,
        },
        VisibleState =
        {
            ValueHandler =
            {
                validKeys = { [0] = true },
            },
        },
    }

    -- Key
    if targetFrameData.instanceID == nil then
        targetFrameData.instanceID = string.sub(tostring(uiObject), 13, 19)
    end
    uiObject.tags = { "TARGET_FRAME", targetFrameData.instanceID }
    this.FormatData(uiObject)

    this.UIObjectSetup(uiObject)
end

function this:OnEvent(eventName, ...)
    if eventName == "ADDON_LOADED" then
        local addon = ...

        if addon == "TheEyeCore" then
            this.scale = _G["TheEyeAddonCharacterSettings"].UI.scale or TheEye.Core.Managers.Settings.Character.Default.UI.scale

            for k,v in pairs(groupers) do
                if v.Setup ~= nil then
                    v.Setup(v.UIObject)
                end
                GrouperUIObjectSetup(v.UIObject)
            end
        end
    else -- PLAYER_ENTERING_WORLD, PLAYER_SPECIALIZATION_CHANGED
        local newSpec = GetSpecializationInfo(GetSpecialization())
        if newSpec ~= playerSpec then
            playerSpec = newSpec
            
            if eventName == "PLAYER_SPECIALIZATION_CHANGED" then
                for k, module in pairs(this.Modules.IconGroups) do
                    local uiObject = this.Modules.IconGroups[k].UIObject
                    this.Modules.IconGroups[k].UIObject = nil
                    uiObject:Deactivate()
                    TheEye.Core.UI.Objects.Instances[uiObject.key] = nil
                end
            end

            for k, module in pairs(this.Modules.CastBars) do
                local moduleSettings = _G["TheEyeAddonCharacterSettings"].UI.Modules[module.type]
                if moduleSettings.enabled == true then
                    module.UIObject = CastBarUIObjectSetup(module)
                end
            end
    
            for k, module in pairs(this.Modules.EncounterAlerts) do
                local moduleSettings = _G["TheEyeAddonCharacterSettings"].UI.Modules[module.type]
                if moduleSettings.enabled == true then
                    module.UIObject = EncounterAlertUIObjectSetup(module)
                end
            end
    
            for k, module in pairs(this.Modules.IconGroups) do
                local moduleSettings = _G["TheEyeAddonCharacterSettings"].UI.Modules[module.type]
                if moduleSettings.enabled == true then
                    module.UIObject = IconGroupUIObjectSetup(module, moduleSettings.maxIcons)
                end
            end

            for k, module in pairs(this.Modules.TargetFrames) do
                local moduleSettings = _G["TheEyeAddonCharacterSettings"].UI.Modules[module.type]
                if moduleSettings.enabled == true then
                    module.UIObject = TargetFrameUIObjectSetup(module)
                end
            end
        end
    end
end