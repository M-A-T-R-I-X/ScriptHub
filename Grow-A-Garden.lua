local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "Mat-Rix Hub",
    SubTitle = "Grow A Garden 1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
	Transparency = true,
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Seed = Window:AddTab({ Title = "Seed", Icon = "glass" }), 
    Gear = Window:AddTab({ Title = "Gears", Icon = "arrow-up" }), 
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
do
Fluent:Notify({
    Title = "Notifications",
    Content = "Discord Server Have Copied!",
    SubContent = "SubContent", -- Optional
    Duration = 5 -- Set to nil to make the notification not disappear
})

Tabs.Main:AddParagraph({
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})

Tabs.Main:AddButton({
     Title = "Button",
     Description = "Very important button",
     Callback = function()
     Window:Dialog({
     Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            print("Confirmed the dialog.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
     end
})




    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value)
            print("Slider was changed:", Value)
        end
    })

    Slider:OnChanged(function(Value)
        print("Slider changed:", Value)
    end)

    Slider:SetValue(3)

local enabled = false
local selected = "Fastest"
local gayposition = nil
local Toggle = Tabs.Farm:AddToggle("Auto Harvest", {
    Title = "Auto Harvest",
    Description = "Automatically Harvest You Farm",
    Default = false,
    Callback = function(Value)
        enabled = Value
    end
})
local Dropdown = Tabs.Farm:AddDropdown("Dropdown", {
    Title = "Harvest",
    Values = {"Fastest", "Slow", "Fast"},
    Default = 1,
    Callback = function(Value)
        selected = Value
    end
})
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    return char, humanoid, root
end
local function harvest(seconds)
    local endTime = tick() + seconds
    while tick() < endTime and enabled do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.1)
    end
end
local function lastpos(targetPosition, radius)
    if gayposition == nil then
        return false
    end
    return (targetPosition - gayposition).Magnitude < radius
