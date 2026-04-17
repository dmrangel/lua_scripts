local ID = "FPSCap_Script"
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if guiParent:FindFirstChild(ID) then
    guiParent[ID]:Destroy()
end
if getgenv()[ID.."_Drag"] then getgenv()[ID.."_Drag"]:Disconnect() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ID
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 140)
MainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "FPS Limiter"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

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

local options = {
    {texto = "10 FPS", valor = 10},
    {texto = "60 FPS", valor = 60},
    {texto = "120 FPS", valor = 120},
    {texto = "Ilimitado", valor = 10000}
}

local botoes = {}
local valorAtual = 10000

local function atualizarVisuais()
    for _, obj in ipairs(botoes) do
        if obj.valor == valorAtual then
            obj.botao.Text = "[ X ]  " .. obj.texto
            obj.botao.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            obj.botao.Text = "[   ]  " .. obj.texto
            obj.botao.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

for i, opt in ipairs(options) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 25)
    btn.Position = UDim2.new(0, 15, 0, 30 + ((i - 1) * 25))
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame
    
    table.insert(botoes, {botao = btn, valor = opt.valor, texto = opt.texto})
    
    btn.MouseButton1Click:Connect(function()
        valorAtual = opt.valor
        atualizarVisuais()
        pcall(function()
            if setfpscap then setfpscap(valorAtual) end
        end)
    end)
end

atualizarVisuais()
pcall(function()
    if setfpscap then setfpscap(valorAtual) end
end)