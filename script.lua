local _G = getgenv and getgenv() or _G
local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,_,__,___,____,_____,______,_______,________,_________,__________,___________,____________,_____________,______________,_______________,________________,_________________,__________________

-- Core Services
local S = {
    P = game:GetService("Players"),
    RI = game:GetService("ReplicatedStorage"),
    RS = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    WS = workspace,
    SG = game:GetService("StarterGui"),
    DSP = game:GetService("Debris")
}
local LP = S.P.LocalPlayer
local CG = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil

-- Load External Dependencies
local FY = 'https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'
local function LOAD(u) return loadstring(game:HttpGet(u))() end
LOAD(FY)
local REPO = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local LIB = LOAD(REPO .. "Library.lua")
local TM = LOAD(REPO .. "addons/ThemeManager.lua")
local SM = LOAD(REPO .. "addons/SaveManager.lua")

-- Library Setup
local OPTS = LIB.Options
local TOGGS = LIB.Toggles
LIB.ForceCheckbox = false

local WIN = LIB:CreateWindow({
    Title = "Thinder client Free",
    Footer = "Thinder client Free",
    Icon = 6026568198,
    NotifySide = "Right",
    ShowCustomCursor = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    CornerRadius = 15
})

local TAB = {
    D = WIN:AddTab("Defence", "shield"),
    T = WIN:AddTab("Target", "target"),
    V = WIN:AddTab("Visuals", "eye"),
    M = WIN:AddTab("Misc", "layers"),
    F = WIN:AddTab("Fun", "smile"),
    K = WIN:AddTab("Keybinds", "keyboard"),
    UI = WIN:AddTab("UI Settings", "settings")
}

-- Character Setup
local CHAR = LP.Character or LP.CharacterAdded:Wait()
local HRP = CHAR:WaitForChild("HumanoidRootPart")
local HUM = CHAR:WaitForChild("Humanoid")
local CAM = workspace.CurrentCamera
local RS = S.RI
local CE = RS:WaitForChild("CharacterEvents", 10)
local HELD = LP:WaitForChild("IsHeld", 10)
local STRG = CE and CE:WaitForChild("Struggle")

-- Utility Functions
local function NFY(t, c, d) LIB:Notify({ Title = t or "Notification", Description = c or "", Time = d or 5 }) end
local function HLD() local c = LP.Character if c and c:FindFirstChild("Head") then local o = c.Head:FindFirstChild("PartOwner") return o and o.Value ~= nil end return false end
local function KH(km, fn) S.UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == km then fn() end end) end

-- ============================================
-- DEFENCE TAB
-- ============================================
local DL = TAB.D:AddLeftGroupbox("Defence Main")
local DR = TAB.D:AddRightGroupbox("Anti Input Lag")

-- Anti Grab
local AG_CONN = nil
DL:AddToggle("x1", {
    Text = "Anti Grab", Default = false,
    Callback = function(V)
        if V then
            if AG_CONN then AG_CONN:Disconnect() end
            AG_CONN = S.RS.Heartbeat:Connect(function()
                if HLD() then
                    task.spawn(function()
                        if STRG then STRG:FireServer(LP) end
                        pcall(function() RS.GameCorrectionEvents.StopAllVelocity:FireServer() end)
                        for _, p in ipairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.Anchored = true end end
                        repeat task.wait() until not HELD.Value
                        for _, p in ipairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.Anchored = false end end
                    end)
                end
            end)
        else
            if AG_CONN then AG_CONN:Disconnect(); AG_CONN = nil end
            local c = LP.Character
            if c then for _, p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored = false end end end
        end
    end
})

-- Anti Blobman
local AB = false
DL:AddToggle("x2", { Text = "Anti Blobman", Default = false, Callback = function(V) AB = V end })
S.WS.DescendantAdded:Connect(function(o) if o.Name == "CreatureBlobman" and AB then pcall(function() o.LeftDetector:Destroy() o.RightDetector:Destroy() end) end end)

-- Anti Explosion
local AE = false
DL:AddToggle("x3", { Text = "Anti Explosion", Default = false, Callback = function(V) AE = V end })
S.WS.ChildAdded:Connect(function(m) if m.Name == "Part" and AE then local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if h and (m.Position - h.Position).Magnitude <= 20 then h.Anchored = true task.wait(0.01) repeat task.wait(0.001) until LP.Character["Right Arm"].RagdollLimbPart.CanCollide == false h.Anchored = false end end end)

