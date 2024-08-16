require("Server_GameData")

-- Called in any game set to manual territory distribution, before players select their picks. This hook is not called in any game configured to automatic territory distribution.
-- Duplicates Server_StartGame, but makes the chat work during manual picks. So unavoidable.
function Server_StartDistribution(game, standing) GameDataSetup(game) end