end
task.spawn(function()
    while true do
        if enabled and (selected == "Slow" or selected == "Fast") then
            local farmsFolder = workspace:FindFirstChild("Farm")
            if farmsFolder then
                for _, farm in ipairs(farmsFolder:GetChildren()) do
                    if farm:IsA("Folder") and farm.Name == "Farm" then
                        local important = farm:FindFirstChild("Important")
                        if important then
                            local data = important:FindFirstChild("Data")
                            local owner = data and data:FindFirstChild("Owner")
                            if owner and owner:IsA("StringValue") and owner.Value == player.Name then
                                local plantsFolder = important:FindFirstChild("Plants_Physical")
                                if plantsFolder then
                                    local plants = plantsFolder:GetChildren()
                                    if #plants > 0 then
                                        local target = plants[math.random(1, #plants)]
                                        local pos
                                        if target:IsA("BasePart") then
                                            pos = target.Position
                                        elseif target:IsA("Model") and target.PrimaryPart then
                                            pos = target.PrimaryPart.Position
                                        end
                                        if pos then
                                            if lastpos(pos, 10) then
                                                continue
                                            end
                                            if selected == "Slow" then
                                                local _, humanoid = getCharacter()
                                                humanoid:MoveTo(pos)
                                                task.wait(1)
                                                task.spawn(function()
                                                    harvest(3)
                                                end)
                                            elseif selected == "Fast" then
                                                local _, humanoid = getCharacter()
                                                humanoid.RootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                                                task.wait(0.01)
                                                task.spawn(function()
                                                    harvest(3)
                                                end)
                                                lastTeleportPosition = pos
                                            end

                                            task.wait(0.7)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
RunService.RenderStepped:Connect(function()
    if enabled and selected == "Fastest" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)

local Toggle = Tabs.Farm:AddToggle("Auto Plant", {
    Title = "Auto Plant",
    Description = "Auto Plant Selected Seed",
    Default = false
})
shared.selectedSeed = "Carrot"
local Dropdown = Tabs.Farm:AddDropdown("Dropdown", { 
    Title = "Auto Plant Seed", 
    Description = "Select The Seed", 
    Values = {
        "Carrot", "Strawberry", "Blueberry", "Orange Tulip",
        "Tomato", "Corn", "Daffodil", "Watermelon", "Pumpkin", 
        "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit", 
        "Mango", "Grape", "Mushroom", "Repper", "Cacao"
    },
    Default = 1,
    Callback = function(Value)
        shared.selectedSeed = Value
    end
})
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local autoPlant = false
local function equipSeed()
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find(shared.selectedSeed .. " Seed") then
            tool.Parent = character
            return true
        end
    end
    return false
end
local function hasSeedEquipped()
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find(shared.selectedSeed .. " Seed") then
            return true
        end
    end
    return false
end
local function teleportTo(position)
    if typeof(position) == "Vector3" then
        humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
end
local function getRandomPointInPart(part)
    local size = part.Size
    local pos = part.Position
    return Vector3.new(
        pos.X + (math.random() * 2 - 1) * size.X / 2,
        pos.Y,
        pos.Z + (math.random() * 2 - 1) * size.Z / 2
    )
end
local function plantSeed(position)
    local plantRE = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Plant_RE")
    if plantRE then
        plantRE:FireServer(position, shared.selectedSeed)
    end
end
local function autoPlantLoop()
    while autoPlant do
        local ready = false
        if hasSeedEquipped() or equipSeed() then
            for _, farm in ipairs(Workspace.Farm:GetChildren()) do
                local important = farm:FindFirstChild("Important")
                local data = important and important:FindFirstChild("Data")
                local owner = data and data:FindFirstChild("Owner")

                if owner and owner.Value == localPlayer.Name then
                    local plantLoc = important:FindFirstChild("Plant_Locations")
                    local canPlant = plantLoc and plantLoc:FindFirstChild("Can_Plant")

                    if canPlant then
                        local targetPos = getRandomPointInPart(canPlant)
                        teleportTo(targetPos)
                        task.wait(0.1)
                        plantSeed(targetPos)
                        ready = true
                        break
                    end
                end
            end
        end
        task.wait(0.1)
    end
end
Toggle:Callback(function(Value)
    autoPlant = Value
    if Value then
        coroutine.wrap(autoPlantLoop)()
    end
end)

local Toggle1 = Tabs.Seed:AddToggle("Carrot", {
    Title = "Auto Buy Carrot",
    Default = false
})
local buying = false
Toggle1:Callback(function(Value)
    buying = Value
    task.spawn(function()
        while buying do
            local args = {
                "Carrot"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)
local Toggle1 = Tabs.Seed:AddToggle("Strawberry", {
    Title = "Auto Buy Strawberry",
    Default = false
})
local buyingStrawberry = false
Toggle1:Callback(function(Value)
    buyingStrawberry = Value
    task.spawn(function()
        while buyingStrawberry do
            local args = {
                "Strawberry"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)
local Toggle1 = Tabs.Seed:AddToggle("Blueberry", {
    Title = "Auto Buy Blueberry",
    Default = false
})
local buyingBlueBerry = false
Toggle1:Callback(function(Value)
    buyingBlueBerry = Value
    task.spawn(function()
        while buyingBlueBerry do
            local args = {
                "Blueberry"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

local Toggle2 = Tab.Gear:AddToggle("GodlySprinkler", {
    Title = "Auto Buy Godly Sprinkler",
    Default = false
})
local buyingGodlySprinkler = false
Toggle2:Callback(function(Value)
    buyingGodlySprinkler = Value
    task.spawn(function()
        while buyingGodlySprinkler do
            local args = {
                "Godly Sprinkler"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)
local Toggle2 = Tabs.Gear:AddToggle("MasterSprinkler", {
    Title = "Auto Buy Master Sprinkler",
    Default = false
})
local buyingMasterSprinkler = false
Toggle2:Callback(function(Value)
    buyingMasterSprinkler = Value
    task.spawn(function()
        while buyingMasterSprinkler do
            local args = {
                "Master Sprinkler"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)
local Toggle2 = Tabs.Gear:AddToggle("FavoriteTool", {
    Title = "Auto Buy Favorite Tool",
    Default = false
})
local buyingFavoriteTool = false
Toggle2:Callback(function(Value)
    buyingFavoriteTool = Value
    task.spawn(function()
        while buyingFavoriteTool do
            local args = {
                "Favorite Tool"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

    local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Dropdown",
        Description = "You can select multiple values.",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })

    MultiDropdown:SetValue({
        three = true,
        five = true,
        seven = false
    })

    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)



    local Colorpicker = Tabs.Main:AddColorpicker("Colorpicker", {
        Title = "Colorpicker",
        Default = Color3.fromRGB(96, 205, 255)
    })

    Colorpicker:OnChanged(function()
        print("Colorpicker changed:", Colorpicker.Value)
    end)
    
    Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))



    local TColorpicker = Tabs.Main:AddColorpicker("TransparencyColorpicker", {
        Title = "Colorpicker",
        Description = "but you can change the transparency.",
        Transparency = 0,
        Default = Color3.fromRGB(96, 205, 255)
    })

    TColorpicker:OnChanged(function()
        print(
            "TColorpicker changed:", TColorpicker.Value,
            "Transparency:", TColorpicker.Transparency
        )
    end)



    local Keybind = Tabs.Main:AddKeybind("Keybind", {
        Title = "KeyBind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        Callback = function(Value)
            print("Keybind clicked!", Value)
        end,

        -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    -- OnClick is only fired when you press the keybind and the mode is Toggle
    -- Otherwise, you will have to use Keybind:GetState()
    Keybind:OnClick(function()
        print("Keybind clicked:", Keybind:GetState())
    end)

    Keybind:OnChanged(function()
        print("Keybind changed:", Keybind.Value)
    end)

    task.spawn(function()
        while true do
            wait(1)

            -- example for checking if a keybind is being pressed
            local state = Keybind:GetState()
            if state then
                print("Keybind is being held down")
            end

            if Fluent.Unloaded then break end
        end
    end)

    Keybind:SetValue("MB2", "Toggle") -- Sets keybind to MB2, mode to Hold


    local Input = Tabs.Main:AddInput("Input", {
        Title = "Input",
        Default = "Default",
        Placeholder = "Placeholder",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Input:OnChanged(function()
        print("Input updated:", Input.Value)
    end)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()