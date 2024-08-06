require("Utilities")

function Server_AdvanceTurn_End(game, addNewOrder)
    -- Add a turn 'chat' msg to show that a turn advanced in chat
    TurnDivider(game.Game.NumberOfTurns)
end

function TurnDivider(turnNumber)
    local playerGameData = Mod.PlayerGameData
    local ChatArrayIndex

    local ChatInfo = {}
    ChatInfo.Sender = -1 -- The Mod is the sender
    ChatInfo.Chat = " ------ End of turn " .. turnNumber + 1 .. " ------"

    -- For All playerGameData.Chat
    for playerID, _ in pairs(playerGameData) do
        -- For ALL groups
        if (playerGameData[playerID].Chat ~= nil) then
            for TargetGroupID, _ in pairs(playerGameData[playerID].Chat) do
                -- ADD a turn chat
                if (playerGameData[playerID].Chat[TargetGroupID] == nil) then
                    ChatArrayIndex = 1
                else
                    ChatArrayIndex =
                        #playerGameData[playerID].Chat[TargetGroupID] + 1
                end
                playerGameData[playerID].Chat[TargetGroupID].NumChat =
                    ChatArrayIndex
                playerGameData[playerID].Chat[TargetGroupID][ChatArrayIndex] =
                    {}
                playerGameData[playerID].Chat[TargetGroupID][ChatArrayIndex] =
                    ChatInfo
            end
        end
    end
    -- Save playerGameData
    Mod.PlayerGameData = playerGameData
end
