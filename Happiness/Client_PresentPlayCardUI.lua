---Client_PresentPlayCardUI
---@param game GameClientHook
---@param cardInstance CardInstance # Read-only data about the card that the player is attempting to play
---@param playCard fun(orderListMessage: string, modData: string, turnPhase: EnumTurnPhase) # Function that when invoked, will make the player play the card
---@diagnostic disable-next-line: undefined-doc-param
function Client_PresentPlayCardUI(game, cardInstance, playCard, closeCardsDialog)
	Game = game;

	--If this dialog is already open, close the previous one. This prevents two copies of it from being open at once which can cause errors due to only saving one instance of TargetTerritoryBtn
	---@diagnostic disable-next-line: undefined-global
	if (Close ~= nil) then
		---@diagnostic disable-next-line: undefined-global
		Close();
	end
	playCard("You do not need to play this card. Happiness effect will still apply", "", WL.TurnPhase.ActiveCardWoreOff);
end
