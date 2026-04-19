local ID = "Hub_Completo"
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if guiParent:FindFirstChild(ID) then guiParent[ID]:Destroy() end
for k, v in pairs(getgenv()) do
    if type(k) == "string" and string.sub(k, 1, #ID) == ID then
        if type(v) == "thread" then task.cancel(v)
        elseif typeof(v) == "RBXScriptConnection" then v:Disconnect() end
        getgenv()[k] = nil
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ID
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
getgenv()[ID.."_Drag"] = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundTransparency = 1
TabBar.CanvasSize = UDim2.new(0, 420, 0, 0)
TabBar.ScrollBarThickness = 4
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -55)
ContentContainer.Position = UDim2.new(0, 10, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function createTabAndPage(name, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, -5)
    TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabBar

    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0, 1, 1, -15)
    Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Separator.BorderSizePixel = 0
    Separator.LayoutOrder = order
    Separator.Parent = TabBar

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentContainer

    return TabBtn, Page
end

local tabs = {}
local pages = {}

local t1, p1 = createTabAndPage("Anti-AFK", 1)
local t2, p2 = createTabAndPage("Auto Clicker", 2)
local t3, p3 = createTabAndPage("Auto Skill", 3)
local t4, p4 = createTabAndPage("FPS Cap", 4)
tabs = {t1, t2, t3, t4}
pages = {p1, p2, p3, p4}

local function selectTab(index)
    for i, p in ipairs(pages) do p.Visible = (i == index) end
    for i, t in ipairs(tabs) do
        t.TextColor3 = (i == index) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        t.BackgroundColor3 = (i == index) and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(45, 45, 45)
    end
end

for i, btn in ipairs(tabs) do
    btn.MouseButton1Click:Connect(function() selectTab(i) end)
end
selectTab(1)

local function createLabel(text, pos, parent, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local AfkStatus = createLabel("Status: Active", UDim2.new(0, 0, 0, 10), p1, Color3.fromRGB(0, 255, 0))
local AfkTime = createLabel("Time Active: 00:00:00", UDim2.new(0, 0, 0, 40), p1)
local startTime = tick()
local lastMove = tick()

if getgenv()[ID.."_AfkLoop"] then task.cancel(getgenv()[ID.."_AfkLoop"]) end

getgenv()[ID.."_AfkLoop"] = task.spawn(function()
    while true do
        task.wait(1)
        local currentTime = tick() - startTime
        AfkTime.Text = string.format("Time Active: %02d:%02d:%02d", math.floor(currentTime / 3600), math.floor((currentTime / 60) % 60), math.floor(currentTime % 60))
        
        if tick() - lastMove >= 840 then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                AfkStatus.Text = "Status: Simulating Activity"
                AfkStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
                task.wait(0.5)
                AfkStatus.Text = "Status: Active"
                AfkStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            end)
            lastMove = tick()
        end
    end
end)

getgenv()[ID.."_Idled"] = LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

createLabel("Ativar/Desativar: F1", UDim2.new(0, 0, 0, 10), p2)
local M1Status = createLabel("Status: Desligado", UDim2.new(0, 0, 0, 40), p2, Color3.fromRGB(255, 0, 0))
local M1Clicks = createLabel("Cliques: 0/23", UDim2.new(0, 0, 0, 70), p2)

local m1Ativo = false
local cliques = 0
local maxCliques = 23

local function rotinaClick()
    while true do
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        cliques = cliques + 1
        M1Clicks.Text = "Cliques: " .. cliques .. "/" .. maxCliques
        if cliques >= maxCliques then
            m1Ativo = false
            M1Status.Text = "Status: Finalizado"
            M1Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            getgenv()[ID.."_M1Thread"] = nil
            break
        end
        task.wait(6.45)
    end
end

createLabel("Ativar/Desativar: F2", UDim2.new(0, 0, 0, 10), p3)
local SkillStatus = createLabel("Status: Inativo", UDim2.new(0, 0, 0, 40), p3, Color3.fromRGB(255, 0, 0))

local skillAtivo = false
local SLOTS = {Enum.KeyCode.One, Enum.KeyCode.Two}

local function rotinaSkill()
    while true do
        for _, tecla in ipairs(SLOTS) do
            vim:SendKeyEvent(true, tecla, false, game)
            task.wait(0.01)
            vim:SendKeyEvent(false, tecla, false, game)
            task.wait(0.1)
        end
    end
end

getgenv()[ID.."_Input"] = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F1 then
        m1Ativo = not m1Ativo
        if m1Ativo then
            cliques = 0
            M1Clicks.Text = "Cliques: 0/" .. maxCliques
            M1Status.Text = "Status: Ligado"
            M1Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            if getgenv()[ID.."_M1Thread"] then task.cancel(getgenv()[ID.."_M1Thread"]) end
            getgenv()[ID.."_M1Thread"] = task.spawn(rotinaClick)
        else
            if getgenv()[ID.."_M1Thread"] then task.cancel(getgenv()[ID.."_M1Thread"]); getgenv()[ID.."_M1Thread"] = nil end
            M1Status.Text = "Status: Desligado"
            M1Status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        skillAtivo = not skillAtivo
        if skillAtivo then
            SkillStatus.Text = "Status: Ativo"
            SkillStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            if getgenv()[ID.."_SkillThread"] then task.cancel(getgenv()[ID.."_SkillThread"]) end
            getgenv()[ID.."_SkillThread"] = task.spawn(rotinaSkill)
        else
            if getgenv()[ID.."_SkillThread"] then task.cancel(getgenv()[ID.."_SkillThread"]); getgenv()[ID.."_SkillThread"] = nil end
            SkillStatus.Text = "Status: Inativo"
            SkillStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)

local fpsOptions = {
    {t = "10 FPS", v = 10},
    {t = "60 FPS", v = 60},
    {t = "120 FPS", v = 120},
    {t = "Ilimitado", v = 10000}
}
local fpsBotoes = {}
local fpsAtual = 10000

local function atualizarFpsUI()
    for _, obj in ipairs(fpsBotoes) do
        if obj.v == fpsAtual then
            obj.btn.Text = "[ X ]  " .. obj.t
            obj.btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            obj.btn.Text = "[   ]  " .. obj.t
            obj.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

for i, opt in ipairs(fpsOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, 10 + ((i - 1) * 30))
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = p4
    table.insert(fpsBotoes, {btn = btn, v = opt.v, t = opt.t})
    
    btn.MouseButton1Click:Connect(function()
        fpsAtual = opt.v
        atualizarFpsUI()
        pcall(function() if setfpscap then setfpscap(fpsAtual) end end)
    end)
end

atualizarFpsUI()
pcall(function() if setfpscap then setfpscap(fpsAtual) end end)