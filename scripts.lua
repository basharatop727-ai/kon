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

-- Get all active breakable tapes/brainrots via proximity prompts
local function getTapes()
    local tapes = {}
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local action = string.lower(prompt.ActionText)
            local object = string.lower(prompt.ObjectText)
            local parent = prompt.Parent
            
            -- Exclude store elements, gamepass unlocks, rebirth pads, portals
            if not string.find(action, "buy") and not string.find(action, "open") and 
               not string.find(action, "unlock") and not string.find(action, "rebirth") and 
               not string.find(object, "shop") and not string.find(object, "gamepass") then
                table.insert(tapes, {
                    prompt = prompt,
                    parent = parent,
                    name = parent.Name,
                    objectText = prompt.ObjectText,
                    actionText = prompt.ActionText
                })
            end
        end
    end
    return tapes
end

-- Parse numerical reward value of a tape
local function getTapeValue(tape)
    local text = string.lower(tape.objectText .. " " .. tape.actionText .. " " .. tape.name)
    local val = 0
    local clean = string.gsub(text, "[$,+]", "")
    
    local num, suffix = string.match(clean, "(%d+%.?%d*)([kmb]?)")
    if num then
        val = tonumber(num) or 0
        if suffix == "k" then
            val = val * 1000
        elseif suffix == "m" then
            val = val * 1000000
        elseif suffix == "b" then
            val = val * 1000000000
        end
    end
    return val
end

-- Find Best Earnings function
local function teleportToBestEarnings()
    local tapes = getTapes()
    if #tapes == 0 then
        -- Fallback to workspace elements if no prompts are found
        local foundFallback = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("BasePart") then
                local name = string.lower(v.Name)
                if string.find(name, "tape") or string.find(name, "brainrot") then
                    foundFallback = v
                    break
                end
            end
        end
        if foundFallback then
            teleportTo(foundFallback)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Bloxlord",
                    Text = "Teleported to tape/brainrot fallback",
                    Duration = 2
                })
            end)
        else
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Bloxlord",
                    Text = "No tapes/brainrots found!",
                    Duration = 2
                })
            end)
        end
        return
    end
    
    -- Sort by parsed earnings, then by distance from spawn (further = higher zone)
    table.sort(tapes, function(a, b)
        local valA = getTapeValue(a)
        local valB = getTapeValue(b)
        if valA ~= valB then
            return valA > valB
        else
            local posA = a.parent:IsA("BasePart") and a.parent.Position or (a.parent.PrimaryPart and a.parent.PrimaryPart.Position or Vector3.new(0,0,0))
            local posB = b.parent:IsA("BasePart") and b.parent.Position or (b.parent.PrimaryPart and b.parent.PrimaryPart.Position or Vector3.new(0,0,0))
            return posA.Magnitude > posB.Magnitude
        end
    end)
    
    local best = tapes[1]
    teleportTo(best.parent)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bloxlord",
            Text = "Teleported to: " .. best.name .. " (" .. tostring(getTapeValue(best)) .. ")",
            Duration = 2
        })
    end)
end

-- Universal Remote Fire function
local function fireRemoteByName(targetName, ...)
    local args = {...}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and string.lower(v.Name) == string.lower(targetName) then
            pcall(function()
                if v:IsA("RemoteEvent") then
                    v:FireServer(unpack(args))
                else
                    v:InvokeServer(unpack(args))
                end
            end)
        end
    end
end

-- Collect Cash function (Combines touch interests and proximity prompts)
local function collectCash()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Touch collectible parts
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = string.lower(v.Name)
            local parentName = v.Parent and string.lower(v.Parent.Name) or ""
            if string.find(name, "cash") or string.find(parentName, "cash") or 
               string.find(name, "coin") or string.find(parentName, "coin") or 
               string.find(name, "money") or string.find(name, "drop") or string.find(parentName, "drop") then
                
                -- Touch with primary root part
                if firetouchinterest then
                    pcall(function()
                        firetouchinterest(hrp, v, 0)
                        task.wait()
                        firetouchinterest(hrp, v, 1)
                    end)
                    -- Touch with foot fallback to satisfy custom collision checks
                    local foot = LocalPlayer.Character:FindFirstChild("LeftFoot") or LocalPlayer.Character:FindFirstChild("Left Leg")
                    if foot then
                        pcall(function()
                            firetouchinterest(foot, v, 0)
                            task.wait()
                            firetouchinterest(foot, v, 1)
                        end)
                    end
                else
                    -- Teleport physical drop to player character
                    pcall(function()
                        v.Anchored = false
                        v.CanCollide = false
                        v.CFrame = hrp.CFrame
                    end)
                end
            end
        end
    end
    
    -- Interact with collectible prompts
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local action = string.lower(prompt.ActionText)
            local object = string.lower(prompt.ObjectText)
            local parentName = prompt.Parent and string.lower(prompt.Parent.Name) or ""
            if string.find(action, "collect") or string.find(action, "cash") or 
               string.find(object, "cash") or string.find(parentName, "cash") or 
               string.find(parentName, "money") then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
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
    local stats = {"Power", "Speed", "WalkSpeed", "Click", "Damage", "Strength"}
    for _, stat in ipairs(stats) do
        fireRemoteByName("Upgrade", stat)
        fireRemoteByName("Upgrade", stat, 1)
        fireRemoteByName("BuyUpgrade", stat)
        fireRemoteByName("PurchaseUpgrade", stat)
    end
