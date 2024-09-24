---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
    for settingsName, settingsConfig in pairs(SettingsTable) do
        if (settingsConfig.box ~= nil) then
            Mod.Settings[settingsName] = settingsConfig.box.GetIsChecked()
        else
            local num = settingsConfig.number.GetValue()
            if (num > settingsConfig.max) then
                num = settingsConfig.max
            else
                if (num < 0) then num = 0 end
            end
            Mod.Settings[settingsName] = num
        end
    end
end
