local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false

local Window = Library:CreateWindow({
    Title = "Thinder client Free",
    Footer = "Thinder client Free",
    Icon = 6026568198,
    NotifySide = "Right",
    ShowCustomCursor = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    CornerRadius = 15
})

local Tabs = {
    Defence = Window:AddTab("Defence", "shield"),
    Target = Window:AddTab("Target", "target"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Misc", "layers"),
    Fun = Window:AddTab("Fun", "smile"),
    Keybinds = Window:AddTab("Keybinds", "keyboard"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local PS = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local Workspace = workspace
local Player = PS.LocalPlayer
local Camera = Workspace.CurrentCamera
local CE = RS:WaitForChild("CharacterEvents", 10)
local BeingHeld = Player:WaitForChild("IsHeld", 10)
local StruggleEvent = CE and CE:WaitForChild("Struggle")

local function notify(title, content, duration)
    Library:Notify({ Title = title or "Notification", Description = content or "", Time = duration or 5 })
end

local function sendHubLoadedMessage()
    local message = " Owner Version | Thinder client Free loaded. "
    local sent = false
    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local say = chatEvents:FindFirstChild("SayMessageRequest")
            if say and typeof(say.FireServer) == "function" then
                say:FireServer(message, "All")
                sent = true
            end
        end
    end)
    if not sent then
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = message;
                Color = Color3.fromRGB(255, 170, 0);
                Font = Enum.Font.SourceSansBold;
                FontSize = Enum.FontSize.Size18;
            })
        end)
    end
end
task.spawn(function() task.wait(1) sendHubLoadedMessage() end)

-- Paint helpers
local paintPartsBackup = {}
local paintConnections = {}
local function deleteAllPaintParts()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
            local clone = obj:Clone()
            clone.Archivable = true
            paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent }
            obj:Destroy()
        end
    end
end
local function restorePaintParts()
    for _, data in pairs(paintPartsBackup) do
        if data.clone and data.parent then data.clone.Parent = data.parent end
    end
    paintPartsBackup = {}
end
local function watchNewPaintParts()
    table.insert(paintConnections, Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
            task.defer(function()
                if obj and obj.Parent then
                    local clone = obj:Clone()
                    clone.Archivable = true
                    paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent }
                    obj:Destroy()
                end
            end)
        end
    end))
end
local function disconnectWatchers()
    for _, conn in ipairs(paintConnections) do if conn.Connected then conn:Disconnect() end end
    paintConnections = {}
end
local function setTouchQuery(state)
    local char = Workspace:FindFirstChild(Player.Name)
    if not char then return end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Part") or v:IsA("BasePart") then
            v.CanTouch = state
            v.CanQuery = state
        end
    end
end

-- Anti‑Gucci helpers
local antiGucciConnection, safePosition, restoreFrames = nil, nil, 0
local autoGucciActive = false
local autoGucciActiveTrain = false

local function spawnBlobman()
    local args = { [1] = "CreatureBlobman", [2] = CFrame.new(0, 5000000, 0), [3] = Vector3.new(0, 60, 0) }
    pcall(function() ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(unpack(args)) end)
    local folder = Workspace:WaitForChild(Player.Name .. "SpawnedInToys", 5)
    if folder and folder:FindFirstChild("CreatureBlobman") then
        local blob = folder.CreatureBlobman
        if blob:FindFirstChild("Head") then
            blob.Head.CFrame = CFrame.new(0, 50000, 0)
            blob.Head.Anchored = true
        end
        notify("Success", "Blobman Spawned!", 3)
    end
end
local function startAntiGucci()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    safePosition = rootPart.Position
    local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    local blob = folder and folder:FindFirstChild("CreatureBlobman")
    local seat = blob and blob:FindFirstChild("VehicleSeat")
    if not blob then
        spawnBlobman()
        task.wait(1)
        folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
        blob = folder and folder:FindFirstChild("CreatureBlobman")
        seat = blob and blob:FindFirstChild("VehicleSeat")
    end
    if seat and seat:IsA("VehicleSeat") then
        rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        seat:Sit(humanoid)
    end
    humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoid.Jump and humanoid.Sit then
            restoreFrames = 15
            safePosition = rootPart.Position
        end
    end)
    if antiGucciConnection then antiGucciConnection:Disconnect() end
    antiGucciConnection = R.Heartbeat:Connect(function()
        if not rootPart or not humanoid then return end
        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
        if restoreFrames > 0 then
            rootPart.CFrame = CFrame.new(safePosition)
            restoreFrames = restoreFrames - 1
        end
    end)
    task.spawn(function()
        while humanoid.Sit do task.wait(1) end
        task.wait(0.5)
        rootPart.CFrame = CFrame.new(safePosition)
    end)
end
local function stopAntiGucci()
    if antiGucciConnection then antiGucciConnection:Disconnect() antiGucciConnection = nil end
    local blobFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    if blobFolder and blobFolder:FindFirstChild("CreatureBlobman") then blobFolder.CreatureBlobman:Destroy() end
end

-- Train version
local antiGucciConnectionTrain, safePositionTrain, restoreFramesTrain = nil, nil, 0
local function startAntiGucciTrain()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    safePositionTrain = rootPart.Position
    local folder = workspace.Map.AlwaysHereTweenedObjects
    local train = folder and folder:FindFirstChild("Train")
    local seat
    if train then
        for _, d in ipairs(train:GetDescendants()) do if d:IsA("Seat") then seat = d; break end end
    end
    if seat then
        rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        seat:Sit(humanoid)
    end
    humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoid.Jump and humanoid.Sit then
            restoreFramesTrain = 15
            safePositionTrain = rootPart.Position
        end
    end)
    if antiGucciConnectionTrain then antiGucciConnectionTrain:Disconnect() end
    antiGucciConnectionTrain = R.Heartbeat:Connect(function()
        if not rootPart or not humanoid then return end
        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
        if restoreFramesTrain > 0 then
            rootPart.CFrame = CFrame.new(safePositionTrain)
            restoreFramesTrain = restoreFramesTrain - 1
        end
    end)
    task.spawn(function()
        while humanoid.Sit do task.wait(1) end
        task.wait(0.5)
        rootPart.CFrame = CFrame.new(safePositionTrain)
    end)
end
local function stopAntiGucciTrain()
    if antiGucciConnectionTrain then antiGucciConnectionTrain:Disconnect() antiGucciConnectionTrain = nil end
    local trainFolder = workspace.Map.AlwaysHereTweenedObjects
    if trainFolder and trainFolder:FindFirstChild("Train") then
        pcall(function() game:GetService("Players").LocalPlayer.Character:BreakJoints() end)
    end
end

-- ============================================
-- DEFENCE TAB
-- ============================================
local DefenceLeft = Tabs.Defence:AddLeftGroupbox("Defence Main")
local DefenceRight = Tabs.Defence:AddRightGroupbox("Anti Input Lag")

-- Anti Grab
local autoStruggleConn = nil
DefenceLeft:AddToggle("AntiGrabObsidian", {
    Text = "Anti Grab", Default = false,
    Callback = function(Value)
        if Value then
            if autoStruggleConn then autoStruggleConn:Disconnect() end
            autoStruggleConn = R.Heartbeat:Connect(function()
                local character = Player.Character
                if character and character:FindFirstChild("Head") and character.Head:FindFirstChild("PartOwner") then
                    task.spawn(function()
                        if StruggleEvent then StruggleEvent:FireServer(Player) end
                        pcall(function() ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer() end)
                        for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.Anchored = true end end
                        local isHeld = Player:FindFirstChild("IsHeld")
                        while isHeld and isHeld.Value do task.wait() end
                        for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.Anchored = false end end
                    end)
                end
            end)
        else
            if autoStruggleConn then autoStruggleConn:Disconnect() autoStruggleConn = nil end
            local char = Player.Character
            if char then for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.Anchored = false end end end
        end
    end
})

-- Anti Blobman
local antiBlob1T = false
local function antiBlob1F()
    antiBlob1T = true
    workspace.DescendantAdded:Connect(function(toy)
        if toy.Name == "CreatureBlobman" and antiBlob1T then
            pcall(function() toy.LeftDetector:Destroy() toy.RightDetector:Destroy() end)
        end
    end)
end
DefenceLeft:AddToggle("AntiBlobmanToggle", { Text = "Anti Blobman", Default = false, Callback = function(on) if on then antiBlob1F() else antiBlob1T = false end end })

-- Anti Explosion
local antiExplodeT = false
local function antiExplodeF()
    antiExplodeT = true
    local char = Player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "Part" and antiExplodeT then
            if (model.Position - hrp.Position).Magnitude <= 20 then
                hrp.Anchored = true
                wait(0.01)
                while char["Right Arm"].RagdollLimbPart.CanCollide do wait(0.001) end
                hrp.Anchored = false
            end
        end
    end)
