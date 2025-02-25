-- Saved variables
local addonName, addonTable = ...
local savedVariables = {
    showGuildTags = true,
    showPlayerNames = true,
    showPvPTitles = true,
    showOwnName = true,
}

-- Create main frame
local PTNe = CreateFrame("Frame", "MyPTN", UIParent, "BackdropTemplate")
PTNe:SetSize(200, 165)  -- Adjusted size for fewer checkboxes
PTNe:SetPoint("CENTER")
PTNe:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
PTNe:SetBackdropColor(0, 0, 0, 0.8)
PTNe:SetBackdropBorderColor(0, 0, 0)
PTNe:EnableMouse(true)
PTNe:SetMovable(true)
PTNe:RegisterForDrag("LeftButton")
PTNe:SetScript("OnDragStart", PTNe.StartMoving)
PTNe:SetScript("OnDragStop", PTNe.StopMovingOrSizing)
PTNe:Hide()

-- Create title text
local titleText = PTNe:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", 0, -10)
titleText:SetText("Player Title Names")
titleText:SetTextColor(1, 0.4, 0.8)  -- Pinkish-purple


-- Create close button
local closeButton = CreateFrame("Button", nil, PTNe)
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", PTNe, "TOPRIGHT", -5, -5)
closeButton:SetNormalTexture("Interface\\AddOns\\PlayerTitleNames\\close.png")

-- Set the close button to change color when mouseovered
closeButton:SetScript("OnEnter", function(self)
    self:GetNormalTexture():SetVertexColor(1, 0, 0)  -- Red
end)
closeButton:SetScript("OnLeave", function(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1)  -- White (original color)
end)

closeButton:SetScript("OnClick", function()
    PTNe:Hide()
end)

-- Load LibDBIcon-1.0
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("PlayerTitleNames", {
    type = "launcher",
    icon = "Interface\\AddOns\\PlayerTitleNames\\mmicon.png",  -- Updated icon path
    OnClick = function(self, button)
        if button == "LeftButton" then
            if PTNe:IsShown() then
                PTNe:Hide()
            else
                PTNe:Show()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Player Title Names")
        tooltip:AddLine("Left-click to toggle the main frame.")
    end,
})

local icon = LibStub("LibDBIcon-1.0")
local minimapButtonDB = {}

-- Create minimap button
icon:Register("PlayerTitleNames", LDB, minimapButtonDB)

-- Function to create checkboxes
local function CreateCheckbox(name, label, parent, x, y, variable, cvar, valueOn, valueOff)
    local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.Text:SetText(label)
    checkbox:SetChecked(savedVariables[variable])
    checkbox:SetScript("OnClick", function(self)
        savedVariables[variable] = self:GetChecked()
        if self:GetChecked() then
            self.Text:SetTextColor(1, 1, 0)  -- Yellow
            if cvar == "UnitNameOwn" then
                SetCVar(cvar, 1)
            else
                SetCVar(cvar, valueOn)
            end
        else
            self.Text:SetTextColor(0.5, 0.5, 0.5)  -- Gray
            if cvar == "UnitNameOwn" then
                SetCVar(cvar, 0)
            else
                SetCVar(cvar, valueOff)
            end
        end
    end)
    if checkbox:GetChecked() then
        checkbox.Text:SetTextColor(1, 1, 0)
        if cvar == "UnitNameOwn" then
            SetCVar(cvar, 1)
        else
            SetCVar(cvar, valueOn)
        end
    else
        checkbox.Text:SetTextColor(0.5, 0.5, 0.5)
        if cvar == "UnitNameOwn" then
            SetCVar(cvar, 0)
        else
            SetCVar(cvar, valueOff)
        end
    end
    return checkbox
end

-- Create checkboxes
local nameCheckbox = CreateCheckbox("NameCheckbox", "Show Player Names", PTNe, 10, -40, "showPlayerNames", "UnitNameFriendlyPlayerName", 1, 0)
local guildCheckbox = CreateCheckbox("GuildCheckbox", "Show Guild Tags", PTNe, 10, -70, "showGuildTags", "UnitNamePlayerGuild", 1, 0)
local pvpTitleCheckbox = CreateCheckbox("PvPTitleCheckbox", "Show PvP Titles", PTNe, 10, -100, "showPvPTitles", "UnitNamePlayerPVPTitle", 1, 0)
local ownNameCheckbox = CreateCheckbox("OwnNameCheckbox", "Show Own Name", PTNe, 10, -130, "showOwnName", "UnitNameOwn", 1, 0)

-- Slash command to toggle frame visibility
SLASH_PTN1 = "/ptn"
SlashCmdList["PTN"] = function()
    if PTNe:IsShown() then
        PTNe:Hide()
    else
        PTNe:Show()
    end
end

-- Event handler to load saved variables
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        -- Load saved variables
        if TitlesSavedVariables then
            savedVariables = TitlesSavedVariables
        else
            TitlesSavedVariables = savedVariables
        end
        -- Update checkbox states
        nameCheckbox:SetChecked(savedVariables.showPlayerNames)
        guildCheckbox:SetChecked(savedVariables.showGuildTags)
        pvpTitleCheckbox:SetChecked(savedVariables.showPvPTitles)
        ownNameCheckbox:SetChecked(savedVariables.showOwnName)
        
        -- Load minimap button position
        if TitlesSavedVariables.minimapButtonDB then
            minimapButtonDB = TitlesSavedVariables.minimapButtonDB
            icon:Refresh("PlayerTitleNames", minimapButtonDB)
        end
    end
end)

-- Save variables on logout
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGOUT" then
        TitlesSavedVariables = savedVariables
        TitlesSavedVariables.minimapButtonDB = minimapButtonDB
    end
end)
