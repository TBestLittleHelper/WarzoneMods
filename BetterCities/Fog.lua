---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---Creates a WL.TerritoryModification to remove fog using a special unit.
---@param territoryID TerritoryID
function RemoveTerritoryFogMod(territoryID, unitID)
    local TerrModRemoveFog = WL.TerritoryModification.Create(territoryID)
    TerrModRemoveFog.RemoveSpecialUnitsOpt = {unitID}
    return TerrModRemoveFog
end

---Creates a WL.TerritoryModification to add fog using a special unit.
---@param territoryID TerritoryID
function AddTerritoryFogMod(territoryID)

    local TerrModAddFog = WL.TerritoryModification.Create(territoryID)
    local unit = CreateFogUnit()
    TerrModAddFog.AddSpecialUnits = {unit}
    return TerrModAddFog
end

function CreateFogUnit()
    ---@type CustomSpecialUnitBuilder
    local builder = WL.CustomSpecialUnitBuilder.Create(WL.PlayerID.Neutral);
    builder.Name = "";
    builder.IncludeABeforeName = false;
    builder.ImageFilename = 'empty.png';
    builder.AttackPower = 0;
    builder.DefensePower = 0;
    builder.DamageToKill = 0;
    builder.DamageAbsorbedWhenAttacked = 0;
    builder.CombatOrder = 9999;
    builder.CanBeGiftedWithGiftCard = false;
    builder.CanBeTransferredToTeammate = false;
    builder.CanBeAirliftedToSelf = false;
    builder.CanBeAirliftedToTeammate = false;
    builder.IsVisibleToAllPlayers = true;

    local built = builder.Build() -- Do this to help the type annotations work
    return built
end
