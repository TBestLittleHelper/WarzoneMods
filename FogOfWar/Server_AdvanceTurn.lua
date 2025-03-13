---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL

---@type table<targetID>
local TerritoriesAttacked = {}

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
        ---@cast order GameOrderAttackTransfer
        if orderResult.IsAttack then
            TerritoriesAttacked[order.To] = true
            print(game.Map.Territories[order.To].Name .. " is attacked")
            print(order.proxyType, order.PlayerID)
            return
        end
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
    PrivateGameData = Mod.PrivateGameData
    ---@alias Duration integer  -- Remaining turns of fog
    ---@alias targetID TerritoryID -- The territoriy that is fogged
    ---@alias Id string|nil -- Guid: Automatically generated and guaranteed to be unique for every FogMod instance created.
    ---@type table<targetID, {duration: Duration, id: Id}>  -- All the fogged territories
    local FoggedTerritories = PrivateGameData.FoggedTerritories or {};

    local TerritoriesToBeFogged = {}
    local TerritoriesToRemoveFog = {}

    print("End turn start")

    -- Spend 1 duration for fogged territories
    for targetID, info in pairs(FoggedTerritories) do
        FoggedTerritories[targetID].duration = info.duration - 1

        if FoggedTerritories[targetID].duration <= 0 then
            table.insert(TerritoriesToRemoveFog, targetID)
        end
    end

    -- Add fog duration to attacked territories
    for targetID, _ in pairs(TerritoriesAttacked) do
        print(targetID, game.Map.Territories[targetID].Name)
        if FoggedTerritories[targetID] == nil then
            table.insert(TerritoriesToBeFogged, targetID)
        else
            FoggedTerritories[targetID].duration = FoggedTerritories[targetID].duration + 1
        end
    end

    print("************")
    -- Update fogged
    -- Wiki ref : https://www.warzone.com/wiki/Mod_API_Reference:FogMod

    for _, targetID in pairs(TerritoriesToBeFogged) do
        print(game.Map.Territories[targetID].Name .. " is being fogged")
        local fogMod = CreateFog(targetID)
        FoggedTerritories[targetID] = { duration = 2, id = fogMod.ID }
        local msg = "Fog in " .. game.Map.Territories[targetID].Name
        local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg, {});
        event.FogModsOpt = { fogMod };
        addNewOrder(event);
    end

    print("done adding new fog")
    for _, targetID in pairs(TerritoriesToRemoveFog) do
        local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Fog of War has ended', {});
        event.RemoveFogModsOpt = { FoggedTerritories[targetID].id };
        addNewOrder(event);
        FoggedTerritories[targetID] = nil
    end
    print("done removing fog")

    PrivateGameData.FoggedTerritories = FoggedTerritories
    Mod.PrivateGameData = PrivateGameData;
end

function CreateFog(targetID)
    local message = "Hidden by fog of War"
    local fogLevel = WL.StandingFogLevel.OwnerOnly
    local priority = 6316

    local fogMod = WL.FogMod.Create(message, fogLevel, priority, { targetID }, nil);
    print("add fog " .. fogMod.ID);
    return fogMod;
end
