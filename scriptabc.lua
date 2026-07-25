-- [[
--    Bloxlord - Dog Race Script
--    Made By Ch Basharat
--    Premium Executor-Safe Universal Script
-- ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxlordDogRaceGui"
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
local infWinsActive = false
local autoTrainActive = false
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

-- 1. Inf Wins Feature (Spam 1M+ Wins)
local function performInfWins()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- 1. Scan finish pads & win zones in workspace
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = string.lower(v.Name)
            if string.find(name, "finish") or string.find(name, "win") or 
               string.find(name, "end") or string.find(name, "goal") or 
               string.find(name, "checkpointend") or string.find(name, "rewardpad") then
                
                if firetouchinterest then
                    pcall(function()
                        firetouchinterest(hrp, v, 0)
                        task.wait()
                        firetouchinterest(hrp, v, 1)
                    end)
                end
                
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
                
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt and fireproximityprompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
    
    -- 2. Spam Win Remotes
    local winRemotes = {
        "AddWins", "Win", "GiveWins", "AddWin", "WinRace", "RaceWin", 
        "FinishRace", "CollectWins", "WinEvent", "ClaimWin", "TouchFinish", 
        "FinishLine", "CompleteRace", "EndRace", "RaceFinish", "GiveWin", "Add1M"
    }
    for _, rName in ipairs(winRemotes) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, 1000)
        fireRemoteByName(rName, 1000000)
        fireRemoteByName(rName, true)
    end
end

-- 2. Auto Train Feature (Stand-still Training Points Collector)
local function performAutoTrain()
    -- 1. Tool Auto-Equip & Click
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool then
            tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = LocalPlayer.Character
            end
        end
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
    
    -- 2. Virtual User Screen Click
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
    
    -- 3. Workspace Training Equipment Scanner (Treadmills, Weights, Pads)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = string.lower(v.Name)
            if string.find(name, "train") or string.find(name, "treadmill") or 
               string.find(name, "weight") or string.find(name, "punch") or 
               string.find(name, "agility") or string.find(name, "exercise") or 
               string.find(name, "dogbed") or string.find(name, "speed") then
                
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
                
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt and fireproximityprompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                
                local part = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
                if part and hrp and firetouchinterest and part:FindFirstChildOfClass("TouchTransmitter") then
                    pcall(function()
                        firetouchinterest(hrp, part, 0)
                        task.wait()
                        firetouchinterest(hrp, part, 1)
                    end)
                end
            end
        end
    end
    
    -- 4. Training Remotes
    local trainRemotes = {
        "Train", "AddSpeed", "AddPower", "Training", "Click", "Tap", 
        "GainSpeed", "GainPower", "TrainEvent", "DoTrain", "ClickTrain", 
        "TapTrain", "TrainDog", "AddTraining", "TrainPoint", "AddPowerPoint"
    }
    for _, rName in ipairs(trainRemotes) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, true)
    end
end

-- 3. Auto Rebirth Feature (Requirement Auto Check & Rebirth GUI/Pad)
local function performAutoRebirth()
    -- 1. Click GUI Rebirth Buttons & Confirmation Popups
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                
                local isRebirth = string.find(name, "rebirth") or string.find(text, "rebirth")
                local isConfirm = string.find(name, "confirm") or string.find(text, "confirm") or 
                                  string.find(name, "yes") or string.find(text, "yes") or 
                                  string.find(name, "accept") or string.find(text, "accept")
                
                if isRebirth or isConfirm then
                    pcall(function() button:Activate() end)
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 2. Physical Rebirth Pads in Workspace / Map
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = string.lower(v.Name)
            if string.find(name, "rebirth") then
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
                
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt and fireproximityprompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                
                local part = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
                if part and hrp and firetouchinterest and part:FindFirstChildOfClass("TouchTransmitter") then
                    pcall(function()
                        firetouchinterest(hrp, part, 0)
                        task.wait()
                        firetouchinterest(hrp, part, 1)
                    end)
                end
            end
        end
    end
    
    -- 3. Rebirth Server Remotes
    local remoteNames = {
        "Rebirth", "RebirthRequest", "PerformRebirth", "BuyRebirth", 
        "DoRebirth", "RequestRebirth", "RebirthPlayer", "RebirthSystem", 
        "RebirthEvent", "RebirthFunction", "RebirthServer", "RebirthManager", 
        "ClaimRebirth", "DogRebirth"
    }
    
    for _, rName in ipairs(remoteNames) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, true)
        fireRemoteByName(rName, "1")
    end