-- Anti Burn
local ABURN = nil
DL:AddToggle("x4", { Text = "Anti Burn", Default = false, Callback = function(V) if V then local c = LP.Character local h = c:WaitForChild("Humanoid") local r = c:WaitForChild("HumanoidRootPart") if ABURN then ABURN:Disconnect() end ABURN = h.FireDebounce.Changed:Connect(function(b) if b then local old = r.CFrame local p2 = S.WS.Plots and S.WS.Plots:FindFirstChild("Plot2") if p2 then local bar = p2.Barrier and p2.Barrier:FindFirstChild("PlotBarrier") if bar then c:SetPrimaryPartCFrame(bar.CFrame * CFrame.new(0,6,0)) task.wait(0.3) local f = c:FindFirstChild("FirePlayerPart", true) if f then for _, o in ipairs(f:GetChildren()) do if o:IsA("Sound") then o:Stop() elseif o:IsA("Light") or o:IsA("ParticleEmitter") then o.Enabled = false end end if f:FindFirstChild("CanBurn") then f.CanBurn.Value = false end if h:FindFirstChild("FireDebounce") then h.FireDebounce.Value = false end end task.wait(0.6) if c and c.PrimaryPart then c:SetPrimaryPartCFrame(old) end end end end end) else if ABURN then ABURN:Disconnect() end end end })

-- Anti Void
local AV = nil
DL:AddToggle("x5", { Text = "Anti Void", Default = false, Callback = function(V) if V then if AV then AV:Disconnect() end AV = S.RS.Heartbeat:Connect(function() local c = LP.Character if c and c.PrimaryPart and c.PrimaryPart.Position.Y < -50 then local p = c.PrimaryPart.Position c:SetPrimaryPartCFrame(CFrame.new(p.X, p.Y + 100, p.Z)) c.PrimaryPart.AssemblyLinearVelocity = Vector3.zero end end) else if AV then AV:Disconnect(); AV = nil end end end })

-- Anti Sticky
local AS = false
DL:AddToggle("x6", { Text = "Anti Sticky", Default = false, Callback = function(V) AS = V if LP.PlayerScripts:FindFirstChild("StickyPartsTouchDetection") then LP.PlayerScripts.StickyPartsTouchDetection.Disabled = V end end })

-- Anti Lag (Grab Lines)
local AL_COPIES = {}
DL:AddToggle("x7", {
    Text = "Anti Lag", Default = false,
    Callback = function(V)
        local gf = RS:FindFirstChild("GrabEvents")
        if V then
            if gf then
                local c = gf:FindFirstChild("CreateGrabLine")
                local e = gf:FindFirstChild("ExtendGrabLine")
                if c then AL_COPIES.c = c:Clone(); c:Destroy() end
                if e then AL_COPIES.e = e:Clone(); e:Destroy() end
            end
            for _, o in ipairs(S.WS:GetDescendants()) do if o:IsA("Beam") or o.Name:lower():find("line") then o:Destroy() end end
        else
            if gf then
                if AL_COPIES.c and not gf:FindFirstChild("CreateGrabLine") then AL_COPIES.c:Clone().Parent = gf end
                if AL_COPIES.e and not gf:FindFirstChild("ExtendGrabLine") then AL_COPIES.e:Clone().Parent = gf end
            end
            AL_COPIES = {}
        end
    end
})

-- Anti Paint
local PP_BACKUP = {}
local PP_CONNS = {}
DL:AddToggle("x8", {
    Text = "Anti Paint", Default = false,
    Callback = function(V)
        if V then
            for _, o in ipairs(S.WS:GetDescendants()) do if o:IsA("BasePart") and o.Name == "PaintPlayerPart" then PP_BACKUP[o:GetDebugId()] = {c=o:Clone(), p=o.Parent} o:Destroy() end end
            local cn = S.WS.DescendantAdded:Connect(function(o) if o:IsA("BasePart") and o.Name == "PaintPlayerPart" then task.defer(function() if o and o.Parent then PP_BACKUP[o:GetDebugId()] = {c=o:Clone(), p=o.Parent} o:Destroy() end end) end end)
            table.insert(PP_CONNS, cn)
            if LP.Character then for _, p in ipairs(LP.Character:GetChildren()) do if p:IsA("Part") or p:IsA("BasePart") then p.CanTouch = false; p.CanQuery = false end end end
        else
            for _, d in pairs(PP_BACKUP) do if d.c and d.p then d.c.Parent = d.p end end
            PP_BACKUP = {}
            for _, cn in ipairs(PP_CONNS) do if cn.Connected then cn:Disconnect() end end
            PP_CONNS = {}
            if LP.Character then for _, p in ipairs(LP.Character:GetChildren()) do if p:IsA("Part") or p:IsA("BasePart") then p.CanTouch = true; p.CanQuery = true end end end
        end
    end
})

