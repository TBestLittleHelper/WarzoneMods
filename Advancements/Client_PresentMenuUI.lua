function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	---@type UI UI
	UI = UI
	local vert = UI.CreateVerticalLayoutGroup(rootParent)
	local horz = UI.CreateHorizontalLayoutGroup(vert)

	UI.CreateButton(horz).SetText("Economy").SetColor("#FFAA00").SetOnClick(function()
		ShowEconomyMenuUI()
    end)
	UI.CreateButton(horz).SetText("Culture").SetColor("FF7E015A").SetOnClick(function()
		UI.Alert("Not implemented yet.")
    end)
	UI.CreateButton(horz).SetText("Armies").SetColor("FFF10505").SetOnClick(function()
		UI.Alert("Not implemented yet.")
	end)
end

ShowEconomyMenuUI = function()
	--TODO
	UI.Alert("todo")
end
