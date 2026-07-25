-- [[
--    Bloxlord - Break Tape For Brainrots Script
--    Made By Ch Basharat
--    Premium Executor-Safe Script
-- ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxlordGui"
ScreenGui.ResetOnSpawn = false

-- Fallback for parent protection in modern executors
local parentObj = nil
pcall(function()
    if gethui then
        parentObj = gethui()
    elseif syn and syn.protect_gui then
        parentObj = game:GetService("CoreGui")
    else
        parentObj = game:GetService("CoreGui")
    end
end)
ScreenGui.Parent = parentObj or LocalPlayer:WaitForChild("PlayerGui")

-- Variables for Toggles
local findOGActive = false
local findExclusiveActive = false
local collectCashActive = false
local upgradeAllActive = false
local buyPower10Active = false
local autoRebirthActive = false

-- Draggable function for all executors
local function makeDraggable(frame, dragHandle)
    local dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPosition}):Play()
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
            
            local dragConnection
            dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                    update(changedInput)
                end
            end)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragConnection:Disconnect()
                end
            end)
        end
    end)
end

-- Teleport function
local function teleportTo(instance)
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetCFrame = nil
    if instance:IsA("Model") then
        if instance.PrimaryPart then
            targetCFrame = instance.PrimaryPart.CFrame
        else
            local part = instance:FindFirstChildOfClass("BasePart")
            if part then
                targetCFrame = part.CFrame
            end
        end
    elseif instance:IsA("BasePart") then
        targetCFrame = instance.CFrame
    end
    
    if targetCFrame then
        hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    end
end

-- Find Tape Type function (scans both names and billboard text labels)
local function teleportToTapeType(typeName)
    local found = nil
    
    -- Check names
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            if string.find(string.lower(v.Name), string.lower(typeName)) then
                found = v
                break
            end
        end
    end
    
    -- Check BillboardGui labels if not found by name
    if not found then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BillboardGui") then
                for _, tl in ipairs(v:GetDescendants()) do
                    if tl:IsA("TextLabel") and string.find(string.lower(tl.Text), string.lower(typeName)) then
                        local parent = v.Adornee or v.Parent
                        if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
                            found = parent
                            break
                        end
                    end
                end
            end
            if found then break end
        end
    end
    
    if found then
        teleportTo(found)
    end
end

-- Find Best Earnings function
local function teleportToBestEarnings()
    local bestTape = nil
    local maxEarnings = -1
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local isTape = false
            local earnings = 0
            
            -- Method 1: Check Attributes
            local attReward = v:GetAttribute("Reward") or v:GetAttribute("Cash") or v:GetAttribute("Earnings") or v:GetAttribute("Value")
            if attReward then
                isTape = true
                earnings = tonumber(attReward) or 0
            end
            
            -- Method 2: Check Value Instances
            if not isTape then
                local valObj = v:FindFirstChild("Reward") or v:FindFirstChild("Cash") or v:FindFirstChild("Earnings") or v:FindFirstChild("Value")
                if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
                    isTape = true
                    earnings = valObj.Value
                end
            end
            
            -- Method 3: Check BillboardGuis
            if not isTape then
                local bbgui = v:FindFirstChildOfClass("BillboardGui")
                if bbgui then
                    for _, tl in ipairs(bbgui:GetDescendants()) do
                        if tl:IsA("TextLabel") then
                            local txt = tl.Text
                            local cleanTxt = string.gsub(txt, "[$,+]", "")
                            local num = tonumber(cleanTxt)
                            if num then
                                isTape = true
                                earnings = num
                            elseif string.find(string.lower(txt), "k") then
                                local base = tonumber(string.gsub(string.lower(txt), "k", ""))
                                if base then
                                    isTape = true
                                    earnings = base * 1000
                                end
                            end
                        end
                    end
                end
            end
            
            -- Fallback Check
            if not isTape then
                local name = string.lower(v.Name)
                if string.find(name, "tape") or string.find(name, "brainrot") then
                    isTape = true
                    earnings = 1
                end
            end
            
            if isTape and earnings > maxEarnings then
                local part = v:IsA("BasePart") and v or (v:FindFirstChildOfClass("BasePart") or v.PrimaryPart)
                if part then
                    maxEarnings = earnings
                    bestTape = v
                end
            end
        end
    end
    
    if bestTape then
        teleportTo(bestTape)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Bloxlord",
                Text = "Teleported to best earnings tape (" .. tostring(maxEarnings) .. ")",
                Duration = 2
            })
        end)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Bloxlord",
                Text = "No tape/brainrot found!",
                Duration = 2
            })
        end)
    end