end
DefenceLeft:AddToggle("AntiExplosionToggle", { Text = "Anti Explosion", Default = false, Callback = function(on) if on then antiExplodeF() else antiExplodeT = false end end })

-- Anti Burn
local hookBurnConn
local function hookBurn(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    char.PrimaryPart = hrp
    if hookBurnConn then hookBurnConn:Disconnect() end
    hookBurnConn = hum.FireDebounce.Changed:Connect(function(isBurning)
        if isBurning then
            local oldCF = hrp.CFrame
            local plots = workspace:FindFirstChild("Plots")
            if plots and plots:FindFirstChild("Plot2") then
                local plot2 = plots.Plot2
                local barrier = plot2:FindFirstChild("Barrier")
                local pb = barrier and barrier:FindFirstChild("PlotBarrier")
                if pb and pb:IsA("BasePart") then
                    char:SetPrimaryPartCFrame(pb.CFrame * CFrame.new(0, 6, 0))
                    task.wait(0.3)
                    local firePart = char:FindFirstChild("FirePlayerPart", true)
                    if firePart then
                        for _, obj in ipairs(firePart:GetChildren()) do
                            if obj:IsA("Sound") then obj:Stop() end
                            if obj:IsA("Light") or obj:IsA("ParticleEmitter") then obj.Enabled = false end
                        end
                        if firePart:FindFirstChild("CanBurn") then firePart.CanBurn.Value = false end
                        if hum:FindFirstChild("FireDebounce") then hum.FireDebounce.Value = false end
                    end
                    task.wait(0.6)
                    if char and char.PrimaryPart then char:SetPrimaryPartCFrame(oldCF) end
                end
            end
        end
    end)
end
DefenceLeft:AddToggle("AntiBurnToggle", { Text = "Anti Burn", Default = false, Callback = function(on) if on then hookBurn(Player.Character) elseif hookBurnConn then hookBurnConn:Disconnect() end end })

-- Anti Void
local antiVoidConn
local VOID_THRESHOLD = -50
local SAFE_HEIGHT = 100
DefenceLeft:AddToggle("AntiVoidToggle", {
    Text = "Anti Void", Default = false,
    Callback = function(on)
        if on then
            if antiVoidConn then antiVoidConn:Disconnect() end
            antiVoidConn = R.Heartbeat:Connect(function()
                local char = Player.Character
                if char and char.PrimaryPart and char.PrimaryPart.Position.Y < VOID_THRESHOLD then
                    local pos = char.PrimaryPart.Position
                    char:SetPrimaryPartCFrame(CFrame.new(pos.X, pos.Y + SAFE_HEIGHT, pos.Z))
                    char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
                end
            end)
        else
            if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end
        end
    end
})

-- Anti Sticky
local antiStickyT = false
DefenceLeft:AddToggle("AntiStickyToggle", {
    Text = "Anti Sticky", Default = false,
    Callback = function(Value)
        antiStickyT = Value
        if Player.PlayerScripts:FindFirstChild("StickyPartsTouchDetection") then
            Player.PlayerScripts.StickyPartsTouchDetection.Disabled = Value
        end
    end
})

-- Anti Lag
local createGrabLineCopy, extendGrabLineCopy
local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
if grabFolder then
    local originalCreate = grabFolder:FindFirstChild("CreateGrabLine")
    local originalExtend = grabFolder:FindFirstChild("ExtendGrabLine")
    if originalCreate then createGrabLineCopy = originalCreate:Clone() end
    if originalExtend then extendGrabLineCopy = originalExtend:Clone() end
end
DefenceLeft:AddToggle("AntiLagToggle", {
    Text = "Anti Lag", Default = false,
    Callback = function(Value)
        if Value then
            local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
            if grabFolder then
                local create = grabFolder:FindFirstChild("CreateGrabLine")
                local extend = grabFolder:FindFirstChild("ExtendGrabLine")
                if create and create:IsA("RemoteEvent") then create:Destroy() end
                if extend and extend:IsA("RemoteEvent") then extend:Destroy() end
            end
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Beam") or v.Name:lower():find("line") then v:Destroy() end
            end
        else
            local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
            if grabFolder then
                if createGrabLineCopy and not grabFolder:FindFirstChild("CreateGrabLine") then
                    createGrabLineCopy:Clone().Parent = grabFolder
                end
                if extendGrabLineCopy and not grabFolder:FindFirstChild("ExtendGrabLine") then
                    extendGrabLineCopy:Clone().Parent = grabFolder
                end
            end
        end
    end
})

-- Anti Paint
DefenceLeft:AddToggle("PaintDeleteToggle", {
    Text = "Anti Paint", Default = false,
    Callback = function(state)
        if state then
            deleteAllPaintParts()
            watchNewPaintParts()
            setTouchQuery(false)
        else
            restorePaintParts()
            disconnectWatchers()
            setTouchQuery(true)
        end
    end
})

-- Anti Gucci (Blobman)
DefenceLeft:AddToggle("AutoGucciToggle", {
    Text = "Anti Gucci (Blobman)", Default = false,
    Callback = function(Value)
        autoGucciActive = Value
        if Value then
            startAntiGucci()
        else
            stopAntiGucci()
        end
    end
})

-- Anti Gucci (Train)
DefenceLeft:AddToggle("AutoGucciToggleTrain", {
    Text = "Anti Gucci (Train)", Default = false,
    Callback = function(Value)
        autoGucciActiveTrain = Value
        if Value then
            startAntiGucciTrain()
        else
            stopAntiGucciTrain()
        end
    end
})

-- Anti Kick (Shuriken)
DefenceLeft:AddToggle("ShurikenAntiKick", {
    Text = "Anti Kick", Default = false,
    Callback = function(Value)
        _G.ShurikenAntiKick = Value
        local function ClearKunai()
            local plr = Player
            local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            local destroyrem = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
            if inv and destroyrem then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                        pcall(function() destroyrem:FireServer(v) end)
                    end
                end
            end
        end
        if Value then
            task.spawn(function()
                local plr = Player
                local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
                local spawnRemote = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
                local destroyrem = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
                local canSpawn = plr:WaitForChild("CanSpawnToy")
                local function getHRP()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        return plr.Character.HumanoidRootPart
                    else
                        local character = plr.CharacterAdded:Wait()
                        return character:WaitForChild("HumanoidRootPart")
                    end
                end
                local function CheckForHome()
                    if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return false end
                    for _, v in pairs(workspace.Plots:GetChildren()) do
                        local sign = v:FindFirstChild("PlotSign")
                        local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                        if owners then
                            for _, b in pairs(owners:GetChildren()) do
                                if b.Value == plr.Name then
                                    local folder = workspace.PlotItems:FindFirstChild(v.Name)
                                    if folder then return true, folder end
                                end
                            end
                        end
                    end
                    return false
                end
                local function StickKunai(kunai)
                    if not kunai or not kunai:FindFirstChild("StickyPart") then return end
                    local currentHRP = getHRP()
                    if not currentHRP then return end
                    if kunai:FindFirstChild("SoundPart") then
                        if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= plr.Name then
                            setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
                        end
                    end
                    local firePart = currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart", 5)
                    if firePart then
                        stickyEvent:FireServer(kunai.StickyPart, firePart, CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(90),math.rad(90)))
                    end
                    for _, obj in pairs(kunai:GetChildren()) do
                        if obj.Name == "Pyramid" or obj.Name == "Main" then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = obj.Name=="Pyramid" and Color3.new(0,0,0) or Color3.new(1,1,1)
                            end
                        elseif obj:IsA("BasePart") then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 1
                        end
                    end
                end
                local function SpawnToy(name)
                    local t = tick()
                    while not canSpawn.Value do
                        if not _G.ShurikenAntiKick or tick()-t>5 then return nil end
                        task.wait(0.1)
                    end
                    local currentHRP = getHRP()
                    if currentHRP then
                        task.spawn(function() pcall(function() spawnRemote:InvokeServer(name, currentHRP.CFrame*CFrame.new(0,12,20), Vector3.zero) end) end)
                    end
                    local boolik, house = CheckForHome()
                    local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    if boolik and house then return house:WaitForChild(name,2) end
                    if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) and inv then return inv:WaitForChild(name,2) end
                    return nil
                end
                while _G.ShurikenAntiKick do
                    task.wait(0.005)
                    if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health<=0 then continue end
                    local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    local kunai = inv and inv:FindFirstChild("NinjaShuriken")
                    if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then
                        local boolik, house = CheckForHome()
                        if boolik and house and workspace.Plots:FindFirstChild(house.Name) then
                            local sign = workspace.Plots[house.Name]:FindFirstChild("PlotSign")
                            if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then
                                kunai = SpawnToy("NinjaShuriken")
                                if kunai == nil then continue end
                                kunai.Name = "AntiKick"
                                StickKunai(kunai)
                            end
                        end
                    end
                    if not kunai then
                        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end
                        kunai = SpawnToy("NinjaShuriken")
                        if kunai == nil then continue end
                        kunai.Name = "AntiKick"
                        if not kunai then continue end
                    end
                    repeat
                        if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch then
                            StickKunai(kunai)
                            kunai.Name = "AntiKick"
                        end
                        task.wait(0.3)
                    until not kunai or not _G.ShurikenAntiKick or not kunai:FindFirstChild("StickyPart") or kunai.StickyPart.CanTouch == false or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20
                    if not kunai or not kunai:FindFirstChild("StickyPart") or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 then
                        ClearKunai()
                    end
                    pcall(function()
                        repeat task.wait(0.05) until not _G.ShurikenAntiKick or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or not kunai or not kunai:FindFirstChild("StickyPart") or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1
                        if not kunai or not kunai:FindFirstChild("StickyPart") or (plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) or not kunai.StickyPart:FindFirstChild("StickyWeld").Part1 then
                            ClearKunai()
                        end
                    end)
                end
            end)
        else
            _G.ShurikenAntiKick = false
            ClearKunai()
        end
    end
})

