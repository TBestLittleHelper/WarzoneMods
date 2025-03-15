function Client_SaveConfigureUI(alert, addCard)
	Mod.Settings.NumPieces = 20;
	local cardWeight = 0;
	local minPieces = 0;
	local initialPieces = 0;

	local celebratingCardID = addCard("Celebrating",
		"Your territories are very happy. They will produce 20 extra income.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local happyCardID = addCard("Happy",
		"Your territories are happy. They will produce 5 extra income.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local contentCardID = addCard("Content",
		"People are content and there is no effect on your income.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, 21,
		cardWeight);
	local misserableCardID = addCard("Misserable",
		"People are misserable. You earn 10 less income.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);
	local riotingCardID = addCard("Rioting",
		"People are rioting. Your income is reduced by 50.",
		"Celebrating.png", Mod.Settings.NumPieces, minPieces, initialPieces,
		cardWeight);

	Mod.Settings.Cards = {
		Celebrating = { cardID = celebratingCardID, income = 20 }
		,
		Happy = { cardID = happyCardID, income = 5 },
		Content = { cardID = contentCardID, income = 0 },
		Misserable = { cardID = misserableCardID, income = -10 },
		Rioting = { cardID = riotingCardID, income = -50 },
	};
	Mod.Settings.AllCardIDs = {
		[celebratingCardID] = true,
		[happyCardID] = true,
		[contentCardID] = true,
		[misserableCardID] = true,
		[riotingCardID] = true
	}
end
