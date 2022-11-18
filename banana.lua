local repo = 'https://raw.githubusercontent.com/gobboo/banana/main/'

local Library = loadstring(game:HttpGet(repo .. 'lib/lib.lua'))()
local Util = loadstring(game:HttpGet(repo .. 'lib/util.lua'))()
-- local Util = loadfile('minion/util.lua')()
-- local Library = loadfile('minion/lib.lua')()
-- local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
-- local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Banana Minion',
    Center = false,
    AutoShow = true,
})

local Tabs = {
    ['Dev'] = Window:AddTab("Dev"), 
    ['Settings'] = Window:AddTab('Settings'),
}

local DevLeftBox = Tabs.Dev:AddLeftGroupbox('Auto Mining')

-- Auto Mine
DevLeftBox:AddToggle('AutoMine', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Makes your minions mine the closest breakable.',
})

-- Auto Swing
DevLeftBox:AddToggle('AutoSwing', {
    Text = 'Auto Swing',
    Default = false,
    Tooltip = 'Automatically swings your pickaxe when you are near a breakable.',
})

-- Execute Closest
DevLeftBox:AddButton('Execute Closest', function()
    Util:BreakClosest()
end):AddTooltip('Breaks the Closest Breakable')

-- Drops
local DropsBox = Tabs.Dev:AddRightGroupbox('Drops')

DropsBox:AddToggle('AutoCollect', {
    Text = 'Auto Collect',
    Default = false, -- Default value (true / false)
    Tooltip = 'Auto collects all drops in the map.', -- Information shown when you hover over the toggle
})

DropsBox:AddButton('Collect All', function()
    Util:CollectAllDrops()
end):AddTooltip('Collects all drops in the map')

-- Chests
local ChestsBox = Tabs.Dev:AddRightGroupbox('Auto Chest')

ChestsBox:AddToggle('AutoOpen', {
    Text = 'Auto Open',
    Default = false, -- Default value (true / false)
    Tooltip = 'Opens chests in the background automagically :)', -- Information shown when you hover over the toggle
})

ChestsBox:AddToggle('SkipChest', {
    Text = 'Fast Open',
    Default = false, -- Default value (true / false)
    Tooltip = 'Opens up the Chests faster, we don\'t play an animation regardless. ( Requires Skip Gamepass )', -- Information shown when you hover over the toggle
})

ChestsBox:AddToggle('TripleChests', {
    Text = 'x3 Chests',
    Default = false, -- Default value (true / false)
    Tooltip = 'Opens 3 Chests at once ( Requires x3 Gamepass )', -- Information shown when you hover over the toggle
})

ChestsBox:AddDropdown('AutoDelete', {
    Values = { 'Common', 'Uncommon', 'Rare', 'Epic' },
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Auto Delete',
    Tooltip = 'Select what rarity to auto delete', -- Information shown when you hover over the textbox
})

ChestsBox:AddDropdown('ChestOptions', {
    Values = Util:GetChestNames(),
    Default = 1, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Chest',
    Tooltip = 'Select your chests to open', -- Information shown when you hover over the textbox
})


ChestsBox:AddButton('Open Chest', function()
    Util:OpenChests()
end):AddTooltip('Opens the a chest')

-- Listeners

Toggles.TripleChests:OnChanged(function()
    Util:UpdateChestSettings('ChestSettings', 'TripleChest', Toggles.TripleChests.Value)
end)

Toggles.SkipChest:OnChanged(function()
    Util:UpdateChestSettings('ChestSettings', 'Skip', Toggles.SkipChest.Value)
end)

Options.ChestOptions:OnChanged(function()
    local chestsToOpen = {}

    for key, value in next, Options.ChestOptions.Value do
        warn(key, value)
        if value then
            chestsToOpen[#chestsToOpen + 1] = key
        end
    end

    Util:UpdateChestsToOpen(chestsToOpen)
end)

Options.AutoDelete:OnChanged(function()
    local autoDelete = {
        ['Common'] = false,
        ['Uncommon'] = false,
        ['Rare'] = false,
        ['Epic'] = false,
    }

    for key, value in next, Options.AutoDelete.Value do
        if value then
            autoDelete[key] = true
        end
    end
    
    -- Update the auto delete settings
    for key, value in next, autoDelete do
        Util:UpdateChestSettings('AutoDelete', key, value)
    end
end)


-- MISCALLANEOUS --
Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end) 
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu


-- ThemeManager:SetLibrary(Library)
-- SaveManager:SetLibrary(Library)

-- SaveManager:IgnoreThemeSettings() 

-- SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

-- ThemeManager:SetFolder('banana')
-- SaveManager:SetFolder('banana/minion-simulator')

-- -- SaveManager:BuildConfigSection(Tabs['Settings']) 

-- ThemeManager:ApplyToTab(Tabs['Settings'])


-- Update Thread
task.spawn(function()
    while true do
        task.wait(0.1)
        if Library.Unloaded then break end

        local autoChest = Toggles.AutoOpen.Value
        if autoChest then
            Util:OpenChests()
        end

        local AutoCollect = Toggles.AutoCollect.Value
        if AutoCollect then
            Util:CollectAllDrops()
        end

        local autoMine = Toggles.AutoMine.Value
        if autoMine then
            Util:BreakClosest()
        end

        local autoSwing = Toggles.AutoSwing.Value
        if autoSwing then
            Util:SwingPickaxe()
        end
    end
end)