-- Loop TP
local tpActive = false
DefenceLeft:AddToggle("LoopTP", {
    Text = "Loop TP", Default = false,
    Callback = function(Value)
        tpActive = Value
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if Value then
            if hum then hum.PlatformStand = true end
            task.spawn(function()
                while tpActive and hrp do
                    hrp.CFrame = CFrame.new(math.random(-500,500), math.random(30,480), math.random(-500,500))
                    task.wait(0.03)
                end
            end)
        else
            if hum then hum.PlatformStand = false end
        end
    end
})

-- Delete Legs
DefenceLeft:AddButton({
    Text = "Delete Legs",
    Func = function()
        local character = Player.Character
        if not character then 
            character = Player.CharacterAdded:Wait()
        end
        
        local leftLeg = character:FindFirstChild("Left Leg")
        local rightLeg = character:FindFirstChild("Right Leg")
        local torso = character:WaitForChild("Torso") or character:WaitForChild("UpperTorso")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local RagdollRemote = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("RagdollRemote")
        
        if leftLeg and rightLeg and torso and hrp and RagdollRemote then
            local originalFallHeight = workspace.FallenPartsDestroyHeight
            local originalCFrame = torso.CFrame
            
            workspace.FallenPartsDestroyHeight = -100
            RagdollRemote:FireServer(hrp, 2)
            
            task.wait(0.5)
            
            leftLeg.CFrame = CFrame.new(0, -10000, 0)
            rightLeg.CFrame = CFrame.new(0, -10000, 0)
            
            task.wait(0.3)
            
            torso.CFrame = CFrame.new(0, -9970, 0)
            
            task.wait(0.5)
            
            torso.CFrame = originalCFrame
            
            task.wait(0.5)
            workspace.FallenPartsDestroyHeight = originalFallHeight
        end
    end,
    DoubleClick = false
})

-- Break PCLD
DefenceLeft:AddButton({
    Text = "Break PCLD",
    Func = function()
        local serverPos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
        workspace.FallenPartsDestroyHeight = 0/0

        local storedJoints = {}
        local root
        local conn
        local active = false

        local function breakPCLD()
            local char = Player.Character
            if not char then return end
            root = char:WaitForChild("HumanoidRootPart")

            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Motor6D") then
                    storedJoints[v] = v.Part0
                    v.Part0 = nil
                end
            end

            root.CFrame = serverPos

            conn = R.RenderStepped:Connect(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end

        local function restore()
            if conn then conn:Disconnect() conn = nil end

            for m, p0 in pairs(storedJoints) do
                if m and m.Parent then
                    m.Part0 = p0
                end
            end
            storedJoints = {}
        end

        local function press6()
            active = not active
            if active then
                breakPCLD()
            else
                restore()
            end
        end

        press6()
        task.wait(0.12)
        press6()

        Player.CharacterAdded:Once(function()
            task.wait(0.25)
            press6()
            task.wait(0.12)
            press6()
        end)
    end,
    DoubleClick = false
})

-- ============================================
-- ANTI INPUT LAG (В ОТДЕЛЬНОЙ ПРАВОЙ ГРУППЕ)
-- ============================================
DefenceRight:AddToggle("AntiInputLag", {
    Text = "Anti Input Lag", Default = false,
    Callback = function(Value)
        _G.AntiInputLag = Value
        if Value then
            task.spawn(function()
                local plr = Player
                local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
                local burgerFolder = nil
                local currentBurger = nil
                local lastGrab = 0
                
                pcall(function() SpawnRemote:InvokeServer("FoodHamburger", CFrame.new(0, 50000, 0), Vector3.zero) end)
                
                while _G.AntiInputLag do
                    local char = plr.Character
                    if not char then 
                        task.wait(0.1)
                        continue 
                    end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then 
                        task.wait(0.1)
                        continue 
                    end
                    
                    if not burgerFolder or not burgerFolder.Parent then
                        burgerFolder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                        if not burgerFolder then
                            task.wait(0.1)
                            continue
                        end
                    end
                    
                    if not currentBurger or not currentBurger.Parent then
                        currentBurger = burgerFolder:FindFirstChild("FoodHamburger")
                    end
                    
                    if not currentBurger then
                        pcall(function() 
                            SpawnRemote:InvokeServer("FoodHamburger", hrp.CFrame * CFrame.new(0, 3, 0), Vector3.zero) 
                        end)
                        local t = tick()
                        repeat
                            task.wait()
                            currentBurger = burgerFolder:FindFirstChild("FoodHamburger")
                        until currentBurger or tick() - t > 0.2 or not _G.AntiInputLag
                    end
                    
                    if currentBurger and currentBurger.Parent and tick() - lastGrab > 0.05 then
                        local holdPart = currentBurger:FindFirstChild("HoldPart")
                        if holdPart then
                            pcall(function() 
                                holdPart.HoldItemRemoteFunction:InvokeServer(currentBurger, char) 
                            end)
                            lastGrab = tick()
                        end
                    end
                    
                    task.wait()
                end
                
                if currentBurger and currentBurger.Parent then
                    pcall(function() currentBurger:Destroy() end)
                end
            end)
        else
            task.spawn(function()
                local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                if folder then
                    for _, v in ipairs(folder:GetChildren()) do
                        if v.Name == "FoodHamburger" then
                            pcall(function() v:Destroy() end)
                        end
                    end
                end
            end)
        end
    end
})

-- ============================================
-- TARGET TAB
-- ============================================
local TargetLeft = Tabs.Target:AddLeftGroupbox("Target Selection")
local TargetActions = Tabs.Target:AddLeftGroupbox("Target Actions")
local TargetExtra = Tabs.Target:AddRightGroupbox("Extra")

local selectedKickPlayer = nil
local kickLoop = false
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(PS:GetPlayers()) do if plr ~= Player then table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")") end end
    return list
end
local function getPlayerFromSelection(selection)
    if not selection then return nil end
    local username = selection:match("%((.-)%)")
    return username and PS:FindFirstChild(username) or nil
end

TargetLeft:AddDropdown("KickPlayerDropdown", {
    Values = getPlayerList(), Default = 1, Multi = false,
    Text = "Select player for kick",
    Callback = function(Value) selectedKickPlayer = getPlayerFromSelection(Value) end
})

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local currentList = getPlayerList()
            if #currentList > 0 then
                Options.KickPlayerDropdown:SetValues(currentList)
                if selectedKickPlayer and selectedKickPlayer.Parent then
                    local displayText = selectedKickPlayer.DisplayName .. " (" .. selectedKickPlayer.Name .. ")"
                    Options.KickPlayerDropdown:SetValue(displayText)
                else
                    Options.KickPlayerDropdown:SetValue(nil)
                    selectedKickPlayer = nil
                end
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        local mouse = Player:GetMouse()
        local target = mouse.Target
        if target then
            local foundPlayer = nil
            for _, plr in ipairs(PS:GetPlayers()) do
                if plr ~= Player and plr.Character and target:IsDescendantOf(plr.Character) then
                    foundPlayer = plr
                    break
                end
            end
            if foundPlayer then
                selectedKickPlayer = foundPlayer
                Options.KickPlayerDropdown:SetValue(foundPlayer.DisplayName .. " (" .. foundPlayer.Name .. ")")
                notify("Target Selected", "Selected: " .. foundPlayer.Name, 3)
            end
        end
    end
end)