end

-- UI Layout Design
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 230, 0, 220)
MainFrame.Position = UDim2.new(0.5, -115, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 140, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderFlat = Instance.new("Frame")
HeaderFlat.Size = UDim2.new(1, 0, 0.5, 0)
HeaderFlat.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFlat.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
HeaderFlat.BorderSizePixel = 0
HeaderFlat.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Dog Race 🐶"
TitleLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0.4, -35, 1, 0)
SubtitleLabel.Position = UDim2.new(0.6, 0, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Bloxlord"
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.Font = Enum.Font.GothamBold
SubtitleLabel.TextSize = 10
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
SubtitleLabel.Parent = Header

-- Close Button "X"
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Position = UDim2.new(1, -28, 0.5, -11)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 15
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
end)

makeDraggable(MainFrame, Header)

-- Container for features
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -24, 1, -75)
Container.Position = UDim2.new(0, 12, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Container

-- Toggle creation helper
local function createToggle(name, labelText, order)
    local Row = Instance.new("Frame")
    Row.Name = name .. "Row"
    Row.Size = UDim2.new(1, 0, 0, 28)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = Container
    
    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
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
    Checkbox.Position = UDim2.new(1, -26, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
    CheckboxStroke.Color = Color3.fromRGB(255, 140, 0)
    CheckboxStroke.Thickness = 1.2
    CheckboxStroke.Parent = Checkbox
    
    return Checkbox
end

-- Create Toggles
local toggleWins = createToggle("InfWins", "Inf Wins (1M+ Spam)", 1)
local toggleTrain = createToggle("AutoTrain", "Auto Train (Standing Still)", 2)
local toggleRebirth = createToggle("AutoRebirth", "Auto Rebirth", 3)

-- Checkbox activation helper
local function hookToggle(checkbox, callback)
    local state = false
    checkbox.MouseButton1Click:Connect(function()
        state = not state
        if state then
            checkbox.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            checkbox.Text = "✓"
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            checkbox.Text = ""
        end
        callback(state)
    end)
    
    checkbox.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
        end
    end)
    checkbox.MouseLeave:Connect(function()
        if not state then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        end
    end)
end

-- Hook Toggles
hookToggle(toggleWins, function(state) infWinsActive = state end)
hookToggle(toggleTrain, function(state) autoTrainActive = state end)
hookToggle(toggleRebirth, function(state) autoRebirthActive = state end)

-- Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 12)
FooterCorner.Parent = Footer

local FooterFlat = Instance.new("Frame")
FooterFlat.Size = UDim2.new(1, 0, 0.5, 0)
FooterFlat.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
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
FloatingToggle.Name = "DogRaceToggle"
FloatingToggle.Size = UDim2.new(0, 75, 0, 32)
FloatingToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FloatingToggle.BorderSizePixel = 0
FloatingToggle.Text = "Dog Race 🐶"
FloatingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 11
FloatingToggle.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(0, 8)
FloatingCorner.Parent = FloatingToggle

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = Color3.fromRGB(255, 140, 0)
FloatingStroke.Thickness = 1.5
FloatingStroke.Parent = FloatingToggle

makeDraggable(FloatingToggle, FloatingToggle)

-- Toggle main frame visibility
local visible = true
FloatingToggle.MouseButton1Click:Connect(function()
    visible = not visible
    MainFrame.Visible = visible
end)

-- Keyboard keybind (RightShift / Insert)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert) then
        visible = not visible
        MainFrame.Visible = visible
    end
end)

-- 1. High-Speed Inf Wins Loop (1M+ Wins Spam)
task.spawn(function()
    while true do
        task.wait(0.01)
        if infWinsActive then
            pcall(performInfWins)
        end
    end
end)

-- 2. Auto Train Loop (Standing Still)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoTrainActive then
            pcall(performAutoTrain)
        end
    end
end)

-- 3. Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if autoRebirthActive then
            pcall(performAutoRebirth)
        end
    end
end)

-- Welcome Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Dog Race Script Loaded!",
        Text = "Press RightShift or click floating button to toggle UI.",
        Duration = 5
    })
end)
