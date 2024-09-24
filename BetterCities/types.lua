---@alias settingsName string -- Name of the setting
---@alias boxInput CheckBox  -- UI CheckBox
---@alias numberInput NumberInputField -- UI NumberInput

---@class UiElementWithBox
---@field isBox boolean  -- When true, the element is a box.

---@class UiElementWithoutBox
---@field isBox boolean  -- When false, the element is not a box.
---@field max number     -- Maximum value, only if isBox is false.
---@field initial number -- Initial value, only if isBox is false.

---@alias configureUiElement UiElementWithBox | UiElementWithoutBox
-- todo enum for settings names
