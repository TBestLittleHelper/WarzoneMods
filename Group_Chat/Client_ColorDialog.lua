function ColorPickerDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(410, 390) -- This dialog's size

    local colors = PossibleColors()

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    for _, color in ipairs(colors) do UI.CreateLabel(vert).SetText(color) end
end
