TheEyeAddon.UI.Components.Icon = {}
local this = TheEyeAddon.UI.Components.Icon
local inherited = TheEyeAddon.UI.Components.FrameModifierBase

local DisplayerIDChange = TheEyeAddon.Managers.Icons.DisplayerIDChange
local TextureCreate = TheEyeAddon.UI.Factories.Texture.Create
local TextureFileIDGet = TheEyeAddon.Helpers.Files.TextureFileIDGet


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
    ValueHandler = nil
    ListenerGroup = nil
    iconObjectType = #ICON#TYPE#
    iconObjectID = #ICON#ID#
}
]]


--[[ SETUP
    instance
]]
function this.Setup(
    instance
)

	instance.ValueHandler = { validKeys = { [0] = true, } }

    instance.Modify = this.Modify
    instance.Demodify = this.Demodify

    inherited.Setup(
        instance,
        "background",
        "creator"
    )
end

function this:Modify(frame)
    frame.background = frame.background or TextureCreate(frame, "BACKGROUND")
    self.iconTextureFileID = self.iconTextureFileID or TextureFileIDGet(self.iconObjectType, self.iconObjectID)
    frame.background:TextureSet(self.iconTextureFileID)

    DisplayerChange(self.iconObjectID, self.UIObject.instanceID)
end

function this:Demodify(frame)
    frame.background:TextureSet(nil)

    DisplayerChange(self.iconObjectID, nil)
end