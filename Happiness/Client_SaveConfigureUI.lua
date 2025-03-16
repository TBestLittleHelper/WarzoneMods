function Client_SaveConfigureUI(alert, addCard)
	Mod.Settings.NumPieces = 100; -- Must be 1 or greater
	local cardWeight = 0;
	local minPieces = 0;
	local initialPieces = 0;

	local celebratingCardID = addCard("Celebrating",
		"Your territories are very happy. They will produce 20 extra income.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local happyCardID = addCard("Happy",
		"Your territories are happy. They will produce 5 extra income.",
		"Happy.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local contentCardID = addCard("Content",
		"People are content and there is no effect on your income.",
		"Content.png", Mod.Settings.NumPieces, minPieces, Mod.Settings.NumPieces,
		cardWeight);
	local MiserableCardID = addCard("Miserable",
		"People are Miserable. You earn 10 less income.",
		"Miserable.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local riotingCardID = addCard("Rioting",
		"People are rioting. Your income is reduced by 50.",
		"Rioting.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);

	Mod.Settings.Cards = {
		Celebrating = { cardID = celebratingCardID, income = 20 }
		,
		Happy = { cardID = happyCardID, income = 5 },
		Content = { cardID = contentCardID, income = 0 },
		Miserable = { cardID = MiserableCardID, income = -10 },
		Rioting = { cardID = riotingCardID, income = -50 },
	};
	Mod.Settings.AllCardIDs = {
		[celebratingCardID] = true,
		[happyCardID] = true,
		[contentCardID] = true,
		[MiserableCardID] = true,
		[riotingCardID] = true
	}
	Mod.Settings.HappinessEachTurn = -5;
end
