require("Utilities")

local ClientGame;
function PlayerPickerDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(410, 390)
    print("create PlayerPickerDialog")

    ClientGame = game

    local players = Filter(game.Game.Players, IsPotentialTarget)
    local buttonsPerRow = 3

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horizontalLayout;

    for i, player in ipairs(players) do
        if (i - 1) % buttonsPerRow == 0 then
            horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)
        end

        local color = ClientGame.Game.Players[player.ID].Color.HtmlColor

        UI.CreateButton(horizontalLayout).SetText(
            ClientGame.Game.Players[player.ID].DisplayName(nil, false))
            .SetColor(color).SetPreferredWidth(100).SetOnClick(function()
            print(player.ID)

            -- Migth be nil, if parant dialog is closed
            if (SelectedPlayerButton == nil) then
                close()
                return
            end

            SelectedPlayerButton.SetText(displayName).SetColor(color)
            TargetPlayerID = player.ID
            close()
        end)
    end
end

-- Determins if the player is one we can interact with.
function IsPotentialTarget(player)
    if (ClientGame.Us.ID == player.ID) then return false end -- We can never add ourselves.

    if (player.State ~= WL.GamePlayerState.Playing) then return false end -- Skip players not alive anymore, or that declined the game.

    if (ClientGame.Settings.SinglePlayer) then return true end -- In single player, allow AI for testing

    return not player.IsAI -- In multi-player, never allow adding an AI.
end
