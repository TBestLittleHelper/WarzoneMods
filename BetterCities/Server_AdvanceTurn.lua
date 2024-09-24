require("ModSettings")
require("Fog")

---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod ModServerHook

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
                                  addNewOrder) end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)

    if (Mod.Settings.UnfogCities) then
        for _, territoryID in pairs(Mod.PrivateGameData.Cities) do
            if (game.ServerGame.LatestTurnStanding.Territories[territoryID]
                .NumArmies.SpecialUnits == {}) then
                -- Create a new unit, if the old one is missing
                -- For example after combat
                local unit = CreateFogUnit()
                local addUnit = WL.TerritoryModification.Create(territoryID)
                addUnit.AddSpecialUnits = {unit}
                local orders = {addUnit}
                addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "News report from the city!",
                                                     {}, orders))
            end
        end

    end

   -- for _, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
   --     if (territory.NumArmies.SpecialUnits ~= nil) then
   --         local SpecialUnits = territory.NumArmies.SpecialUnits
   --         for key, value in pairs(SpecialUnits) do
   --             print(value.proxyType)
   --             print(value.ID)
--
   --             local removeUnit = WL.TerritoryModification.Create(territory.ID)
   --             removeUnit.RemoveSpecialUnitsOpt = {value.ID}
   --             local orders = {removeUnit}
   --             addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "",
   --                                                  {}, orders))
   --         end
   --     end
   -- end

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
