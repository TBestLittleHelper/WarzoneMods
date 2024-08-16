function Alert(message, game)
    if (message == nil) then return false end
    local function AlertDialog(rootParent, setMaxSize, setScrollable, game,
                               close)
        setMaxSize(210, 150) -- This dialog's size
        local vert = UI.CreateVerticalLayoutGroup(rootParent)
        UI.CreateLabel(vert).SetText(message)
    end
    game.CreateDialog(AlertDialog)
    return true
end

