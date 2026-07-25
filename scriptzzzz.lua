-- [[
--    Bloxlord - Break Tape For Brainrots Script
--    Made By Ch Basharat
--    Premium Executor-Safe Universal Edition
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
local autoBestActive = false
local collectCashActive = false
local upgradeAllActive = false
local buyPower10Active = false
local autoRebirthActive = false
local autoClickerActive = false

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

-- Find player's specific base plot in workspace
local function getPlayerPlot()
    local containers = {
        workspace:FindFirstChild("Plots"),
        workspace:FindFirstChild("Tycoons"),
        workspace:FindFirstChild("Bases"),
        workspace:FindFirstChild("PlotsFolder"),
        workspace:FindFirstChild("Players"),
        workspace
    }
    
    for _, container in ipairs(containers) do
        if container then
            for _, plot in ipairs(container:GetChildren()) do
                if plot:IsA("Model") or plot:IsA("Folder") then
                    local ownerAttr = plot:GetAttribute("Owner") or plot:GetAttribute("Player") or plot:GetAttribute("UserId")
                    if tostring(ownerAttr) == LocalPlayer.Name or tostring(ownerAttr) == tostring(LocalPlayer.UserId) then
                        return plot
                    end
                    
                    local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
                    if ownerVal then
                        if ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer then
                            return plot
                        elseif ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name then
                            return plot
                        elseif ownerVal:IsA("IntValue") or ownerVal:IsA("NumberValue") then
                            if tostring(ownerVal.Value) == tostring(LocalPlayer.UserId) then
                                return plot
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Teleport function with safety check
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
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end)
        hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    end
end

-- Find player plot base, deposit pad, or sell point
local function getBaseOrSellPad()
    local myPlot = getPlayerPlot()
    if myPlot then
        local pad = myPlot:FindFirstChild("Sell") or myPlot:FindFirstChild("Deposit") or 
                    myPlot:FindFirstChild("Base") or myPlot:FindFirstChild("SellPad") or 
                    myPlot:FindFirstChild("SellArea") or myPlot:FindFirstChild("Deliver") or
                    myPlot:FindFirstChild("Dropoff")
        if pad then
            return pad
        end
        local spawnPart = myPlot:FindFirstChild("Spawn") or myPlot:FindFirstChild("BasePart") or myPlot:FindFirstChildOfClass("SpawnLocation")
        if spawnPart then
            return spawnPart
        end
        if myPlot.PrimaryPart then
            return myPlot.PrimaryPart
        end
        local anyPart = myPlot:FindFirstChildOfClass("BasePart")
        if anyPart then
            return anyPart
        end
    end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = string.lower(v.Name)
            if name == "sell" or name == "sellpad" or name == "deposit" or name == "deliver" or name == "dropoff" or name == "sell part" or name == "sellarea" then
                return v
            end
        end
    end
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("SpawnLocation") then
            return v
        end
    end
    
    return nil
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

-- Get all active breakable tapes/brainrots via proximity prompts
local function getTapes()
    local tapes = {}
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local action = string.lower(prompt.ActionText or "")
            local object = string.lower(prompt.ObjectText or "")
            local parent = prompt.Parent
            
            if not string.find(action, "buy") and not string.find(action, "open") and 
               not string.find(action, "unlock") and not string.find(action, "rebirth") and 
               not string.find(object, "shop") and not string.find(object, "gamepass") then
                table.insert(tapes, {
                    prompt = prompt,
                    parent = parent,
                    name = parent and parent.Name or "UnknownTape",
                    objectText = prompt.ObjectText or "",
                    actionText = prompt.ActionText or ""
                })
            end
        end
    end
    return tapes
end

-- Multi-field tape tag scanner (For OG, Exclusive, Secret, etc.)
local function getTapesByTag(tag)
    local tagLower = string.lower(tag)
    local found = {}
    
    for _, t in ipairs(getTapes()) do
        local isMatch = false
        local parentName = string.lower(t.name)
        local objText = string.lower(t.objectText)
        local actText = string.lower(t.actionText)
        
        if string.find(parentName, tagLower) or string.find(objText, tagLower) or string.find(actText, tagLower) then
            isMatch = true
        end
        
        if not isMatch and t.parent then
            pcall(function()
                for _, child in ipairs(t.parent:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        if string.find(string.lower(child.Text), tagLower) then
                            isMatch = true
                            break
                        end
                    end
                end
                for attrName, attrVal in pairs(t.parent:GetAttributes()) do
                    if string.find(string.lower(tostring(attrVal)), tagLower) or string.find(string.lower(tostring(attrName)), tagLower) then
                        isMatch = true
                        break
                    end
                end
            end)
        end
        
        if isMatch then
            table.insert(found, t)
        end
    end
    
    return found
end

-- Advanced numerical reward / earnings value parser of a tape
local function getTapeValue(tape)
    local fullText = string.lower(tape.objectText .. " " .. tape.actionText .. " " .. tape.name)
    
    if tape.parent then
        pcall(function()
            for _, child in ipairs(tape.parent:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    fullText = fullText .. " " .. string.lower(child.Text)
                elseif child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("DoubleConstrainedValue") then
                    fullText = fullText .. " " .. tostring(child.Value)
                end
            end
            for attrName, attrVal in pairs(tape.parent:GetAttributes()) do
                fullText = fullText .. " " .. tostring(attrVal)
            end
        end)
    end
    
    local clean = string.gsub(fullText, "[$,+]", "")
    local maxVal = 0
    
    for numStr, suffix in string.gmatch(clean, "(%d+%.?%d*)([a-z]*)") do
        local num = tonumber(numStr)
        if num then
            local mult = 1
            if suffix == "k" then mult = 1e3
            elseif suffix == "m" then mult = 1e6
            elseif suffix == "b" then mult = 1e9
            elseif suffix == "t" then mult = 1e12
            elseif suffix == "qa" or suffix == "q" then mult = 1e15
            elseif suffix == "qi" then mult = 1e18
            elseif suffix == "sx" then mult = 1e21
            elseif suffix == "sp" then mult = 1e24
            end
            
            local calc = num * mult
            if calc > maxVal then
                maxVal = calc
            end
        end
    end
    
    return maxVal
end

-- Universal Auto Clicker function (Tool + VirtualUser + Remotes)
local function autoClick()
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
    
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
    
    local clickRemotes = {"Click", "Tap", "Break", "Punch", "Hit", "Attack", "BreakTape", "TapRemote", "ClickRemote", "MainClick", "Clicker"}
    for _, rName in ipairs(clickRemotes) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, true)
    end
end

-- Find Best Earnings function (Steals best tape, then returns to base)
local function teleportToBestEarnings()
    local tapes = getTapes()
    if #tapes == 0 then
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
            task.wait(3)
            local base = getBaseOrSellPad()
            if base then teleportTo(base) end
        end
        return
    end
    
    table.sort(tapes, function(a, b)
        local valA = getTapeValue(a)
        local valB = getTapeValue(b)
        if valA ~= valB then
            return valA > valB
        else
            local posA = (a.parent and a.parent:IsA("BasePart")) and a.parent.Position or (a.parent and a.parent.PrimaryPart and a.parent.PrimaryPart.Position or Vector3.new(0,0,0))
            local posB = (b.parent and b.parent:IsA("BasePart")) and b.parent.Position or (b.parent and b.parent.PrimaryPart and b.parent.PrimaryPart.Position or Vector3.new(0,0,0))
            return posA.Magnitude > posB.Magnitude
        end
    end)
    
    local best = tapes[1]
    if not best or not best.parent then return end
    
    teleportTo(best.parent)
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bloxlord",
            Text = "Farming best tape: " .. tostring(best.name),
            Duration = 2
        })
    end)
    
    local start = tick()
    while tick() - start < 3.5 do
        if fireproximityprompt and best.prompt then
            pcall(function() fireproximityprompt(best.prompt) end)
        end
        pcall(autoClick)
        task.wait(0.1)
    end
    
    local base = getBaseOrSellPad()
    if base then
        teleportTo(base)
    end