end

-- Collect Cash function
local function collectCash()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (string.find(string.lower(v.Name), "cash") or string.find(string.lower(v.Name), "coin") or string.find(string.lower(v.Name), "money")) then
            if v:FindFirstChildOfClass("TouchTransmitter") or v.Name == "Cash" or v.Name == "Coin" then
                if firetouchinterest then
                    firetouchinterest(hrp, v, 0)
                    task.wait()
                    firetouchinterest(hrp, v, 1)
                else
                    v.CFrame = hrp.CFrame
                end
            end
        end
    end
end

-- Upgrade All function
local function performUpgradeAll()
    -- 1. Simulated Clicks
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                if string.find(name, "upgrade") or string.find(text, "upgrade") or string.find(name, "buy") or string.find(text, "buy") then
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 2. Remote Fire
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = string.lower(v.Name)
            if string.find(name, "upgrade") or string.find(name, "buy") or string.find(name, "purchase") then
                pcall(function()
                    v:FireServer("Power")
                    v:FireServer("Speed")
                    v:FireServer("Click")
                    v:FireServer("Damage")
                    v:FireServer("All")
                end)
            end
        end
    end
end

-- Buy Power +10 function
local function performBuyPower()
    -- 1. Simulated Clicks
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                if (string.find(name, "power") or string.find(text, "power")) and (string.find(name, "buy") or string.find(text, "buy") or string.find(name, "upgrade") or string.find(text, "upgrade")) then
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 2. Remote Fire
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = string.lower(v.Name)
            if string.find(name, "power") and (string.find(name, "upgrade") or string.find(name, "buy")) then
                pcall(function()
                    v:FireServer("Power", 10)
                    v:FireServer(10)
                end)
            end
        end
    end
end

-- Auto Rebirth function
local function performRebirth()
    -- 1. Simulated Clicks
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                if string.find(name, "rebirth") or string.find(text, "rebirth") then
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 2. Remote Fire
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = string.lower(v.Name)
            if string.find(name, "rebirth") then
                pcall(function()
                    v:FireServer(1)
                    v:FireServer()
                end)
            end
        end
    end
end

-- Auto Click tool function
local function autoClick()
    if not LocalPlayer.Character then return end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then
        tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = LocalPlayer.Character
        end
    end
    if tool then
        tool:Activate()
    end
end

-- UI Layout Design
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 340)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- UICorner for main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- UIStroke for red border
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Bottom Hider (to make bottom of header flat)
local HeaderFlat = Instance.new("Frame")
HeaderFlat.Size = UDim2.new(1, 0, 0.5, 0)
HeaderFlat.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFlat.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HeaderFlat.BorderSizePixel = 0
HeaderFlat.Parent = Header

-- Title Label "Bloxlord"
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Bloxlord"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Subtitle Label "Break Tape For Brainrots"
local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0.5, -15, 1, 0)
SubtitleLabel.Position = UDim2.new(0.5, 5, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Break Tape Brainrots"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.Font = Enum.Font.GothamBold
SubtitleLabel.TextSize = 9
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
SubtitleLabel.Parent = Header

-- Make Frame Draggable using the Header
makeDraggable(MainFrame, Header)

-- Container for features
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -85)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- UIListLayout
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Container

-- "Find Best Earnings" Button
local FindBestButton = Instance.new("TextButton")
FindBestButton.Name = "FindBestEarnings"
FindBestButton.Size = UDim2.new(1, 0, 0, 32)
FindBestButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FindBestButton.BorderSizePixel = 0
FindBestButton.Text = "Find Best Earnings"
FindBestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FindBestButton.Font = Enum.Font.GothamBold
FindBestButton.TextSize = 13
FindBestButton.LayoutOrder = 1
FindBestButton.Parent = Container

local FindBestCorner = Instance.new("UICorner")
FindBestCorner.CornerRadius = UDim.new(0, 6)
FindBestCorner.Parent = FindBestButton

FindBestButton.MouseButton1Click:Connect(function()
    teleportToBestEarnings()
end)