-- Anti Gucci (Blobman)
local AGB_ACTIVE = false
local AGB_CONN = nil
local AGB_SAFE = nil
local AGB_RF = 0
DL:AddToggle("x9", {
    Text = "Anti Gucci (Blobman)", Default = false,
    Callback = function(V)
        AGB_ACTIVE = V
        if V then
            local c = LP.Character or LP.CharacterAdded:Wait()
            local h = c:WaitForChild("Humanoid")
            local r = c:WaitForChild("HumanoidRootPart")
            AGB_SAFE = r.Position
            local function spBlob() pcall(function() RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", CFrame.new(0,5000000,0), Vector3.new(0,60,0)) end) local f = S.WS:WaitForChild(LP.Name.."SpawnedInToys",5) if f and f:FindFirstChild("CreatureBlobman") then local b = f.CreatureBlobman if b:FindFirstChild("Head") then b.Head.CFrame = CFrame.new(0,50000,0); b.Head.Anchored = true end end end
            spBlob()
            task.wait(1)
            local f = S.WS:FindFirstChild(LP.Name.."SpawnedInToys")
            local b = f and f:FindFirstChild("CreatureBlobman")
            local s = b and b:FindFirstChild("VehicleSeat")
            if s then r.CFrame = s.CFrame + Vector3.new(0,2,0); s:Sit(h) end
            if AGB_CONN then AGB_CONN:Disconnect() end
            AGB_CONN = S.RS.Heartbeat:Connect(function()
                if not r or not h then return end
                RS.CharacterEvents.RagdollRemote:FireServer(r,0)
                if AGB_RF > 0 then r.CFrame = CFrame.new(AGB_SAFE); AGB_RF = AGB_RF - 1 end
            end)
            h:GetPropertyChangedSignal("Jump"):Connect(function() if h.Jump and h.Sit then AGB_RF = 15; AGB_SAFE = r.Position end end)
        else
            if AGB_CONN then AGB_CONN:Disconnect(); AGB_CONN = nil end
            local f = S.WS:FindFirstChild(LP.Name.."SpawnedInToys") if f and f:FindFirstChild("CreatureBlobman") then f.CreatureBlobman:Destroy() end
        end
    end
})

-- Anti Kick (Shuriken)
local AKS_ACTIVE = false
DL:AddToggle("x10", {
    Text = "Anti Kick", Default = false,
    Callback = function(V)
        AKS_ACTIVE = V
        if V then
            task.spawn(function()
                local function clrK()
                    local inv = S.WS:FindFirstChild(LP.Name.."SpawnedInToys")
                    local dr = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("DestroyToy")
                    if inv and dr then for _, v in pairs(inv:GetChildren()) do if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then pcall(function() dr:FireServer(v) end) end end end
                end
                local so = RS:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                local se = RS:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
                local sr = RS.MenuToys.SpawnToyRemoteFunction
                local dr = RS:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
                local cs = LP:WaitForChild("CanSpawnToy")
                local function gHRP() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then return LP.Character.HumanoidRootPart else local c = LP.CharacterAdded:Wait() return c:WaitForChild("HumanoidRootPart") end end
                local function ckHome() if not S.WS.PlotItems.PlayersInPlots:FindFirstChild(LP.Name) then return false end for _, p in pairs(S.WS.Plots:GetChildren()) do local s = p:FindFirstChild("PlotSign") local o = s and s:FindFirstChild("ThisPlotsOwners") if o then for _, b in pairs(o:GetChildren()) do if b.Value == LP.Name then local f = S.WS.PlotItems:FindFirstChild(p.Name) if f then return true, f end end end end end return false end
                local function stkK(k) if not k or not k:FindFirstChild("StickyPart") then return end local h = gHRP() if not h then return end if k:FindFirstChild("SoundPart") then if not k.SoundPart:FindFirstChild("PartOwner") or k.SoundPart.PartOwner.Value ~= LP.Name then so:FireServer(k.SoundPart, k.SoundPart.CFrame) end end local fp = h:FindFirstChild("FirePlayerPart") or h:WaitForChild("FirePlayerPart",5) if fp then se:FireServer(k.StickyPart, fp, CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(90),math.rad(90))) end for _, o in pairs(k:GetChildren()) do if o.Name == "Pyramid" or o.Name == "Main" then o.CanTouch = false; o.CanCollide = false; o.CanQuery = false; o.Transparency = 0 else if o:IsA("BasePart") then o.CanTouch = false; o.CanCollide = false; o.CanQuery = false; o.Transparency = 1 end end end end
                local function spT(n) local t = tick() while not cs.Value do if not AKS_ACTIVE or tick()-t>5 then return nil end task.wait(0.1) end local h = gHRP() if h then task.spawn(function() pcall(function() sr:InvokeServer(n, h.CFrame*CFrame.new(0,12,20), Vector3.zero) end) end) end local _, house = ckHome() local inv = S.WS:FindFirstChild(LP.Name.."SpawnedInToys") if _ and house then return house:WaitForChild(n,2) end if not S.WS.PlotItems.PlayersInPlots:FindFirstChild(LP.Name) and inv then return inv:WaitForChild(n,2) end return nil end
                while AKS_ACTIVE do
                    task.wait(0.005)
                    if not LP.Character or not LP.Character:FindFirstChild("Humanoid") or LP.Character.Humanoid.Health<=0 then continue end
                    local inv = S.WS:FindFirstChild(LP.Name.."SpawnedInToys")
                    local k = inv and inv:FindFirstChild("NinjaShuriken")
                    if S.WS.PlotItems.PlayersInPlots:FindFirstChild(LP.Name) then
                        local _, house = ckHome()
                        if _ and house and S.WS.Plots:FindFirstChild(house.Name) then
                            local s = S.WS.Plots[house.Name]:FindFirstChild("PlotSign")
                            if s and s.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then k = spT("NinjaShuriken") if k == nil then continue end k.Name = "AntiKick" stkK(k) end
                        end
                    end
                    if not k then if S.WS.PlotItems.PlayersInPlots:FindFirstChild(LP.Name) then continue end k = spT("NinjaShuriken") if k == nil then continue end k.Name = "AntiKick" end
                    repeat if k and k:FindFirstChild("StickyPart") and k.StickyPart.CanTouch then stkK(k) k.Name = "AntiKick" end task.wait(0.3) until not k or not AKS_ACTIVE or not k:FindFirstChild("StickyPart") or k.StickyPart.CanTouch == false or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or (LP.Character.HumanoidRootPart.Position - k.StickyPart.Position).Magnitude >= 20
                    if not k or not k:FindFirstChild("StickyPart") or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or (LP.Character.HumanoidRootPart.Position - k.StickyPart.Position).Magnitude >= 20 then clrK() end
                    pcall(function() repeat task.wait(0.05) until not AKS_ACTIVE or not LP.Character or not LP.Character:FindFirstChild("Humanoid") or not k or not k:FindFirstChild("StickyPart") or not k.StickyPart:FindFirstChild("StickyWeld") or not k.StickyPart.StickyWeld.Part1 if not k or not k:FindFirstChild("StickyPart") or (LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health<=0) or not k.StickyPart:FindFirstChild("StickyWeld").Part1 then clrK() end end)
                end
            end)
        else clrK() end
    end
})

