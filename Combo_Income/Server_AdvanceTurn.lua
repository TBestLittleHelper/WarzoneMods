---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---@alias CurrentCombo integer  -- Current combo count
---@alias BestCombo integer -- Best combo this round
---@type table<PlayerID, {current: CurrentCombo, best: BestCombo}>  -- A table where keys are integers and values are PlayerID
local combo = {}

---Server_AdvanceTurn_Start hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Start(game, addNewOrder)
    for playerID, _ in pairs(game.Game.PlayingPlayers) do
        combo[playerID] = {current = 0, best = 0}
    end
end

---Server_AdvanceTurn_Order hook
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder,
                                  addNewOrder)
    if order.proxyType == "GameOrderAttackTransfer" then
        ---@cast orderResult GameOrderAttackTransferResult
        if not orderResult.IsAttack then return end
        if orderResult.IsSuccessful then
            combo[order.PlayerID].current = combo[order.PlayerID].current + 1
            if combo[order.PlayerID].current > combo[order.PlayerID].best then
                combo[order.PlayerID].best = combo[order.PlayerID].current
            end
        else
            combo[order.PlayerID].current = 0
        end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)

    ---@param playerID PlayerID
    ---@param comboScore CurrentCombo
    for playerID, comboScore in pairs(combo) do
        if comboScore.best < 2 then return end
        local msg = "Bonus income from a combo of : " .. comboScore.best

        local bonusIncome = BonusIncome(comboScore.best)
        local comboIncomeMod = WL.IncomeMod.Create(playerID, bonusIncome, msg)
        addNewOrder(WL.GameOrderEvent.Create(playerID, msg, nil, {}, nil,
                                             {comboIncomeMod}))
    end
end

---Calculate a bonus from a score
---@param bestCombo BestCombo
---@return integer # Bonus Income
function BonusIncome(bestCombo)
    if bestCombo > 9 then return 10 end
    if bestCombo > 4 then return 5 end
    return 1
end
