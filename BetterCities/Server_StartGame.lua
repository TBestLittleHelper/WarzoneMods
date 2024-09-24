require("Fog")

---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod ModServerHook
---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    PrivateGameData = Mod.PrivateGameData
    PrivateGameData.Cities = {}
    if (Mod.Settings.wastelandNeutralCities) then
        ---@type table<EnumStructureType[]>
        local structure = {}
        Cities = WL.StructureType.City
        structure[Cities] = Mod.Settings.NumberOfStartingCities

        for _, territory in pairs(standing.Territories) do
            if (territory.IsNeutral) then
                if (territory.NumArmies.NumArmies == game.Settings.WastelandSize and
                    territory.IsNeutral == true) then
                    -- Wastelands starts with 2 cities.
                    structure[Cities] = 2
                    territory.Structures = structure

                    if (Mod.Settings.UnfogCities) then
                        local unit = CreateFogUnit()
                        local unitArray = {unit}
                        territory.NumArmies = WL.Armies.Create(
                                                  territory.NumArmies.NumArmies,
                                                  unitArray)
                    end
                    table.insert(PrivateGameData.Cities, territory.ID)
                end
            end
        end
    end
    Mod.PrivateGameData = PrivateGameData
end