end

-- Collect Cash function (Collects cash generated by brainrots in base + ground drops)
local function collectCash()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myPlot = getPlayerPlot()
    local searchArea = myPlot or workspace
    
    -- 1. Scan player plot & workspace for brainrot cash generators / collectors / podiums / slots
    for _, v in ipairs(searchArea:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = string.lower(v.Name)
            if string.find(name, "collect") or string.find(name, "claim") or 
               string.find(name, "generator") or string.find(name, "collector") or 
               string.find(name, "bank") or string.find(name, "safe") or 
               string.find(name, "giver") or string.find(name, "podium") or 
               string.find(name, "brainrot") or string.find(name, "slot") then
                
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd and fireclickdetector then
                    pcall(function() fireclickdetector(cd) end)
                end
                
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt and fireproximityprompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                
                local part = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
                if part and part:FindFirstChildOfClass("TouchTransmitter") then
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(hrp, part, 0)
                            task.wait()
                            firetouchinterest(hrp, part, 1)
                        end)
                    end
                end
            end
        end
    end
    
    -- 2. Floor Cash Drops inside plot & workspace
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = string.lower(v.Name)
            local parentName = v.Parent and string.lower(v.Parent.Name) or ""
            if string.find(name, "cash") or string.find(parentName, "cash") or 
               string.find(name, "coin") or string.find(parentName, "coin") or 
               string.find(name, "money") or string.find(name, "drop") or string.find(parentName, "drop") then
                
                if firetouchinterest then
                    pcall(function()
                        firetouchinterest(hrp, v, 0)
                        task.wait()
                        firetouchinterest(hrp, v, 1)
                    end)
                else
                    pcall(function()
                        v.Anchored = false
                        v.CanCollide = false
                        v.CFrame = hrp.CFrame
                    end)
                end
            end
        end
    end
    
    -- 3. Click GUI Claim/Collect Buttons
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                if string.find(name, "claim") or string.find(text, "claim") or 
                   string.find(name, "collect") or string.find(text, "collect") then
                    pcall(function() button:Activate() end)
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 4. Server Remotes
    local collectRemotes = {
        "CollectCash", "CollectCoins", "Collect", "Claim", "ClaimCash", 
        "CollectGenerator", "CollectAll", "ClaimAll", "CollectPlot", 
        "CollectGiver", "ClaimGenerator", "CollectPlotCash", "CollectBrainrots",
        "CollectBrainrotCash", "ClaimPlotCash", "CollectBaseCash"
    }
    for _, rName in ipairs(collectRemotes) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, true)
    end
