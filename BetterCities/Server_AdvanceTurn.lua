require("ModSettings")
require("Fog")

---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod ModServerHook | ModSettings

---Server_AdvanceTurn_Start hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Start(game, addNewOrder) end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder,
                                  addNewOrder)
    if (order.proxyType == "GameOrderAttackTransfer") then
        ---@cast orderResult GameOrderAttackTransferResult
        ---@cast order GameOrderAttackTransfer
        if (Mod.PrivateGameData.Cities[order.To]) then
            -- Don't trust the structures to exsist, or to be bigger then 0
            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures == nil) then return end
            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures[WL.StructureType.City] == nil) then
                return
            end
            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures[WL.StructureType.City] > 0) then return end

            local defBonus =
                game.ServerGame.LatestTurnStanding.Territories[order.To]
                    .Structures[WL.StructureType.City] *
                    (Mod.Settings.CityWalls * 0.01)
            local attackersKilled =
                orderResult.AttackingArmiesKilled.NumArmies +
                    orderResult.AttackingArmiesKilled.NumArmies * defBonus

            -- Minimum kill 1 attacking army
            if (attackersKilled == 0) then
                -- Max armies lost is equal to actualArmies
                attackersKilled = 1
            elseif (orderResult.ActualArmies.NumArmies - attackersKilled < 0) then
                local extraDmg = attackersKilled -
                                     orderResult.ActualArmies.NumArmies
                orderResult.DamageToSpecialUnits =
                    orderResult.DamageToSpecialUnits + extraDmg
                attackersKilled = orderResult.ActualArmies.NumArmies
            else
                -- round up, always
                attackersKilled = math.ceil(attackersKilled)
            end
            -- Write to GameOrderResult	 (result)
            local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled)
            orderResult.AttackingArmiesKilled = NewAttackingArmiesKilled
            local msg = "The city has " .. tostring(defBonus * 100) ..
                            "% fortification bonus"

            addNewOrder(WL.GameOrderEvent.Create(game.ServerGame
                                                     .LatestTurnStanding
                                                     .Territories[order.To]
                                                     .OwnerPlayerID, msg,
                                                 {order.PlayerID}, nil))

        end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)

    if (Mod.Settings.UnfogCities) then
        for _, territoryID in pairs(Mod.PrivateGameData.Cities) do
            local unfogUnitFound = false
            for _, unit in ipairs(
                               game.ServerGame.LatestTurnStanding.Territories[territoryID]
                                   .NumArmies.SpecialUnits) do
                if (unit.proxyType == "CustomSpecialUnit") then
                    ---@cast unit CustomSpecialUnit
                    if (unit.ModID == 758) then
                        unfogUnitFound = true
                        print("unfogUnitFound found ", territoryID, " turn ",
                              game.Game.NumberOfLogicalTurns)
                        break
                    end
                end
            end
            if (unfogUnitFound) then return end

            print("unfogUnit missing ", territoryID)

            -- Create a new unit, as the old one is missing
            -- For example after combat
            local unit = CreateFogUnit()
            local addUnit = WL.TerritoryModification.Create(territoryID)
            addUnit.AddSpecialUnits = {unit}
            local orders = {addUnit}
            addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,
                                                 "News report from the city!",
                                                 {}, orders))

        end
    end
end
