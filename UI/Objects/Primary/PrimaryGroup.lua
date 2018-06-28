TheEyeAddon.UI.Objects:Add(
{
    tags = { "GROUP", "HUD", "MODULE", "PRIMARY" },
    DisplayData =
    {
        factory = TheEyeAddon.UI.Factories.Group,
        parentKey = "GROUP_UIPARENT",
        dimensionTemplate =
        {
            width = 0,
            height = 0,
            point = "TOP",
            relativePoint = "CENTER",
            offsetX = 0,
            offsetY = -50,
        }
    },
    StateGroups =
    {
        Enabled =
        {
            OnValidKey = TheEyeAddon.UI.Objects.Enable,
            OnInvalidKey = TheEyeAddon.UI.Objects.Disable,
            validKeys = { [6] = true },
            Listeners =
            {
                Setting_Module_Enabled =
                {
                    keyValue = 2,
                    inputValues = { --[[uiObjectKey]] "GROUP_HUD_MODULE_PRIMARY" }
                },
                UIObject_Visible =
                {
                    keyValue = 4,
                    inputValues = { --[[uiObjectKey]] "GROUP_UIPARENT" }
                }
            }
        },
        Visible =
        {
            OnValidKey = TheEyeAddon.UI.Objects.Show,
            OnInvalidKey = TheEyeAddon.UI.Objects.Hide,
            validKeys = { [2] = true },
            Listeners =
            {
                Unit_CanAttack_Unit =
                {
                    keyValue = 2,
                    inputValues = { --[[attackerUnit]] "player", --[[attackedUnit]] "target" }
                }
            }
        }
    }
}
)