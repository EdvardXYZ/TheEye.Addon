TheEyeAddon.UI.Objects:Add(
{
    priority = nil,
    tags = { "HUD", "ICON", "PRIMARY", "SPELL-15407" },
    DisplayData =
    {
        factory = TheEyeAddon.UI.Factories.Icon,
        parentKey = "GROUP_HUD_MODULE_PRIMARY",
        dimensionTemplate = TheEyeAddon.UI.DimensionTemplates.Icon_Large,
        iconObjectType = "SPELL",
        iconObjectID = 15407,
        fontTemplate = TheEyeAddon.UI.Fonts.Templates.Icon.default
    },
    ListenerGroups =
    {
        Enabled =
        {
            type = "STATE",
            OnValidKey = TheEyeAddon.UI.Objects.Enable,
            OnInvalidKey = TheEyeAddon.UI.Objects.Disable,
            validKeys = { [2] = true },
            ListeningTo =
            {
                UIObject_Visible =
                {
                    keyValue = 2,
                    inputValues = { --[[uiObjectKey]] "GROUP_HUD_MODULE_PRIMARY" }
                }
            }
        },
        Visible =
        {
            type = "STATE",
            OnValidKey = TheEyeAddon.UI.Objects.Show,
            OnInvalidKey = TheEyeAddon.UI.Objects.Hide,
            validKeys = { [0] = true, [4] = true, [6] = true },
            ListeningTo =
            {
                Unit_Spellcast_Active =
                {
                    keyValue = 2,
                    inputValues = { --[[unit]] "player", --[[spellID]] 15407 }
                },
                Unit_Spellcast_CastRecently =
                {
                    keyValue = 4,
                    inputValues = { --[[unit]] "player", --[[spellID]] 15407 }
                }
            }
        }
    }
}
)