-- Hover effect for button
FindBestButton.MouseEnter:Connect(function()
    TweenService:Create(FindBestButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end)
FindBestButton.MouseLeave:Connect(function()
    TweenService:Create(FindBestButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
end)

-- Toggle creation helper
local function createToggle(name, labelText, order)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(1, -20, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Checkbox.BorderSizePixel = 0
    Checkbox.Text = ""
    Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkbox.Font = Enum.Font.GothamBold
    Checkbox.TextSize = 14
    Checkbox.Parent = Row
    
    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 4)
    CheckboxCorner.Parent = Checkbox
    
    local CheckboxStroke = Instance.new("UIStroke")
    CheckboxStroke.Color = Color3.fromRGB(255, 60, 60)
    CheckboxStroke.Thickness = 1
    CheckboxStroke.Parent = Checkbox
    
    return Checkbox
end

-- Create Toggles
local toggleOG = createToggle("FindOG", "Find OG", 2)
local toggleExclusive = createToggle("FindExclusive", "Find Exclusive", 3)
local toggleCash = createToggle("CollectCash", "Collect Cash", 4)
local toggleUpgrade = createToggle("UpgradeAll", "Upgrade All", 5)
local togglePower = createToggle("BuyPower10", "Buy Power +10", 6)
local toggleRebirth = createToggle("AutoRebirth", "Auto Rebirth", 7)

-- Checkbox activation helper
local function hookToggle(checkbox, callback)
    local state = false
    checkbox.MouseButton1Click:Connect(function()
        state = not state
        if state then
            checkbox.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            checkbox.Text = "✓"
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            checkbox.Text = ""
        end
        callback(state)
    end)
    
    -- Hover effect
    checkbox.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)
    checkbox.MouseLeave:Connect(function()
        if not state then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
        end
    end)
end

-- Hook Toggles
hookToggle(toggleOG, function(state) findOGActive = state end)
hookToggle(toggleExclusive, function(state) findExclusiveActive = state end)
hookToggle(toggleCash, function(state) collectCashActive = state end)
hookToggle(toggleUpgrade, function(state) upgradeAllActive = state end)
hookToggle(togglePower, function(state) buyPower10Active = state end)
hookToggle(toggleRebirth, function(state) autoRebirthActive = state end)

-- Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 10)
FooterCorner.Parent = Footer

-- Top Hider for footer
local FooterFlat = Instance.new("Frame")
FooterFlat.Size = UDim2.new(1, 0, 0.5, 0)
FooterFlat.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
FooterFlat.BorderSizePixel = 0
FooterFlat.Parent = Footer

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Made By Ch Basharat"
FooterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FooterLabel.Font = Enum.Font.GothamSemibold
FooterLabel.TextSize = 10
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.Parent = Footer

-- Floating Toggle Button (For Mobile & easy access)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "BloxlordToggle"
FloatingToggle.Size = UDim2.new(0, 65, 0, 30)
FloatingToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatingToggle.BorderSizePixel = 0
FloatingToggle.Text = "Bloxlord"
FloatingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 11
FloatingToggle.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(0, 6)
FloatingCorner.Parent = FloatingToggle

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = Color3.fromRGB(255, 60, 60)
FloatingStroke.Thickness = 1.5
FloatingStroke.Parent = FloatingToggle

makeDraggable(FloatingToggle, FloatingToggle)

-- Toggle main frame visibility
local visible = true
FloatingToggle.MouseButton1Click:Connect(function()
    visible = not visible
    MainFrame.Visible = visible
end)

-- Standard Keyboard bind key (RightShift / Insert) to toggle menu
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert) then
        visible = not visible
        MainFrame.Visible = visible
    end
end)

-- Main Loops (task.spawn to run asynchronously without crashing the client)

-- Find OG Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if findOGActive then
            pcall(function()
                teleportToTapeType("OG")
            end)
        end
    end
end)

-- Find Exclusive Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if findExclusiveActive then
            pcall(function()
                teleportToTapeType("Exclusive")
            end)
        end
    end
end)

-- Collect Cash Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if collectCashActive then
            pcall(collectCash)
        end
    end
end)

-- Upgrade All Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if upgradeAllActive then
            pcall(performUpgradeAll)
        end
    end
end)

-- Buy Power +10 Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if buyPower10Active then
            pcall(performBuyPower)
        end
    end
end)

-- Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(2.5)
        if autoRebirthActive then
            pcall(performRebirth)
        end
    end
end)

-- Auto Clicker (active during farming modes)
task.spawn(function()
    while true do
        task.wait(0.1)
        if findOGActive or findExclusiveActive or upgradeAllActive or buyPower10Active then
            pcall(autoClick)
        end
    end
end)

-- Welcome Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bloxlord Loaded!",
        Text = "Press RightShift or click floating button to toggle UI.",
        Duration = 5
    })
end)
