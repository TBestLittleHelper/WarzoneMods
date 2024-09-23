---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    UI.CreateLabel(rootParent).SetText("City Walls")
    UI.CreateCheckBox(rootParent)
    UI.CreateLabel(rootParent).SetText("Natural city growth")
    UI.CreateCheckBox(rootParent)

    UI.CreateLabel(rootParent).SetText("Bomb card damages cities")
    UI.CreateCheckBox(rootParent)

    UI.CreateLabel(rootParent).SetText("Wastland neutral cities")
    UI.CreateCheckBox(rootParent)

    UI.CreateLabel(rootParent).SetText("Extra armies when deploying in a city")
    UI.CreateCheckBox(rootParent)

    UI.CreateLabel(rootParent)
        .SetText("Deploy orders outside a city is skipped")
    UI.CreateCheckBox(rootParent)

end
