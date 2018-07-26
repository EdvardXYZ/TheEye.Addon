TheEyeAddon.UI.Components.Elements.ValueHandlers.ValueChangeNotifier = {}
local this = TheEyeAddon.UI.Components.Elements.ValueHandlers.ValueChangeNotifier
local inherited = TheEyeAddon.UI.Components.Elements.ValueHandlers.Base


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}
]]


--[[ #SETUP#
    instance
    uiObject                    UIObject
    valueChangeListener         { function #valueChangeFunctionName#(#VALUE#) }
    valueChangeFunctionName     #STRING#
]]
function this.Setup(
    instance,
    uiObject,
    valueChangeListener,
    valueChangeFunctionName
)

    inherited.Setup(
        instance,
        uiObject,
        nil,
        nil,
        nil,
        this.OnValueChange,
        false
    )

    instance.ValueChangeListener = valueChangeListener
    instance.valueChangeFunctionName = valueChangeFunctionName
end

function this:OnValueChange(value)
    self.ValueChangeListener[self.valueChangeFunctionName](self.ValueChangeListener, value)
end