local notifyActive, notifyConnection = false, nil
TargetLeft:AddToggle("JoinedNotifyBtn", {
    Text = "Target Joined Notify", Default = false,
    Callback = function(on)
        notifyActive = on
        if on then
            notify("Radar","Tracking has enable...",3)
            if notifyConnection then notifyConnection:Disconnect() end
            notifyConnection = PS.PlayerAdded:Connect(function(newPlayer)
                if not notifyActive then return end
                local detected, reason = false, ""
                if selectedKickPlayer and selectedKickPlayer.Name == newPlayer.Name then
                    detected = true; reason = "[Main Target]"
                end
                if detected then
                    notify("detected", reason .. " detected: " .. newPlayer.Name, 8)
                    local sound = Instance.new("Sound", workspace)
                    sound.SoundId = "rbxassetid://7128958209"
                    sound.Volume = 2
                    sound:Play()
                    game:GetService("Debris"):AddItem(sound, 3)
                end
            end)
        else
            if notifyConnection then notifyConnection:Disconnect(); notifyConnection = nil end
            notify("Radar","Tracking Disabled",2)
        end
    end
})

-- TARGET ACTIONS
local function runBlobmanKick()
    if kickLoop then return end; kickLoop = true
    task.spawn(function()
        local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
        local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
        local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Root = Character:WaitForChild("HumanoidRootPart")
        local savedPos = Root.CFrame; local dragging = false; local grabStartTime = 0; local checkStartTime = 0
        local bodyPos = nil; local bodyGyro = nil
        local function cleanupBodies() pcall(function() if bodyPos then bodyPos:Destroy(); bodyPos = nil end; if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end end) end
        local function createBodies(targetRoot, pos)
            cleanupBodies()
            for _, v in pairs(targetRoot:GetChildren()) do if v:IsA("BodyPosition") or v:IsA("BodyGyro") then v:Destroy() end end
            bodyPos = Instance.new("BodyPosition"); bodyPos.MaxForce = Vector3.new(9e9, 9e9, 9e9); bodyPos.D = 100; bodyPos.Position = pos; bodyPos.Parent = targetRoot
            bodyGyro = Instance.new("BodyGyro"); bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bodyGyro.D = 100; bodyGyro.CFrame = CFrame.new(pos); bodyGyro.Parent = targetRoot
        end
        while kickLoop do
            local target = selectedKickPlayer
            if not target or not target.Parent then cleanupBodies(); break end
            Character = Player.Character; Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local tChar = target.Character; local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart"); local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 and Root then
                if not dragging then
                    Root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3); cleanupBodies(); checkStartTime = 0
                    pcall(function() tHum.PlatformStand = true; tHum.Sit = true; SetNetworkOwner:FireServer(tRoot, tRoot.CFrame); SetNetworkOwner:FireServer(tRoot, tRoot.CFrame); DestroyGrabLine:FireServer(tRoot) end)
                    Root.AssemblyLinearVelocity = Vector3.zero; Root.AssemblyAngularVelocity = Vector3.zero
                    if grabStartTime == 0 then grabStartTime = tick() end
                    if tick() - grabStartTime > 0.35 then dragging = true; grabStartTime = 0; checkStartTime = tick(); local lockPos = savedPos * CFrame.new(0, 17, 0); createBodies(tRoot, lockPos.Position) end
                else
                    Root.CFrame = savedPos; local lockPos = savedPos * CFrame.new(0, 17, 0)
                    Root.AssemblyLinearVelocity = Vector3.zero; Root.AssemblyAngularVelocity = Vector3.zero
                    if bodyPos and bodyPos.Parent then bodyPos.Position = lockPos.Position; if bodyGyro then bodyGyro.CFrame = lockPos end else createBodies(tRoot, lockPos.Position) end
                    tHum.PlatformStand = true
                    pcall(function() SetNetworkOwner:FireServer(tRoot, lockPos); SetNetworkOwner:FireServer(tRoot, lockPos); DestroyGrabLine:FireServer(tRoot) end)
                    if checkStartTime > 0 and tick() - checkStartTime > 0.30 then
                        local currentDist = (tRoot.Position - lockPos.Position).Magnitude
                        if currentDist > 10 then dragging = false; grabStartTime = 0; checkStartTime = 0; cleanupBodies(); Root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3) else checkStartTime = tick() end
                    end
                end
            else dragging = false; grabStartTime = 0; checkStartTime = 0; cleanupBodies() end
            R.Heartbeat:Wait()
        end
        cleanupBodies(); if Root then Root.CFrame = savedPos end
        if selectedKickPlayer and selectedKickPlayer.Character then if selectedKickPlayer.Character:FindFirstChild("Humanoid") then local hum = selectedKickPlayer.Character.Humanoid; pcall(function() hum.PlatformStand = false; hum.Sit = false; hum.AutoRotate = true; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end
        Toggles.LoopKickFromFrendly:SetValue(false)
    end)
end

TargetActions:AddToggle("LoopKickFromFrendly", {
    Text = "Loop Kick",
    Default = false,
    Callback = function(State)
        if State then 
            runBlobmanKick() 
        else 
            kickLoop = false 
        end
    end
})

local kickLoopEnabled = false
TargetActions:AddToggle("KickRagdollGrab", {
    Text = "Kick (ragdoll grab)", Default = false,
    Callback = function(on)
        kickLoopEnabled = on
        if not on then return end
        task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local myChar = Player.Character or Player.CharacterAdded:Wait()
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then Toggles.KickRagdollGrab:SetValue(false); return end
            local savedPos = myRoot.CFrame
            local dragging, grabStart = false, 0
            while kickLoopEnabled do
                local target = selectedKickPlayer
                if not target or not target.Parent then break end
                local tChar = target.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health>0 then
                    tRoot.AssemblyLinearVelocity = Vector3.zero
                    tRoot.AssemblyAngularVelocity = Vector3.zero
                    tRoot.Velocity = Vector3.zero
                    if not dragging then
                        myRoot.CFrame = tRoot.CFrame
                        pcall(function()
                            tHum.PlatformStand = true; tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                        if grabStart==0 then grabStart = tick() end
                        if tick()-grabStart > 0.15 then dragging = true; grabStart = 0; myRoot.CFrame = savedPos end
                    else
                        local lockCFrame = CFrame.new(savedPos.Position+Vector3.new(0,7,0)) * CFrame.Angles(math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), math.rad(math.random(-180,180)))
                        tRoot.CFrame = tRoot.CFrame:Lerp(lockCFrame, 0.2)
                        tRoot.Velocity = Vector3.zero; tRoot.RotVelocity = Vector3.zero
                        pcall(function()
                            tHum.PlatformStand = true; tHum.Sit = false
                            GE.SetNetworkOwner:FireServer(tRoot, tRoot.CFrame)
                            GE.DestroyGrabLine:FireServer(tRoot)
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    dragging = false; grabStart = 0
                end
                R.Heartbeat:Wait()
            end
            if myRoot then myRoot.CFrame = savedPos; myRoot.Velocity = Vector3.zero end
            kickLoopEnabled = false
            Toggles.KickRagdollGrab:SetValue(false)
        end)
    end
})

TargetActions:AddButton({
    Text = "Bring",
    Func = function()
        if not selectedKickPlayer then notify("Error", "No player selected", 3); return end
        local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedKickPlayer.Character and selectedKickPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            targetRoot.CFrame = myRoot.CFrame + Vector3.new(0, 3, 0)
            notify("Bring", "Player brought to you", 2)
        end
    end
})

local blobKickActive = false
local blobKickTask = nil

TargetActions:AddToggle("BlobKick", {
    Text = "Blobkick",
    Default = false,
    Callback = function(on)
        blobKickActive = on
        if not on then return end
        blobKickTask = task.spawn(function()
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local myChar = Player.Character or Player.CharacterAdded:Wait()
            local myHum = myChar:FindFirstChild("Humanoid")
            local seat = myHum and myHum.SeatPart
            if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                notify("Error", "Sit on Blobman first!", 3)
                Toggles.BlobKick:SetValue(false)
                return
            end
            local blob = seat.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot.CFrame
            
            local target = selectedKickPlayer
            if target and target.Character then
                local tChar = target.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tRoot and blobRoot then
                    local bringStart = tick()
                    while tick()-bringStart < 0.35 and blobKickActive do
                        blobRoot.CFrame = tRoot.CFrame
                        blobRoot.Velocity = Vector3.zero
                        pcall(function()
                            if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                        end)
                        R.Heartbeat:Wait()
                    end
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    task.wait(0.05)
                end
            end
            
            local packetTimer = 0
            while blobKickActive do
                if not selectedKickPlayer or not selectedKickPlayer.Parent or not selectedKickPlayer.Character then break end
                local tChar = selectedKickPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health>0 and blobRoot then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    local lockPos = SavedPos * CFrame.new(0,23,0)
                    tRoot.CFrame = lockPos
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    if tick()-packetTimer > 0.05 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                            if R_Det then
                                local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                if weld then CD:FireServer(weld) end
                            end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end
                if not blobKickActive then break end
                R.Heartbeat:Wait()
            end
            blobKickActive = false
            Toggles.BlobKick:SetValue(false)
            if blobRoot then
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
            end
        end)
    end
})

