---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL

function Server_AdvanceTurn_Start(game, addNewOrder)

end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	-- Normal players orders can't play or dissmiss the card.
	if (order.proxyType == 'GameOrderPlayCardCustom') then
		if (Mod.Settings.AllCardIDs[order.CustomCardID] ~= nil) then
			skipThisOrder(WL.ModOrderControl
				.SkipAndSupressSkippedMessage)
		end
		return;
	end
	if (order.proxyType == "GameOrderDiscard") then
		-- todo check card type when supported https://www.warzone.com/Forum/816730-mod-incude-customcardid-discard-order
		skipThisOrder(WL.ModOrderControl
			.SkipAndSupressSkippedMessage)
	end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
	local standing = game.ServerGame.LatestTurnStanding;
	print("card game")

	-- Give income based on happiness card
	for playerID, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		local cards = standing.Cards[playerID].WholeCards
		local oldCardID = Mod.Settings.Cards.Content.cardID
		local oldCardPieces = 0;

		for cardInstance, card in pairs(cards) do
			if (Mod.Settings.AllCardIDs[card.CardID]) then
				oldCardID = card.CardID

				local income = CardIDtoIncome(card.CardID);
				local oldCardName = CardIDtoCardName(card.CardID);
				local msg = "Income from " .. oldCardName;
				local incomeMod = WL.IncomeMod.Create(playerID, income, msg)
				addNewOrder(WL.GameOrderEvent.Create(playerID, msg, nil, {}, nil,
					{ incomeMod }))

				-- Remove the old card and old card pices
				-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderEvent
				local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Removing old happiness cards", {});
				event.RemoveWholeCardsOpt = { [playerID] = cardInstance };

				oldCardPieces = standing.Cards[playerID].Pieces[oldCardID]
				event.AddCardPiecesOpt = { [playerID] = { [oldCardID] = -oldCardPieces } };
				addNewOrder(event);

				break;
			end
		end

		-- Calculate new happiness
		local happinessDelta = Mod.Settings.HappinessEachTurn;

		-- Take the old card pices. Add the change. Move down a level if neg. Move up a level if pos.
		local newHappiness = oldCardPieces + happinessDelta;

		-- Create new card pices. Plus add pieces for a "display" card.
		local newHappinessLevel = CardIDtoHappinessLevel(oldCardID);
		if (newHappiness < 0) then
			newHappinessLevel = newHappinessLevel - 1
		elseif (newHappiness > 100) then
			newHappinessLevel = newHappinessLevel + 1
		end

		local newCardEvent = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Adding new happiness card", {});
		local newCardID = HappinessLevelToCardID(newHappinessLevel);
		print(newCardID, "newCardID")

		local newPartialAndWholeCardPices = newHappiness + Mod.Settings.NumPieces;
		newCardEvent.AddCardPiecesOpt = { [playerID] = { [newCardID] = newPartialAndWholeCardPices } };
		addNewOrder(newCardEvent);
	end
end

function CardIDtoIncome(cardID)
	for _, card in pairs(Mod.Settings.Cards) do
		if (card.cardID == cardID) then
			return card.income;
		end
	end
	return 0;
end

function CardIDtoCardName(cardID)
	for cardname, card in pairs(Mod.Settings.Cards) do
		if (card.cardID == cardID) then
			return cardname;
		end
	end
	return "";
end

function CardIDtoHappinessLevel(cardID)
	print(cardID, "cardID")
	local cardIDToHappinessLevel = {
		[Mod.Settings.Cards.Celebrating.cardID] = 4,
		[Mod.Settings.Cards.Happy.cardID] = 3,
		[Mod.Settings.Cards.Content.cardID] = 2,
		[Mod.Settings.Cards.Miserable.cardID] = 1,
		[Mod.Settings.Cards.Rioting.cardID] = 0
	}
	return cardIDToHappinessLevel[cardID] or 0;
end

function HappinessLevelToCardID(happinessLevel)
	local happinessLevelToCardID = {
		[4] = Mod.Settings.Cards.Celebrating.cardID,
		[3] = Mod.Settings.Cards.Happy.cardID,
		[2] = Mod.Settings.Cards.Content.cardID,
		[1] = Mod.Settings.Cards.Miserable.cardID,
		[0] = Mod.Settings.Cards.Rioting.cardID
	}
	return happinessLevelToCardID[happinessLevel] or
		Mod.Settings.Cards.Rioting
		.cardID
end

function Dump(obj)
	if obj.proxyType ~= nil then
		DumpProxy(obj);
	elseif type(obj) == 'table' then
		DumpTable(obj);
	else
		print('Dump ' .. type(obj));
	end
end

function DumpTable(tbl)
	for k, v in pairs(tbl) do
		print('k = ' .. tostring(k) .. ' (' .. type(k) .. ') ' .. ' v = ' .. tostring(v) .. ' (' .. type(v) .. ')');
	end
end

function DumpProxy(obj)
	print('type=' ..
		obj.proxyType ..
		' readOnly=' ..
		tostring(obj.readonly) ..
		' readableKeys=' ..
		table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end