end

-- Buy Power +10 function
local function performBuyPower()
    -- 1. Simulated Clicks (Detects Power, Damage, Strength, or Click buttons)
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                
                local isPowerBtn = string.find(name, "power") or string.find(text, "power") or
                                   string.find(name, "damage") or string.find(text, "damage") or
                                   string.find(name, "strength") or string.find(text, "strength") or
                                   string.find(name, "click") or string.find(text, "click")
                                   
                local isBuyBtn = string.find(name, "buy") or string.find(text, "buy") or 
                                 string.find(name, "upgrade") or string.find(text, "upgrade")
                                 
                if isPowerBtn and isBuyBtn then
                    if getconnections then
                        for i = 1, 10 do
                            for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                            for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Remote Fire (loops 10 times to purchase exactly +10 for all potential stat names)
    local stats = {"Power", "Damage", "Click", "Strength", "PowerStrength"}
    for i = 1, 10 do
        for _, stat in ipairs(stats) do
            fireRemoteByName("Upgrade", stat)
            fireRemoteByName("Upgrade", stat, 1)
            fireRemoteByName("BuyUpgrade", stat)
            fireRemoteByName("PurchaseUpgrade", stat)
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
    fireRemoteByName("Rebirth")
    fireRemoteByName("Rebirth", 1)
    fireRemoteByName("RebirthRequest")
    fireRemoteByName("PerformRebirth")
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

-- Auto fire proximity prompt of the nearest active tape
local function autoFireClosestPrompt()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closestPrompt = nil
    local minDistance = 25 -- max reach distance
    
    for _, t in ipairs(getTapes()) do
        local part = t.parent:IsA("BasePart") and t.parent or (t.parent.PrimaryPart or t.parent:FindFirstChildOfClass("BasePart"))
        if part then
            local dist = (hrp.Position - part.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                closestPrompt = t.prompt
            end
        end
    end
    
    if closestPrompt and fireproximityprompt then
        fireproximityprompt(closestPrompt)
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
SubtitleLabel.Size = UDim2.new(0.5, -45, 1, 0)
SubtitleLabel.Position = UDim2.new(0.5, 5, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Break Tape Brainrots"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.Font = Enum.Font.GothamBold
SubtitleLabel.TextSize = 9
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
SubtitleLabel.Parent = Header

-- Close Button "X"
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Hover effect for Close Button
CloseButton.MouseEnter:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
end)

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
        task.wait(0.5)
        if findOGActive then
            pcall(function()
                local og = nil
                for _, t in ipairs(getTapes()) do
                    if string.find(string.lower(t.name), "og") or string.find(string.lower(t.objectText), "og") then
                        og = t
                        break
                    end
                end
                if og then
                    teleportTo(og.parent)
                end
            end)
        end
    end
end)

-- Find Exclusive Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if findExclusiveActive then
            pcall(function()
                local exc = nil
                for _, t in ipairs(getTapes()) do
                    if string.find(string.lower(t.name), "exclusive") or string.find(string.lower(t.objectText), "exclusive") then
                        exc = t
                        break
                    end
                end
                if exc then
                    teleportTo(exc.parent)
                end
            end)
        end
    end
end)

-- Collect Cash Loop
task.spawn(function()
    while true do
        task.wait(0.3)
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
        task.wait(2)
        if autoRebirthActive then
            pcall(performRebirth)
        end
    end
end)

-- Auto Clicker & Proximity Prompt Trigger (Active during farm modes)
task.spawn(function()
    while true do
        task.wait(0.05)
        if findOGActive or findExclusiveActive or upgradeAllActive or buyPower10Active then
            pcall(autoClick)
            pcall(autoFireClosestPrompt)
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
