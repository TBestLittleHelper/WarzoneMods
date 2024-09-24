---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod
---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    if (Mod.Settings.wastelandNeutralCities) then

        ---@type table<EnumStructureType[]>
        local structure = {}
        Cities = WL.StructureType.City
        structure[Cities] = Mod.Settings.NumberOfStartingCities

        for _, territory in pairs(standing.Territories) do
            if (territory.IsNeutral) then
                if (territory.NumArmies.NumArmies == game.Settings.WastelandSize and
                    Mod.Settings.wastelandNeutralCities == true and
                    territory.IsNeutral == true) then
                    -- Wastelands starts with a city.
                    structure[Cities] = 2
                    territory.Structures = structure
                end
            end
        end

    end

end
