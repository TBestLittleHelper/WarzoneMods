---@alias ComboCounter integer  -- Alias for integer representing a combo count
---@type table<PlayerID, ComboCounter>  -- A table where keys are integers and values are PlayerID
local combo = {}

---Server_AdvanceTurn_Start hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Start(game, addNewOrder)
    for playerID, _ in pairs(game.Game.PlayingPlayers) do combo[playerID] = 0 end
end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder,
                                  addNewOrder) end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
    ---@param playerID PlayerID
    ---@param comboScore ComboCounter
    for playerID, comboScore in pairs(combo) do
        WL.IncomeMod.Create(playerID, comboScore,
                            "Additional income from combo score")
    end
end