end

-- Upgrade All function (Upgrades brainrots in player's base plot + stats)
local function performUpgradeAll()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPlot = getPlayerPlot()
    local searchArea = myPlot or workspace
    
    -- 1. Scan player plot & workspace for brainrot upgrade pads / buttons / slots
    for _, v in ipairs(searchArea:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = string.lower(v.Name)
            if string.find(name, "upgrade") or string.find(name, "evolve") or 
               string.find(name, "level") or string.find(name, "stat") or 
               string.find(name, "tier") or string.find(name, "star") or 
               string.find(name, "promote") then
                
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
    
    -- 2. PlayerGui Upgrade Buttons
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                if string.find(name, "upgrade") or string.find(text, "upgrade") or 
                   string.find(name, "level") or string.find(text, "level") or 
                   string.find(name, "evolve") or string.find(text, "evolve") or 
                   string.find(name, "buy") or string.find(text, "buy") then
                    pcall(function() button:Activate() end)
                    if getconnections then
                        for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                        for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                    end
                end
            end
        end
    end
    
    -- 3. Remotes
    local stats = {"Power", "Speed", "WalkSpeed", "Click", "Damage", "Strength", "Brainrot", "Multiplier", "Capacity", "Income", "Cash", "Bag", "BrainrotUpgrade", "Slot"}
    for _, stat in ipairs(stats) do
        fireRemoteByName("Upgrade", stat)
        fireRemoteByName("Upgrade", stat, 1)
        fireRemoteByName("BuyUpgrade", stat)
        fireRemoteByName("PurchaseUpgrade", stat)
        fireRemoteByName("UpgradeBrainrot", stat)
        fireRemoteByName("EvolveBrainrot", stat)
        fireRemoteByName("UpgradeSlot", stat)
        fireRemoteByName("UpgradePlotBrainrot", stat)
        fireRemoteByName("BuyBrainrotUpgrade", stat)
        fireRemoteByName("UpgradeUnit", stat)
        fireRemoteByName("LevelUpBrainrot", stat)
        fireRemoteByName("UpgradeStat", stat)
        fireRemoteByName("LevelUp", stat)
    end
end

-- Buy Power +10 function
local function performBuyPower()
    if LocalPlayer:FindFirstChild("PlayerGui") then
        for _, button in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local text = button:IsA("TextButton") and string.lower(button.Text) or ""
                local name = string.lower(button.Name)
                
                local isPowerBtn = string.find(name, "power") or string.find(text, "power") or
                                   string.find(name, "damage") or string.find(text, "damage") or
                                   string.find(name, "strength") or string.find(text, "strength") or
                                   string.find(name, "punch") or string.find(text, "punch") or
                                   string.find(name, "tap") or string.find(text, "tap") or
                                   string.find(name, "click") or string.find(text, "click")
                                   
                local isBuyBtn = string.find(name, "buy") or string.find(text, "buy") or 
                                 string.find(name, "upgrade") or string.find(text, "upgrade") or
                                 string.find(name, "+10") or string.find(text, "+10") or
                                 string.find(name, "+") or string.find(text, "+")
                                 
                if isPowerBtn or isBuyBtn then
                    for i = 1, 10 do
                        pcall(function() button:Activate() end)
                        if getconnections then
                            for _, con in pairs(getconnections(button.MouseButton1Click)) do con:Fire() end
                            for _, con in pairs(getconnections(button.Activated)) do con:Fire() end
                        end
                    end
                end
            end
        end
    end
    
    local stats = {"Power", "Damage", "Click", "Strength", "PowerStrength", "Punch", "Tap"}
    for i = 1, 10 do
        for _, stat in ipairs(stats) do
            fireRemoteByName("Upgrade", stat)
            fireRemoteByName("Upgrade", stat, 1)
            fireRemoteByName("Upgrade", stat, 10)
            fireRemoteByName("BuyUpgrade", stat)
            fireRemoteByName("BuyUpgrade", stat, 10)
            fireRemoteByName("PurchaseUpgrade", stat)
            fireRemoteByName("UpgradePower", stat)
            fireRemoteByName("UpgradePower", 10)
            fireRemoteByName("BuyPower", 10)
            fireRemoteByName("TrainPower", stat)
            fireRemoteByName("Train", stat)
        end
    end
end

-- Enhanced Robust Auto Rebirth function
local function performRebirth()
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
    
    -- 2. Physical Rebirth Pads in Workspace / Map / Base
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
    
    -- 3. Comprehensive Remote Events / Remote Functions
    local remoteNames = {
        "Rebirth", "RebirthRequest", "PerformRebirth", "BuyRebirth", 
        "DoRebirth", "RequestRebirth", "RebirthPlayer", "RebirthSystem", 
        "RebirthEvent", "RebirthFunction", "RebirthServer", "RebirthManager", "ClaimRebirth"
    }
    
    for _, rName in ipairs(remoteNames) do
        fireRemoteByName(rName)
        fireRemoteByName(rName, 1)
        fireRemoteByName(rName, true)
        fireRemoteByName(rName, "1")
    end
end

-- Auto fire proximity prompt of the nearest active tape
local function autoFireClosestPrompt()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closestPrompt = nil
    local minDistance = 25
    
    for _, t in ipairs(getTapes()) do
        local part = (t.parent and t.parent:IsA("BasePart")) and t.parent or (t.parent and (t.parent.PrimaryPart or t.parent:FindFirstChildOfClass("BasePart")))
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
MainFrame.Size = UDim2.new(0, 220, 0, 400)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

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

local HeaderFlat = Instance.new("Frame")
HeaderFlat.Size = UDim2.new(1, 0, 0.5, 0)
HeaderFlat.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFlat.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
HeaderFlat.BorderSizePixel = 0
HeaderFlat.Parent = Header

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
Container.Size = UDim2.new(1, -20, 1, -75)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Container

-- "Find Best Earnings" Instant Button
local FindBestButton = Instance.new("TextButton")
FindBestButton.Name = "FindBestEarnings"
FindBestButton.Size = UDim2.new(1, 0, 0, 28)
FindBestButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FindBestButton.BorderSizePixel = 0
FindBestButton.Text = "Find Best Earnings (Instant)"
FindBestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FindBestButton.Font = Enum.Font.GothamBold
FindBestButton.TextSize = 11
FindBestButton.LayoutOrder = 1
FindBestButton.Parent = Container

local FindBestCorner = Instance.new("UICorner")
FindBestCorner.CornerRadius = UDim.new(0, 6)
FindBestCorner.Parent = FindBestButton

FindBestButton.MouseButton1Click:Connect(function()
    teleportToBestEarnings()
end)

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
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Checkbox = Instance.new("TextButton")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 18, 0, 18)
    Checkbox.Position = UDim2.new(1, -18, 0.5, -9)
    Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Checkbox.BorderSizePixel = 0
    Checkbox.Text = ""
    Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkbox.Font = Enum.Font.GothamBold
    Checkbox.TextSize = 13
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
local toggleClicker = createToggle("AutoClicker", "Auto Clicker", 2)
local toggleBest = createToggle("AutoBest", "Auto Best Earnings", 3)
local toggleOG = createToggle("FindOG", "Find OG", 4)
local toggleExclusive = createToggle("FindExclusive", "Find Exclusive", 5)
local toggleCash = createToggle("CollectCash", "Collect Cash", 6)
local toggleUpgrade = createToggle("UpgradeAll", "Upgrade All", 7)
local togglePower = createToggle("BuyPower10", "Buy Power +10", 8)
local toggleRebirth = createToggle("AutoRebirth", "Auto Rebirth", 9)

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
hookToggle(toggleClicker, function(state) autoClickerActive = state end)
hookToggle(toggleBest, function(state) autoBestActive = state end)
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

-- Keyboard keybind (RightShift / Insert)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert) then
        visible = not visible
        MainFrame.Visible = visible
    end