-- Anti Input Lag (Right Group)
DR:AddToggle("x11", {
    Text = "Anti Input Lag", Default = false,
    Callback = function(V)
        if V then
            task.spawn(function()
                local sr = RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
                local bf = nil
                local cb = nil
                local lg = 0
                pcall(function() sr:InvokeServer("FoodHamburger", CFrame.new(0,50000,0), Vector3.zero) end)
                while V do
                    local c = LP.Character
                    if not c then task.wait(0.1); continue end
                    local h = c:FindFirstChild("HumanoidRootPart")
                    if not h then task.wait(0.1); continue end
                    if not bf or not bf.Parent then bf = S.WS:FindFirstChild(LP.Name.."SpawnedInToys") if not bf then task.wait(0.1); continue end end
                    if not cb or not cb.Parent then cb = bf:FindFirstChild("FoodHamburger") end
                    if not cb then pcall(function() sr:InvokeServer("FoodHamburger", h.CFrame*CFrame.new(0,3,0), Vector3.zero) end) local t = tick() repeat task.wait() cb = bf:FindFirstChild("FoodHamburger") until cb or tick()-t>0.2 or not V end
                    if cb and cb.Parent and tick()-lg>0.05 then local hp = cb:FindFirstChild("HoldPart") if hp then pcall(function() hp.HoldItemRemoteFunction:InvokeServer(cb, c) end) lg = tick() end end
                    task.wait()
                end
                if cb and cb.Parent then pcall(function() cb:Destroy() end) end
            end)
        end
    end
})