-- Destroy Gucci
local DestroyTargetGucciActive = false
TargetExtra:AddToggle("DestroyTargetGucci", {
    Text = "Destroy Gucci (sit)", Default = false,
    Callback = function(Value)
        DestroyTargetGucciActive = Value
        if Value then
            if not selectedKickPlayer then notify("Error","Error",3); Toggles.DestroyTargetGucci:SetValue(false); return end
            local char = Player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local SafeSpot = root.CFrame
            local RunService = game:GetService("RunService")
            local folderName = selectedKickPlayer.Name .. "SpawnedInToys"
            notify("System","spawn toy "..folderName,3)
            task.spawn(function()
                while DestroyTargetGucciActive do
                    if not selectedKickPlayer or not selectedKickPlayer.Parent then
                        notify("System","Activated",3)
                        DestroyTargetGucciActive = false
                        Toggles.DestroyTargetGucci:SetValue(false)
                        break
                    end
                    local toysFolder = workspace:FindFirstChild(folderName)
                    if not toysFolder then task.wait(1) else
                        for _, obj in ipairs(toysFolder:GetChildren()) do
                            if not DestroyTargetGucciActive then break end
                            if obj.Name == "CreatureBlobman" then
                                local seat = obj:FindFirstChild("VehicleSeat") or obj:FindFirstChildWhichIsA("VehicleSeat",true)
                                if seat then
                                    local myChar = Player.Character
                                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                    local myHum = myChar and myChar:FindFirstChild("Humanoid")
                                    if myRoot and myHum and myHum.SeatPart ~= seat then
                                        local magnetConnection = RunService.Stepped:Connect(function()
                                            if myRoot and seat then
                                                myRoot.CFrame = seat.CFrame
                                                myRoot.Velocity = Vector3.zero
                                                if obj.PrimaryPart then obj.PrimaryPart.Velocity = Vector3.zero; obj.PrimaryPart.RotVelocity = Vector3.zero end
                                            end
                                        end)
                                        local sitStart = tick()
                                        while tick()-sitStart < 1 and DestroyTargetGucciActive and myHum.SeatPart ~= seat do
                                            seat:Sit(myHum)
                                            task.wait()
                                        end
                                        if magnetConnection then magnetConnection:Disconnect() end
                                        if myHum.SeatPart == seat then
                                            task.wait(0.3)
                                            myHum.Sit = false; myHum.Jump = true
                                            task.wait(0.05)
                                            myRoot.CFrame = SafeSpot; myRoot.Velocity = Vector3.zero
                                            notify("Success","gucci has removed",1)
                                            task.wait(0.5)
                                        else
                                            myRoot.CFrame = SafeSpot
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            DestroyTargetGucciActive = false
            notify("System","remove Gucci off",2)
        end
    end
})

-- Remove Anti Input Lag
local AllowedItems = {
    FoodHamburger = true, FoodCoconut = true, FoodPizzaCheese = true, FoodPizzaPepperoni = true,
    FoodHotdog = true, FoodMushroomPoison = true, FoodBread = true, FoodDippyEgg = true,
    FoodMayonnaise = true, FoodFrenchFries = true, FoodMeatStick = true, FoodDonut = true,
    FoodCakePink = true,
    InstrumentGuitarBanjo = true, InstrumentGuitarViolin = true, InstrumentGuitarUkulele = true,
    InstrumentWoodwindSaxophone = true, InstrumentWoodwindOcarina = true,
    InstrumentBrassVuvuzelaQwizik = true, InstrumentBrassTrumpet = true,
    InstrumentDrumBongos = true, InstrumentDrumSnare = true, InstrumentPianoMelodica = true,
    InstrumentVoiceMicrophone = true,
    CupMugWhite = true, CupMugBrown = true,
    PoopPile = true, PoopPileSparkle = true,
}
local antiAntiLagEnabled = false
TargetExtra:AddToggle("RemoveAntiInputLag", {
    Text = "Remove Anti Input Lag", Default = false,
    Callback = function(on)
        antiAntiLagEnabled = on
        if not on then antiAntiLagEnabled = false; return end
        task.spawn(function()
            local plr = Player
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local items = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                if AllowedItems[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
                    items[#items+1] = v
                end
            end
            workspace.DescendantAdded:Connect(function(obj)
                if AllowedItems[obj.Name] and obj:IsA("Model") then
                    task.spawn(function()
                        local hp = obj:WaitForChild("HoldPart",3)
                        if hp then items[#items+1] = obj end
                    end)
                end
            end)
            while antiAntiLagEnabled do
                for i = #items,1,-1 do
                    local b = items[i]
                    if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
                        table.remove(items,i)
                    else
                        local hp = b.HoldPart
                        pcall(function() hp.HoldItemRemoteFunction:InvokeServer(b, char) end)
                        task.wait()
                        pcall(function() hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(hrp.Position+Vector3.new(0,-2000,0)), Vector3.zero) end)
                    end
                end
                task.wait()
            end
        end)
    end
})

-- Remove Anti Kick
local antiAntiKickActive = false
TargetExtra:AddToggle("DestroyAntiKickToggle", {
    Text = "Remove Anti Kick", Default = false,
    Callback = function(Value)
        antiAntiKickActive = Value
        if Value then
            task.spawn(function()
                local SetNetOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner
                local lp = Player
                local function invis_touch(part, cf) SetNetOwner:FireServer(part, cf) end
                local function CheckAndYeet(toy)
                    local part = toy:FindFirstChild("SoundPart")
                    if part then
                        invis_touch(part, part.CFrame)
                        if part:FindFirstChild("PartOwner") and part.PartOwner.Value == lp.Name then
                            part.CFrame = CFrame.new(0,1000,0)
                        end
                    end
                end
                while antiAntiKickActive do
                    local target = selectedKickPlayer
                    if target then
                        local spawned = workspace:FindFirstChild(target.Name .. "SpawnedInToys")
                        if spawned then
                            if spawned:FindFirstChild("NinjaKunai") then CheckAndYeet(spawned.NinjaKunai) end
                            if spawned:FindFirstChild("NinjaShuriken") then CheckAndYeet(spawned.NinjaShuriken) end
                            if spawned:FindFirstChild("AntiKick") then CheckAndYeet(spawned.AntiKick) end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            antiAntiKickActive = false
        end
    end
})

-- Remove Anti Kick Aura
local removeAntiKickAuraActive = false
TargetExtra:AddToggle("RemoveAntiKickAura", {
    Text = "Remove Anti Kick Aura",
    Default = false,
    Callback = function(on)
        removeAntiKickAuraActive = on
        if not on then return end
        task.spawn(function()
            local SetNetOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner
            while removeAntiKickAuraActive do
                for _, target in ipairs(PS:GetPlayers()) do
                    if target ~= Player then
                        local spawned = workspace:FindFirstChild(target.Name .. "SpawnedInToys")
                        if spawned then
                            for _, toyName in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                                local toy = spawned:FindFirstChild(toyName)
                                if toy then
                                    local part = toy:FindFirstChild("SoundPart")
                                    if part then
                                        pcall(function() SetNetOwner:FireServer(part, part.CFrame) end)
                                        if part:FindFirstChild("PartOwner") and part.PartOwner.Value == Player.Name then
                                            part.CFrame = CFrame.new(0, 1000, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- ============================================
-- VISUALS TAB
-- ============================================
local VisualsLeft = Tabs.Visuals:AddLeftGroupbox("Visuals")
local VisualsRight = Tabs.Visuals:AddRightGroupbox("ESP")

local function enableThirdPerson()
    Player.CameraMode = Enum.CameraMode.Classic
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Player.Character:WaitForChild("Humanoid")
    Player.CameraMaxZoomDistance = 1e10
    Player.CameraMinZoomDistance = 0.5
end
local function disableThirdPerson()
    Player.CameraMode = Enum.CameraMode.LockFirstPerson
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Player.Character:WaitForChild("Humanoid")
    Player.CameraMaxZoomDistance = 0
    Player.CameraMinZoomDistance = 0
end

VisualsLeft:AddToggle("ThirdPersonToggle", { Text = "3rd Person View", Default = false, Callback = function(v) if v then enableThirdPerson() else disableThirdPerson() end end })

VisualsLeft:AddSlider("FOVSlider", { Text = "FOV", Default = 90, Min = 1, Max = 120, Rounding = 0, Suffix = "°", Callback = function(v) Camera.FieldOfView = v end })

-- PCLD Outline ESP
local espEnabled = false
local espBoxes = {}
local espColor = Color3.fromRGB(255, 255, 255)
local espTargetNames = {"partesp", "playercharacterlocationdetector"}

local function IsTargetESP(o)
    if not o:IsA("BasePart") then return false end
    for _, n in ipairs(espTargetNames) do
        if string.lower(o.Name) == string.lower(n) then return true end
    end
    return false
end

local function AddOutlineESP(o)
    if espBoxes[o] then 
        espBoxes[o].Color3 = espColor
        return 
    end
    
    local outline = Instance.new("SelectionBox")
    outline.Adornee = o
    outline.Color3 = espColor
    outline.LineThickness = 0.05
    outline.Transparency = 0.5
    outline.SurfaceTransparency = 1
    outline.SurfaceColor3 = espColor
    outline.Parent = CoreGui or game:GetService("CoreGui")
    
    espBoxes[o] = outline
    
    o.AncestryChanged:Connect(function(_, parent)
        if not parent and espBoxes[o] then
            espBoxes[o]:Destroy()
            espBoxes[o] = nil
        end
    end)
end

local function RemoveAllESP()
    for obj, box in pairs(espBoxes) do
        if box then 
            pcall(function() box:Destroy() end)
        end
    end
    espBoxes = {}
end

local function ScanForTargets()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if espEnabled and IsTargetESP(obj) then
            AddOutlineESP(obj)
        end
    end
end

VisualsRight:AddToggle("PCLDToggle", { 
    Text = "PCLD Outline ESP", 
    Default = false, 
    Callback = function(V) 
        espEnabled = V
        if V then 
            ScanForTargets()
            workspace.DescendantAdded:Connect(function(obj)
                if espEnabled and IsTargetESP(obj) then
                    AddOutlineESP(obj)
                end
            end)
        else 
            RemoveAllESP()
        end 
    end 
}):AddColorPicker("PCLDColor", { 
    Default = Color3.fromRGB(255, 255, 255), 
    Title = "Outline Color", 
    Callback = function(V) 
        espColor = V
        for obj, box in pairs(espBoxes) do
            if box then 
                box.Color3 = espColor
            end
        end 
    end 
})

-- Nickname ESP
VisualsRight:AddToggle("NicknameESP", {
    Text = "Nickname Esp", Default = false,
    Callback = function(Value)
        local function createESP(plr)
            if plr == Player then return end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                if hrp:FindFirstChild("NameESP") then return end
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "NameESP"
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0,100,0,30)
                billboard.StudsOffset = Vector3.new(0,3,0)
                billboard.AlwaysOnTop = true
                billboard.Parent = hrp
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1,0,1,0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = plr.Name
                textLabel.TextColor3 = Color3.new(1,1,1)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextScaled = true
                textLabel.Parent = billboard
            end
        end
        if Value then
            for _, plr in ipairs(PS:GetPlayers()) do createESP(plr) end
            PS.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(function() createESP(plr) end) end)
        else
            for _, plr in ipairs(PS:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    if hrp:FindFirstChild("NameESP") then hrp.NameESP:Destroy() end
                end
            end
        end
    end
})

-- ============================================
-- MISC TAB
-- ============================================
local MiscLeft = Tabs.Misc:AddLeftGroupbox("Miscellaneous")
local MiscRight = Tabs.Misc:AddRightGroupbox("Movement")
local MiscExtra = Tabs.Misc:AddLeftGroupbox("Back Items")
local mouse = Player:GetMouse()

-- Triggerbot
local Triggerbot = { Enabled = false, canGrab = true, maxDistance = 20, preGrabDelay = 0.00001, postGrabDelay = 0.05, lastTarget = nil, lastHitTime = 0, targetMemoryDuration = 0.1, checkThrottle = 0.008, lastCheck = 0, Connection = nil }
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
task.spawn(function()
    local success, result = pcall(function() return RS.GamepassEvents.CheckForGamepass:InvokeServer(20837132) end)
    if success and result then Triggerbot.maxDistance = 29.3 end
end)
if RS:FindFirstChild("GamepassEvents") and RS.GamepassEvents:FindFirstChild("FurtherReachBoughtNotifier") then
    RS.GamepassEvents.FurtherReachBoughtNotifier.OnClientEvent:Connect(function() Triggerbot.maxDistance = 29.3 end)
end
function Triggerbot:GetTarget()
    local c = Player.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    if Workspace:FindFirstChild("GrabParts") then return end
    local origin, dir = Camera.CFrame.Position, Camera.CFrame.LookVector
    rayParams.FilterDescendantsInstances = { c, Workspace.Terrain }
    local result = Workspace:Raycast(origin, dir*1000, rayParams)
    if not result then
        local dirs = { dir, (dir+Vector3.new(0,0.075,0)).Unit, (dir-Vector3.new(0,0.075,0)).Unit }
        for _, d in ipairs(dirs) do result = Workspace:Raycast(origin, d*1000, rayParams); if result then break end end
    end
    if not result then return end
    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if not model or not model:FindFirstChildOfClass("Humanoid") or model == c then return end
    local hum = model:FindFirstChildOfClass("Humanoid"); if hum.Health <= 0 then return end
    local root = model:FindFirstChild("HumanoidRootPart"); if not root then return end
    if (c.HumanoidRootPart.Position - root.Position).Magnitude > self.maxDistance then return end
    return model
end
function Triggerbot:OnHeartbeat()
    if not self.Enabled or not self.canGrab or UserInputService:GetFocusedTextBox() or tick()-self.lastCheck < self.checkThrottle then return end
    self.lastCheck = tick()
    local t = self:GetTarget()
    if t then self.lastTarget = t; self.lastHitTime = tick()
    elseif self.lastTarget and tick()-self.lastHitTime > self.targetMemoryDuration then self.lastTarget = nil end
    local c = Player.Character; local root = self.lastTarget and self.lastTarget:FindFirstChild("HumanoidRootPart")
    if not (self.lastTarget and c and c:FindFirstChild("HumanoidRootPart") and root) or (c.HumanoidRootPart.Position - root.Position).Magnitude > self.maxDistance then self.lastTarget = nil; return end
    if self.lastTarget then
        self.canGrab = false
        task.spawn(function()
            task.wait(self.preGrabDelay); pcall(mouse1press)
            local t0 = tick()
            repeat task.wait(0.02) until not Workspace:FindFirstChild("GrabParts") or tick()-t0 > 1.6
            task.wait(self.postGrabDelay); self.canGrab = true; self.lastTarget = nil
        end)
    end
end

MiscLeft:AddToggle("TriggerbotToggle", { Text = "Trigger Bot", Default = false,
    Callback = function(v) Triggerbot.Enabled = v
        if v and not Triggerbot.Connection then Triggerbot.Connection = R.Heartbeat:Connect(function() Triggerbot:OnHeartbeat() end)
        elseif not v and Triggerbot.Connection then Triggerbot.Connection:Disconnect(); Triggerbot.Connection = nil end
    end
})

MiscLeft:AddToggle("NoBarrierCollision", {
    Text = "Ignore House Barriers", Default = false,
    Callback = function(Value)
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local barrier = plot:FindFirstChild("Barrier")
                if barrier then for _, obj in ipairs(barrier:GetDescendants()) do if obj:IsA("BasePart") then obj.CanCollide = not Value end end end
            end
        end
    end
})

MiscLeft:AddToggle("AutoResetToggle", {
    Text = "Auto Reset", Default = false,
    Callback = function(on)
        autoResetEnabled = on
        if not on then autoResetEnabled = false; return end
        task.spawn(function() while autoResetEnabled do local hum = Player.Character and Player.Character:FindFirstChild("Humanoid"); if hum and hum.Health>0 then hum.Health = 0 end; task.wait(0.5) end end)
    end
})

-- Packet Lag
local PacketSpamAmount = 100
MiscLeft:AddSlider("PacketAmountSlider", { Text = "Packet Lag Amount", Default = 100, Min = 10, Max = 5000, Rounding = 0, Callback = function(v) PacketSpamAmount = v end })
MiscLeft:AddToggle("PacketLagToggle", {
    Text = "Packet Lag", Default = false,
    Callback = function(Value)
        _G.PacketLagActive = Value
        if Value then
            task.spawn(function()
                for _, e in pairs(Players:GetPlayers()) do if e.Name == "MaybeFlashh" then return end end
                local GrabEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("ExtendGrabLine")
                while _G.PacketLagActive do pcall(function() GrabEvent:FireServer(string.rep("Balls Balls Balls Balls", PacketSpamAmount)) end); task.wait() end
            end)
        else _G.PacketLagActive = false end
    end
})

-- Speed Boost
local speedEnabled = false
local speedValue = 50
local speedConnection = nil

local function applySpeed()
    if not speedEnabled then return end
    pcall(function()
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local moveDirection = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * speedValue
            root.AssemblyLinearVelocity = Vector3.new(moveDirection.X, root.AssemblyLinearVelocity.Y, moveDirection.Z)
        end
    end)
end

MiscRight:AddToggle("SpeedToggle", {
    Text = "Speed Boost",
    Default = false,
    Callback = function(State)
        speedEnabled = State
        if State then
            speedConnection = R.Heartbeat:Connect(applySpeed)
        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
        end
    end
})

MiscRight:AddSlider("SpeedSlider", {
    Text = "Speed Value",
    Default = 50,
    Min = 16,
    Max = 3000,
    Rounding = 0,
    Callback = function(Value)
        speedValue = Value
    end
})

-- Jump Power
local jumpEnabled = false
local jumpValue = 50
local jumpConnection = nil

MiscRight:AddToggle("JumpToggle", {
    Text = "Jump Power",
    Default = false,
    Callback = function(State)
        jumpEnabled = State
        if State then
            jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    pcall(function()
                        local char = Player.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpValue, root.AssemblyLinearVelocity.Z)
                            end
                        end
                    end)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

MiscRight:AddSlider("JumpSlider", {
    Text = "Jump Value",
    Default = 50,
    Min = 50,
    Max = 3000,
    Rounding = 0,
    Callback = function(Value)
        jumpValue = Value
    end
})

-- Spin Bot
local spinEnabled = false
local spinSpeed2 = 10
local spinConnection = nil

MiscRight:AddToggle("SpinBotToggle", {
    Text = "Spin Bot",
    Default = false,
    Callback = function(State)
        spinEnabled = State
        if State then
            spinConnection = R.Heartbeat:Connect(function()
                pcall(function()
                    local char = Player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed2), 0)
                        end
                    end
                end)
            end)
        else
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
})

MiscRight:AddSlider("SpinBotSpeed", {
    Text = "Spin Speed",
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        spinSpeed2 = Value
    end
})

-- Infinite Jump
local infJump = false
MiscRight:AddToggle("infJumpToggle", { Text = "Infinite Jump", Default = false, Callback = function(v) infJump = v end })
UserInputService.JumpRequest:Connect(function()
    if infJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Grab Effects
local grabEffectsEnabled = false
local selectedEffect = "Neon"
local effectConnections = {}

local effectsList = {
    ["🔮 Neon"] = "Neon",
    ["🔥 Fire"] = "Fire",
    ["🌈 Rainbow"] = "Rainbow",
    ["✨ Glow"] = "Glow",
    ["💜 Purple"] = "Purple",
    ["👑 Gold"] = "Gold",
    ["❄️ Ice"] = "Ice",
    ["💚 Pulse"] = "Pulse",
}

local function clearEffects(part)
    if not part then return end
    for _, child in ipairs(part:GetChildren()) do
        if string.find(child.Name, "GrabEffect_") then
            pcall(function() child:Destroy() end)
        end
    end
end

local function applyEffectToPart(part, effectType)
    if not part or not part.Parent then return end
    clearEffects(part)
    
    if effectType == "Neon" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        particle.Rate = 60
        particle.Lifetime = NumberRange.new(0.5)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(4)
        particle.Size = NumberSequence.new(0.5)
        
    elseif effectType == "Fire" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/flame_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 150, 0))
        particle.Rate = 80
        particle.Lifetime = NumberRange.new(0.4)
        particle.SpreadAngle = Vector2.new(180, 180)
        particle.Speed = NumberRange.new(5)
        particle.Size = NumberSequence.new(0.6)
        
    elseif effectType == "Rainbow" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/circle_main.dds"
        particle.Rate = 70
        particle.Lifetime = NumberRange.new(0.4)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(4)
        particle.Size = NumberSequence.new(0.4)
        task.spawn(function()
            local hue = 0
            while grabEffectsEnabled and part and part.Parent do
                hue = (hue + 0.03) % 1
                pcall(function() particle.Color = ColorSequence.new(Color3.fromHSV(hue, 1, 1)) end)
                task.wait(0.05)
            end
        end)
        
    elseif effectType == "Glow" then
        local light = Instance.new("PointLight", part)
        light.Name = "GrabEffect_Light"
        light.Color = Color3.fromRGB(255, 255, 255)
        light.Range = 10
        light.Brightness = 2
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/glow_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        particle.Rate = 50
        particle.Lifetime = NumberRange.new(0.3)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(2)
        particle.Size = NumberSequence.new(0.4)
        
    elseif effectType == "Purple" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/stars_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(155, 0, 255), Color3.fromRGB(200, 100, 255))
        particle.Rate = 70
        particle.Lifetime = NumberRange.new(0.5)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(3)
        particle.Size = NumberSequence.new(0.5)
        local light = Instance.new("PointLight", part)
        light.Name = "GrabEffect_Light"
        light.Color = Color3.fromRGB(155, 0, 255)
        light.Range = 8
        light.Brightness = 1.5
        
    elseif effectType == "Gold" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/confetti_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 240, 150))
        particle.Rate = 100
        particle.Lifetime = NumberRange.new(0.4)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(5)
        particle.Size = NumberSequence.new(0.3)
        
    elseif effectType == "Ice" then
        local att = Instance.new("Attachment", part)
        att.Name = "GrabEffect_Attachment"
        local particle = Instance.new("ParticleEmitter", att)
        particle.Name = "GrabEffect_Particle"
        particle.Texture = "rbxasset://textures/particles/snowflake_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(150, 230, 255))
        particle.Rate = 60
        particle.Lifetime = NumberRange.new(0.6)
        particle.SpreadAngle = Vector2.new(360, 360)
        particle.Speed = NumberRange.new(3)
        particle.Size = NumberSequence.new(0.4)
        
    elseif effectType == "Pulse" then
        local box = Instance.new("SelectionBox", part)
        box.Name = "GrabEffect_SelectionBox"
        box.Color3 = Color3.fromRGB(0, 255, 0)
        box.LineThickness = 0.15
        box.Transparency = 0.3
        box.SurfaceTransparency = 0.8
        task.spawn(function()
            local pulse = 0
            local direction = 0.03
            while grabEffectsEnabled and part and part.Parent do
                pulse = pulse + direction
                if pulse >= 0.5 or pulse <= 0 then direction = -direction end
                pcall(function() box.Transparency = pulse end)
                task.wait(0.03)
            end
        end)
    end
end

local function applyEffectToAllGrabParts()
    if not grabEffectsEnabled then return end
    local grabParts = workspace:FindFirstChild("GrabParts")
    if grabParts then
        for _, part in ipairs(grabParts:GetChildren()) do
            if part:IsA("BasePart") then
                applyEffectToPart(part, selectedEffect)
            end
        end
    end
end

local function setupGrabWatcher()
    local conn = workspace.ChildAdded:Connect(function(child)
        if child.Name == "GrabParts" and grabEffectsEnabled then
            task.wait(0.05)
            for _, part in ipairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    applyEffectToPart(part, selectedEffect)
                end
            end
            local descendantConn = child.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") and grabEffectsEnabled then
                    applyEffectToPart(desc, selectedEffect)
                end
            end)
            table.insert(effectConnections, descendantConn)
        end
    end)
    table.insert(effectConnections, conn)
end

local GrabEffectsGroup = Tabs.Misc:AddRightGroupbox("Grab Effects")

GrabEffectsGroup:AddToggle("GrabEffectToggle", {
    Text = "Enable Grab Effects",
    Default = false,
    Callback = function(Value)
        grabEffectsEnabled = Value
        if Value then
            applyEffectToAllGrabParts()
            setupGrabWatcher()
        else
            for _, conn in ipairs(effectConnections) do
                pcall(function() if conn then conn:Disconnect() end end)
            end
            effectConnections = {}
            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts then
                for _, part in ipairs(grabParts:GetChildren()) do
                    clearEffects(part)
                end
            end
        end
    end
})

GrabEffectsGroup:AddDropdown("GrabEffectDropdown", {
    Text = "Effect Type",
    Values = {"🔮 Neon", "🔥 Fire", "🌈 Rainbow", "✨ Glow", "💜 Purple", "👑 Gold", "❄️ Ice", "💚 Pulse"},
    Default = 1,
    Callback = function(Value)
        for k, v in pairs(effectsList) do
            if k == Value then
                selectedEffect = v
                break
            end
        end
        if grabEffectsEnabled then
            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts then
                for _, part in ipairs(grabParts:GetChildren()) do
                    if part:IsA("BasePart") then
                        applyEffectToPart(part, selectedEffect)
                    end
                end
            end
        end
    end
})

-- Back Items
local boomboxOnBack = false
local boomboxModel = nil
local boomboxWeld = nil

local function attachBoombox()
    local char = Player.Character
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    
    local source = workspace:FindFirstChild("antipsixozSpawnedInToys")
    if source then
        source = source:FindFirstChild("Boombox")
        if source then
            source = source:FindFirstChild("Main")
        end
    end
    
    if not source or not source:IsA("BasePart") then
        notify("Error", "Boombox not found", 3)
        return
    end
    
    boomboxModel = source:Clone()
    boomboxModel.Name = "BackBoombox"
    boomboxModel.Anchored = false
    boomboxModel.CanCollide = false
    boomboxModel.Parent = char
    
    boomboxWeld = Instance.new("Weld")
    boomboxWeld.Name = "BoomboxWeld"
    boomboxWeld.Part0 = torso
    boomboxWeld.Part1 = boomboxModel
    boomboxWeld.C0 = CFrame.new(0, 0.5, 1.5) * CFrame.Angles(0, math.rad(180), 0)
    boomboxWeld.Parent = boomboxModel
    
    notify("Success", "Boombox attached to back!", 2)
end

local function removeBoombox()
    if boomboxWeld then boomboxWeld:Destroy(); boomboxWeld = nil end
    if boomboxModel then boomboxModel:Destroy(); boomboxModel = nil end
end

MiscExtra:AddToggle("BoomboxBackToggle", {
    Text = "Boombox on Back",
    Default = false,
    Callback = function(Value)
        boomboxOnBack = Value
        if Value then attachBoombox() else removeBoombox() end
    end
})

-- Bear on Back
local bearOnBack = false
local bearModel = nil
local bearMainPart = nil
local bearWelds = {}

local function weldAllParts(model, mainPart)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part ~= mainPart then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = mainPart
            weld.Part1 = part
            weld.Parent = part
            table.insert(bearWelds, weld)
        end
    end
end

local function attachBear()
    local char = Player.Character
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then
        notify("Error", "Torso not found", 3)
        return
    end
    
    local largeAnimals = workspace:FindFirstChild("Large Animals")
    if not largeAnimals then
        notify("Error", "Large Animals not found", 3)
        return
    end
    
    local bear = largeAnimals:FindFirstChild("Bear")
    if not bear then
        notify("Error", "Bear not found", 3)
        return
    end
    
    bearModel = bear:Clone()
    bearModel.Name = "BackBear"
    bearModel.Parent = char
    
    bearMainPart = bearModel:FindFirstChild("HumanoidRootPart") 
        or bearModel:FindFirstChild("Torso") 
        or bearModel.PrimaryPart
    
    if not bearMainPart then
        for _, part in ipairs(bearModel:GetDescendants()) do
            if part:IsA("BasePart") then
                bearMainPart = part
                break
            end
        end
    end
    
    if not bearMainPart then
        notify("Error", "Bear main part not found", 3)
        removeBear()
        return
    end
    
    local animator = bearModel:FindFirstChildOfClass("Animator")
    if animator then animator:Destroy() end
    
    local humanoid = bearModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        humanoid.AutoRotate = false
        humanoid.PlatformStand = true
    end
    
    for _, part in ipairs(bearModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = true
            part.Massless = true
        end
    end
    
    weldAllParts(bearModel, bearMainPart)
    
    local mainWeld = Instance.new("WeldConstraint")
    mainWeld.Part0 = torso
    mainWeld.Part1 = bearMainPart
    mainWeld.Parent = bearMainPart
    table.insert(bearWelds, mainWeld)
    
    bearMainPart.CFrame = torso.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0)
    
    notify("Success", "Bear anchored to back!", 2)
end

local function removeBear()
    for _, weld in ipairs(bearWelds) do
        if weld and weld.Parent then
            weld:Destroy()
        end
    end
    bearWelds = {}
    if bearModel then
        bearModel:Destroy()
        bearModel = nil
    end
    bearMainPart = nil
end

MiscExtra:AddToggle("BearBackToggle", {
    Text = "Bear on Back",
    Default = false,
    Callback = function(Value)
        bearOnBack = Value
        if Value then attachBear() else removeBear() end
    end
})

Player.CharacterAdded:Connect(function(newChar)
    if boomboxOnBack then
        task.wait(0.5)
        removeBoombox()
        task.wait(0.2)
        attachBoombox()
    end
    if bearOnBack then
        task.wait(0.5)
        removeBear()
        task.wait(0.2)
        attachBear()
    end
end)

-- ============================================
-- FUN TAB
-- ============================================
local FunLeft = Tabs.Fun:AddLeftGroupbox("Build")
local FunRight = Tabs.Fun:AddRightGroupbox("Grab")

-- Heart Build
local heartBuildActive = false
local heartHeight = 3

FunLeft:AddSlider("HeartHeightSlider", {
    Text = "Heart Height",
    Default = 3,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Callback = function(v)
        heartHeight = v
    end
})

FunLeft:AddToggle("HeartSparklerBuild", {
    Text = "Heart",
    Default = false,
    Callback = function(Value)
        heartBuildActive = Value
        if not Value then return end
        task.spawn(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local heart = Instance.new("Part")
            heart.Name = "HeartBuild"
            heart.Size = Vector3.new(2,2,2)
            heart.Shape = Enum.PartType.Ball
            heart.Color = Color3.fromRGB(255,0,0)
            heart.Material = Enum.Material.Neon
            heart.Anchored = true
            heart.CanCollide = false
            heart.Parent = workspace
            
            local att = Instance.new("Attachment", heart)
            local particle = Instance.new("ParticleEmitter", att)
            particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            particle.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(255,100,100))
            particle.Rate = 100
            particle.Lifetime = NumberRange.new(1)
            particle.SpreadAngle = Vector2.new(360,360)
            particle.Speed = NumberRange.new(5)
            
            local heartConnection = R.Heartbeat:Connect(function()
                if not heartBuildActive or not heart then 
                    if heart then heart:Destroy() end
                    if heartConnection then heartConnection:Disconnect() end
                    return 
                end
                local newPos = hrp and hrp.Position or Vector3.zero
                heart.CFrame = CFrame.new(newPos + Vector3.new(0, heartHeight, 0))
            end)
            
            while heartBuildActive do 
                task.wait(1) 
                hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            end
            heart:Destroy()
            heartConnection:Disconnect()
        end)
    end
})