end)

-- 1. Auto Best Earnings Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoBestActive then
            pcall(function()
                teleportToBestEarnings()
            end)
        end
    end
end)

-- 2. Find OG Loop (Steals OG tape, then returns to base)
task.spawn(function()
    while true do
        task.wait(0.5)
        if findOGActive then
            pcall(function()
                local ogList = getTapesByTag("og")
                if #ogList == 0 then
                    ogList = getTapesByTag("original")
                end
                local og = ogList[1]
                if og then
                    teleportTo(og.parent)
                    
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Bloxlord",
                            Text = "Stealing OG Brainrot: " .. tostring(og.name),
                            Duration = 2
                        })
                    end)
                    
                    local start = tick()
                    while tick() - start < 3.5 and findOGActive do
                        if fireproximityprompt and og.prompt then
                            pcall(function() fireproximityprompt(og.prompt) end)
                        end
                        pcall(autoClick)
                        task.wait(0.1)
                    end
                    
                    local base = getBaseOrSellPad()
                    if base and findOGActive then
                        teleportTo(base)
                        task.wait(1.2)
                    end
                end
            end)
        end
    end
end)

-- 3. Find Exclusive Loop (Steals Exclusive tape, then returns to base)
task.spawn(function()
    while true do
        task.wait(0.5)
        if findExclusiveActive then
            pcall(function()
                local excList = getTapesByTag("exclusive")
                if #excList == 0 then
                    excList = getTapesByTag("secret")
                end
                if #excList == 0 then
                    excList = getTapesByTag("mythic")
                end
                local exc = excList[1]
                if exc then
                    teleportTo(exc.parent)
                    
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Bloxlord",
                            Text = "Stealing Exclusive Brainrot: " .. tostring(exc.name),
                            Duration = 2
                        })
                    end)
                    
                    local start = tick()
                    while tick() - start < 3.5 and findExclusiveActive do
                        if fireproximityprompt and exc.prompt then
                            pcall(function() fireproximityprompt(exc.prompt) end)
                        end
                        pcall(autoClick)
                        task.wait(0.1)
                    end
                    
                    local base = getBaseOrSellPad()
                    if base and findExclusiveActive then
                        teleportTo(base)
                        task.wait(1.2)
                    end
                end
            end)
        end
    end
end)

-- 4. Collect Cash Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if collectCashActive then
            pcall(collectCash)
        end
    end
end)

-- 5. Upgrade All Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if upgradeAllActive then
            pcall(performUpgradeAll)
        end
    end
end)

-- 6. Buy Power +10 Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if buyPower10Active then
            pcall(performBuyPower)
        end
    end
end)

-- 7. Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(2)
        if autoRebirthActive then
            pcall(performRebirth)
        end
    end
end)

-- 8. Universal Auto Clicker Loop
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoClickerActive or autoBestActive or findOGActive or findExclusiveActive or upgradeAllActive or buyPower10Active then
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