-- ============================================
-- TARGET TAB
-- ============================================
local TL = TAB.T:AddLeftGroupbox("Target Selection")
local TA = TAB.T:AddLeftGroupbox("Target Actions")
local TE = TAB.T:AddRightGroupbox("Extra")
local SKP = nil
local KICK_LOOP = false

local function GPL() local l = {} for _, p in ipairs(S.P:GetPlayers()) do if p ~= LP then table.insert(l, p.DisplayName.." ("..p.Name..")") end end return l end
local function GPS(s) if not s then return nil end local u = s:match("%((.-)%)") return u and S.P:FindFirstChild(u) or nil end

TL:AddDropdown("y1", { Values = GPL(), Default = 1, Multi = false, Text = "Select player for kick", Callback = function(V) SKP = GPS(V) end })

task.spawn(function() while true do task.wait(2) pcall(function() local cl = GPL() if #cl > 0 then OPTS.y1:SetValues(cl) if SKP and SKP.Parent then OPTS.y1:SetValue(SKP.DisplayName.." ("..SKP.Name..")") else OPTS.y1:SetValue(nil); SKP = nil end end end) end end)

S.UIS.InputBegan:Connect(function(i, g) if g then return end if i.KeyCode == Enum.KeyCode.LeftAlt then local m = LP:GetMouse() local t = m.Target if t then for _, p in ipairs(S.P:GetPlayers()) do if p ~= LP and p.Character and t:IsDescendantOf(p.Character) then SKP = p; OPTS.y1:SetValue(p.DisplayName.." ("..p.Name..")"); NFY("Target Selected", "Selected: "..p.Name, 3) break end end end end end)

local NA = false
TL:AddToggle("y2", { Text = "Target Joined Notify", Default = false, Callback = function(V) NA = V end })
S.P.PlayerAdded:Connect(function(np) if NA and SKP and SKP.Name == np.Name then NFY("detected", "[Main Target] detected: "..np.Name, 8) local s = Instance.new("Sound", S.WS) s.SoundId = "rbxassetid://7128958209" s.Volume = 2 s:Play() S.DSP:AddItem(s, 3) end end)

-- Kick Functions
local function DO_KICK()
    local target = SKP
    if not target or not target.Parent then return end
    local GE = RS:WaitForChild("GrabEvents")
    local SNO = GE:WaitForChild("SetNetworkOwner")
    local DGL = GE:WaitForChild("DestroyGrabLine")
    local CGL = GE:WaitForChild("CreateGrabLine")
    local myChar = LP.Character or LP.CharacterAdded:Wait()
    local myRoot = myChar:WaitForChild("HumanoidRootPart")
    local savedPos = myRoot.CFrame
    
    -- Phase 1: Bring
    local tChar = target.Character
    if tChar and tChar:FindFirstChild("HumanoidRootPart") then
        local tRoot = tChar.HumanoidRootPart
        local startTime = tick()
        while tick() - startTime < 0.35 do
            myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 0, -3)
            myRoot.Velocity = Vector3.zero
            pcall(function() SNO:FireServer(tRoot, myRoot.CFrame) CGL:FireServer(tRoot, Vector3.zero, tRoot.Position, false) end)
            S.RS.Heartbeat:Wait()
        end
    end
    
    -- Phase 2: Drag
    while target and target.Parent and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
        local tRoot = target.Character.HumanoidRootPart
        local tHum = target.Character:FindFirstChild("Humanoid")
        if tHum then tHum.PlatformStand = true; tHum.Sit = true end
        local lockPos = savedPos + Vector3.new(0, 17, 0)
        myRoot.CFrame = savedPos
        myRoot.Velocity = Vector3.zero
        pcall(function()
            SNO:FireServer(tRoot, CFrame.new(lockPos))
            DGL:FireServer(tRoot)
            CGL:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
        end)
        tRoot.CFrame = CFrame.new(lockPos)
        tRoot.Velocity = Vector3.zero
        S.RS.Heartbeat:Wait()
    end
    
    myRoot.CFrame = savedPos
end

TA:AddToggle("y3", { Text = "Loop Kick", Default = false, Callback = function(V) if V then KICK_LOOP = true task.spawn(function() while KICK_LOOP and SKP and SKP.Parent do DO_KICK() end KICK_LOOP = false TOGGS.y3:SetValue(false) end) else KICK_LOOP = false end end })

TA:AddButton({ Text = "Bring", Func = function() if not SKP then NFY("Error", "No player selected", 3) return end local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") local tr = SKP.Character and SKP.Character:FindFirstChild("HumanoidRootPart") if mr and tr then tr.CFrame = mr.CFrame + Vector3.new(0,3,0) NFY("Bring", "Player brought", 2) end end })

-- ============================================
-- VISUALS TAB
-- ============================================
local VL = TAB.V:AddLeftGroupbox("Visuals")
local VR = TAB.V:AddRightGroupbox("ESP")

VL:AddToggle("z1", { Text = "3rd Person View", Default = false, Callback = function(V) if V then LP.CameraMode = Enum.CameraMode.Classic; CAM.CameraType = Enum.CameraType.Custom; CAM.CameraSubject = LP.Character:WaitForChild("Humanoid"); LP.CameraMaxZoomDistance = 1e10; LP.CameraMinZoomDistance = 0.5 else LP.CameraMode = Enum.CameraMode.LockFirstPerson; CAM.CameraType = Enum.CameraType.Custom; CAM.CameraSubject = LP.Character:WaitForChild("Humanoid"); LP.CameraMaxZoomDistance = 0; LP.CameraMinZoomDistance = 0 end end })
VL:AddSlider("z2", { Text = "FOV", Default = 90, Min = 1, Max = 120, Rounding = 0, Suffix = "°", Callback = function(V) CAM.FieldOfView = V end })

-- ============================================
-- KEYBINDS TAB
-- ============================================
local KG = TAB.K:AddLeftGroupbox("Keybinds")
KG:AddLabel("Teleport Tool"):AddKeyPicker("TPKey", { Default = "X", Text = "Teleport to Mouse", NoUI = false, Callback = function() local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if h then h.CFrame = CFrame.new(LP:GetMouse().Hit.Position + Vector3.new(0,3,0)) end end })

-- ============================================
-- UI SETTINGS
-- ============================================
local UIG = TAB.UI:AddLeftGroupbox("Menu")
UIG:AddButton("Unload", function() LIB:Unload() end)
UIG:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
LIB.ToggleKeybind = OPTS.MenuKeybind
TM:SetLibrary(LIB)
SM:SetLibrary(LIB)
SM:IgnoreThemeSettings()
SM:SetIgnoreIndexes({ "MenuKeybind" })
TM:SetFolder("Thinder client Free")
SM:SetFolder("Thinder client Free/Configs")
SM:BuildConfigSection(TAB.UI)
TM:ApplyToTab(TAB.UI)

-- ============================================
-- FINAL SETUP
-- ============================================
NFY("Owner Version", "Thinder client Free loaded.", 5)

S.P.PlayerAdded:Connect(function(p) if p:IsFriendsWith(LP.UserId) then NFY("Friend", p.Name.." joined", 5) end end)

S.WS.ChildAdded:Connect(function(o) if o.Name == "BlackHoleKick" or o.Name == "BlackHoleDetected" then task.wait(0.05) local pos = o:IsA("BasePart") and o.Position or (o:IsA("Model") and o.PrimaryPart and o.PrimaryPart.Position) if not pos then return end local closest, dist = nil, math.huge for _, p in ipairs(S.P:GetPlayers()) do if p ~= LP and p.Character then local h = p.Character:FindFirstChild("HumanoidRootPart") if h then local d = (h.Position - pos).Magnitude if d < dist then dist = d; closest = p end end end end if closest then local s = Instance.new("Sound", game:GetService("SoundService")) s.SoundId = "rbxassetid://7128958209" s.Volume = 5 s.PlayOnRemove = true s:Destroy() NFY("Thinder client Free", closest.DisplayName.." ("..closest.Name..") has been kicked", 6) end end end)
