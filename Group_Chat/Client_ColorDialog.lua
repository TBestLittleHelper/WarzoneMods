function ColorPickerDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(410, 390)

    local colors = PossibleColors()
    local buttonsPerRow = 3

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horizontalLayout;

    for i, color in ipairs(colors) do
        if (i - 1) % buttonsPerRow == 0 then
            horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)
        end

        UI.CreateButton(horizontalLayout).SetText(color).SetColor(color)
            .SetPreferredWidth(100).SetOnClick(function()
            -- May be nill, if the parant dialog was closed
            if (GroupColorButton == nil) then
                close()
                return
            end
            GroupColorButton.SetColor(color)
            close()
        end)
    end
end
