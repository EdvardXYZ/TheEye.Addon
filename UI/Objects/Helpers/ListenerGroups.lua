local TheEyeAddon = TheEyeAddon
TheEyeAddon.UI.Objects.ListenerGroups = {}


-- Setup
function SetupListener(uiObject, listenerGroup, listener, evaluatorName, OnEvaluate)
    listener.uiObject = uiObject
    listener.listenerGroup = listenerGroup
    listener.OnEvaluate = OnEvaluate
    TheEyeAddon.Events.Evaluators:RegisterListener(evaluatorName, listener)
end

function TheEyeAddon.UI.Objects.ListenerGroups:SetupListeningTo(uiObject, listenerGroup, listeningTo, OnEvaluate)
    for evaluatorName,v in pairs(listeningTo) do
        local listener = listenerGroup.ListeningTo[evaluatorName]
        SetupListener(uiObject, listenerGroup, listener, evaluatorName, OnEvaluate)
    end
end

function TheEyeAddon.UI.Objects.ListenerGroups:SetupGroupsOfType(uiObject, groupType)
    for i,listenerGroup in ipairs(uiObject.ListenerGroups) do
        if listenerGroup.type == groupType then
            SetupListeningTo(uiObject, listenerGroup, listenerGroup.ListeningTo, listenerGroup.OnEvaluate)
        end
    end
end


-- Teardown
function TheEyeAddon.UI.Objects.ListenerGroups:TeardownGroup(listenerGroup)
    for evaluatorName,v in pairs(listenerGroup.ListeningTo) do
        local listener = listenerGroup.ListeningTo[evaluatorName]
        TheEyeAddon.Events.Evaluators:UnregisterListener(evaluatorName, listener)
    end
end


-- OnEvaluate: EVENT
function TheEyeAddon.UI.Objects.ListenerGroups:RegisterChild(event, uiObject)
    if self.uiObject.Children == nil then
        self.uiObject.Children = { uiObject }
    else
        table.insert(self.uiObject.Children, uiObject)
    end
end

function TheEyeAddon.UI.Objects.ListenerGroups:SortChildrenByPriority(state, event, uiObject)
    table.sort(uiObject.Children, function(a,b)
        return a.ListenerGroups.Priority.combinedKeyValue > b.ListenerGroups.Priority.combinedKeyValue end) 
end


-- OnEvaluate: STATE
function TheEyeAddon.UI.Objects.ListenerGroups:ChangeValueByState(state)
    if state == true then
        self.uiObject.ValueHandlers[self.listenerGroup.valueHandlerKey]:ChangeValue(self.value)
    else
        self.uiObject.ValueHandlers[self.listenerGroup.valueHandlerKey]:ChangeValue(self.value * -1)
    end
end