-- Grab
_G.strength = 750

local killGrabEnabled = false
local function killGrabFunction()
    workspace.ChildAdded:Connect(function(v)
        if v:IsA("Model") and v.Name == "GrabParts" and killGrabEnabled then
            task.wait(0.05)
            local grabPart = v:FindFirstChild("GrabPart")
            if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                local part1 = grabPart.WeldConstraint.Part1
                if part1 and part1.Parent and part1.Parent ~= Player.Character then
                    local targetHum = part1.Parent:FindFirstChildOfClass("Humanoid")
                    if targetHum then pcall(function() targetHum.Health = 0; part1.Parent:BreakJoints() end) end
                end
            end
        end
    end)
end
killGrabFunction()

FunRight:AddToggle("KillGrabToggle", { Text = "Kill Grab", Default = false, Callback = function(v) killGrabEnabled = v end })
FunRight:AddToggle("MassLessGrabToggle", {
    Text = "MassLess Grab", Default = false,
    Callback = function(Value)
        _G.MassLessGrab = Value
        if not _G.MassLessGrab then if _G.MLConn then _G.MLConn:Disconnect(); _G.MLConn = nil end; return end
        if _G.MLConn then _G.MLConn:Disconnect() end
        _G.MLSense = _G.MLSense or 200
        _G.MLConn = R.Heartbeat:Connect(function()
            if not _G.MassLessGrab then return end
            local gp = workspace:FindFirstChild("GrabParts")
            if not gp then return end
            local dp = gp:FindFirstChild("DragPart")
            if dp then
                local ap = dp:FindFirstChild("AlignPosition")
                local ao = dp:FindFirstChild("AlignOrientation")
                if ap then ap.Responsiveness = _G.MLSense; ap.MaxForce = math.huge; ap.MaxVelocity = math.huge end
                if ao then ao.Responsiveness = _G.MLSense; ao.MaxTorque = math.huge end
            end
        end)
    end
})

