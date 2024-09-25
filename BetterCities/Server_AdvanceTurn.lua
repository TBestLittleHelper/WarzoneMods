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

        if (orderResult.IsAttack == false) then return end
        if (orderResult.ActualArmies == 0) then return end

        if (Mod.PrivateGameData.Cities[order.To]) then
            -- Don't trust the structures to exsist, or to be bigger then 0
            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures == nil) then return end
            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures[WL.StructureType.City] == nil) then
                return
            end

            if (game.ServerGame.LatestTurnStanding.Territories[order.To]
                .Structures[WL.StructureType.City] < 1) then return end

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
                print(extraDmg, " extraDmg")
                -- todo We need to dmg special units : https://www.warzone.com/wiki/Mod_API_Reference:GameOrderAttackTransferResult
                attackersKilled = orderResult.ActualArmies.NumArmies
            else
                -- round up, always
                attackersKilled = math.ceil(attackersKilled)
            end
            -- Write to GameOrderResult	 (result)
            local NewAttackingArmiesKilled = WL.Armies.Create(attackersKilled)
            orderResult.AttackingArmiesKilled = NewAttackingArmiesKilled
            local msg = "The city has " .. tostring(defBonus * 100) ..
                            "% fortification bonus. This killed " ..
                            attackersKilled .. " armies"
            addNewOrder(WL.GameOrderEvent.Create(game.ServerGame
                                                     .LatestTurnStanding
                                                     .Territories[order.To]
                                                     .OwnerPlayerID, msg,
                                                 {order.PlayerID}, nil))

        end

    else
        if (order.proxyType == "GameOrderDeploy") then
            if (Mod.Settings.DeployOrdersOutsideCitySkipped) then -- todo
                return
            end
            if (Mod.Settings.ExtraArmiesInCity) then
                -- todo
            end
        end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)

    if (Mod.Settings.UnfogCities) then
        local orders = {}
        for territoryID, _ in pairs(Mod.PrivateGameData.Cities) do
            local unfogUnitFound = false
            for _, unit in ipairs(
                               game.ServerGame.LatestTurnStanding.Territories[territoryID]
                                   .NumArmies.SpecialUnits) do
                if (unit.proxyType == "CustomSpecialUnit") then
                    ---@cast unit CustomSpecialUnit
                    if (unit.ModID == 758) then
                        unfogUnitFound = true
                        break
                    end
                end
            end
            if (unfogUnitFound == false) then
                -- Create a new unit, as the old one is missing
                -- For example after combat
                local unit = CreateFogUnit()
                local addUnit = WL.TerritoryModification.Create(territoryID)
                addUnit.AddSpecialUnits = {unit}
                table.insert(orders, addUnit)
            end
        end
        local next = next -- This is faster, then using global next
        if (next(orders) == nil) then return end
        -- todo if orders is not empty
        addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,
                                             "News report from all the cities!",
                                             {}, orders))
    end
end

function Dump(obj)
    if obj.proxyType ~= nil then
        DumpProxy(obj)
    elseif type(obj) == "table" then
        DumpTable(obj)
    else
        print("Dump " .. type(obj))
    end
end
function DumpTable(tbl)
    for k, v in pairs(tbl) do
        print("k = " .. tostring(k) .. " (" .. type(k) .. ") " .. " v = " ..
                  tostring(v) .. " (" .. type(v) .. ")")
    end
end
function DumpProxy(obj)
    print("type=" .. obj.proxyType .. " readOnly=" .. tostring(obj.readonly) ..
              " readableKeys=" .. table.concat(obj.readableKeys, ",") ..
              " writableKeys=" .. table.concat(obj.writableKeys, ","))
end
