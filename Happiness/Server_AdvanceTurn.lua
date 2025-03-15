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
	-- Players can't play or dissmiss the card. The mod will handle it.
	if (order.proxyType == 'GameOrderPlayCardCustom') then
		if (Mod.Settings.AllCardIDs[order.CustomCardID] ~= nil) then
			skipThisOrder(WL.ModOrderControl
				.SkipAndSupressSkippedMessage)
		end
		return;
	end
	if (order.proxyType == "GameOrderDiscard") then
		-- todo check card type
		skipThisOrder(WL.ModOrderControl
			.SkipAndSupressSkippedMessage)
		print("discard card skip")
		Dump(order);
		print(order.CardInstanceID)
	end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
	print("card game")

	-- Give income based on happiness state
	for playerID, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		local cards = game.ServerGame.LatestTurnStanding.Cards[playerID].WholeCards
		for cardInstance, card in pairs(cards) do
			print(card.CardID)
			Dump(Mod.Settings.AllCardIDs)
			print(Mod.Settings.AllCardIDs[card.CardID])

			if (Mod.Settings.AllCardIDs[card.CardID]) then
				local income = CardIDtoIncome(card.CardID);
				print("income " .. income)
				Dump(card)
				-- Remove old card
				return;
			end
		end

		-- Give the new card
		print(playerID)
		local cardInstance = CreateCard();
		addNewOrder(WL.GameOrderReceiveCard.Create(playerID, cardInstance))
	end
end

function CreateCard()
	Dump(Mod.Settings.cards)
	local cardinstance = {} -- step 1
	table.insert(cardinstance, WL.NoParameterCardInstance.Create(1000000))
	return cardinstance
end

function CardIDtoIncome(cardID)
	for cardname, card in pairs(Mod.Settings.Cards) do
		if (card.cardID == cardID) then
			return card.income;
		end
	end
	return 0;
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