-- ============================================
-- KEYBINDS TAB
-- ============================================
local KeybindsGroup = Tabs.Keybinds:AddLeftGroupbox("Keybinds")
KeybindsGroup:AddLabel("Teleport Tool"):AddKeyPicker("TPKeybind", { Default = "X", Text = "Teleport to Mouse", NoUI = false,
    Callback = function()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
    end
})

-- ============================================
-- UI SETTINGS
-- ============================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Thinder client Free")
SaveManager:SetFolder("Thinder client Free/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Friend join notify
PS.PlayerAdded:Connect(function(plr) if plr:IsFriendsWith(Player.UserId) then notify("Notify friend", plr.Name .. " joined", 5) end end)

-- Black hole kick detector
local function playKickSound()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://7128958209"
    s.Volume = 5
    s.PlayOnRemove = true
    s.Parent = game:GetService("SoundService")
    s:Destroy()
end
local function getClosestPlayer(pos)
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - pos).Magnitude
                if d < dist then dist = d; closest = plr end
            end
        end
    end
    return closest
end
Workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "BlackHoleKick" or obj.Name == "BlackHoleDetected" then
        task.wait(0.05)
        local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
        if not pos then return end
        local plr = getClosestPlayer(pos)
        if plr then playKickSound(); Library:Notify({ Title = "Thinder client Free", Description = plr.DisplayName .. " (" .. plr.Name .. ") has been kicked", Time = 6 }) end
    end
end)
