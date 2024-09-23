---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)

    for key, value in pairs(SettingsTable) do
        print(key)
        Dump(value)
        print(value.box.GetIsChecked())
        Mod.Settings[key] = value.box.GetIsChecked()
    end
end

function Dump(obj)
    if obj.proxyType ~= nil then
        DumpProxy(obj)
    elseif type(obj) == "table" then
        DumpTable(obj)
    else
        print("Dump " .. type(obj))
    end
end
function DumpTable(tbl)
    for k, v in pairs(tbl) do
        print("k = " .. tostring(k) .. " (" .. type(k) .. ") " .. " v = " ..
                  tostring(v) .. " (" .. type(v) .. ")")
    end
end
function DumpProxy(obj)
    print("type=" .. obj.proxyType .. " readOnly=" .. tostring(obj.readonly) ..
              " readableKeys=" .. table.concat(obj.readableKeys, ",") ..
              " writableKeys=" .. table.concat(obj.writableKeys, ","))
end
