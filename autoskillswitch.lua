local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSkillGui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local SkillFrame = Instance.new("Frame")
SkillFrame.Size = UDim2.new(0, 200, 0, 70)
SkillFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
SkillFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SkillFrame.BorderSizePixel = 0
SkillFrame.Parent = ScreenGui
Instance.new("UICorner", SkillFrame).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Auto Skill (F2)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = SkillFrame
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.5, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Inativo"
Status.TextColor3 = Color3.fromRGB(255, 0, 0)
Status.TextSize = 14
Status.Font = Enum.Font.SourceSans
Status.Parent = SkillFrame
local dragging, dragInput, dragStart, startPos
SkillFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = SkillFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
SkillFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        SkillFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
local TECLA_TOGGLE = Enum.KeyCode.F2
local DELAY_TROCA = 0.1
local SLOTS = {Enum.KeyCode.One, Enum.KeyCode.Two}
local ativo = false
local threadLoop = nil
local function simularToque(tecla)
    vim:SendKeyEvent(true, tecla, false, game)
    task.wait(0.01)
    vim:SendKeyEvent(false, tecla, false, game)
end
local function rotinaDeTroca()
    while true do
        for _, tecla in ipairs(SLOTS) do
            simularToque(tecla)
            task.wait(DELAY_TROCA)
        end
    end
end
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == TECLA_TOGGLE then
        ativo = not ativo
        if ativo then
            if threadLoop then task.cancel(threadLoop) end
            Status.Text = "Status: Ativo"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            threadLoop = task.spawn(rotinaDeTroca)
        else
            if threadLoop then
                task.cancel(threadLoop)
                threadLoop = nil
            end
            Status.Text = "Status: Inativo"
            Status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)