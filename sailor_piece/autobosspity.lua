local ID = "M1Clicker_Script"
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild(ID) then
    guiParent[ID]:Destroy()
end
if getgenv()[ID.."_Drag"] then getgenv()[ID.."_Drag"]:Disconnect() end
if getgenv()[ID.."_Input"] then getgenv()[ID.."_Input"]:Disconnect() end
if getgenv()[ID.."_Thread"] then task.cancel(getgenv()[ID.."_Thread"]) end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ID
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent
local function createLabel(name, pos, text, color, parent, font, size)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = size or 14
    lbl.Font = font or Enum.Font.SourceSans
    lbl.Parent = parent
    return lbl
end
local ClickerFrame = Instance.new("Frame")
ClickerFrame.Size = UDim2.new(0, 200, 0, 100)
ClickerFrame.Position = UDim2.new(0.8, 0, 0.25, 0)
ClickerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ClickerFrame.BorderSizePixel = 0
ClickerFrame.Parent = ScreenGui
Instance.new("UICorner", ClickerFrame).CornerRadius = UDim.new(0, 10)
createLabel("Title", UDim2.new(0,0,0,0), "Auto Clicker (F1)", Color3.fromRGB(255,255,255), ClickerFrame, Enum.Font.SourceSansBold, 16)
local ClickerStatus = createLabel("Status", UDim2.new(0,0,0.4,0), "Status: Desligado", Color3.fromRGB(255,0,0), ClickerFrame)
local ClickLabel = createLabel("ClickLabel", UDim2.new(0,0,0.7,0), "Cliques: 0/23", Color3.fromRGB(255,255,255), ClickerFrame)
local dragging, dragInput, dragStart, startPos
ClickerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ClickerFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
ClickerFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
getgenv()[ID.."_Drag"] = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ClickerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
local ativo = false
local cliques = 0
local maxCliques = 23
local function rotinaClick()
    while true do
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        cliques = cliques + 1
        ClickLabel.Text = "Cliques: " .. cliques .. "/" .. maxCliques
        if cliques >= maxCliques then
            ativo = false
            ClickerStatus.Text = "Status: Finalizado"
            ClickerStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
            getgenv()[ID.."_Thread"] = nil
            break
        end
        task.wait(6.45)
    end
end
getgenv()[ID.."_Input"] = UserInputService.InputBegan:Connect(function(input, processado)
    if not processado and input.KeyCode == Enum.KeyCode.F1 then
        ativo = not ativo
        if ativo then
            cliques = 0
            ClickLabel.Text = "Cliques: 0/" .. maxCliques
            ClickerStatus.Text = "Status: Ligado"
            ClickerStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            if getgenv()[ID.."_Thread"] then task.cancel(getgenv()[ID.."_Thread"]) end
            getgenv()[ID.."_Thread"] = task.spawn(rotinaClick)
        else
            if getgenv()[ID.."_Thread"] then
                task.cancel(getgenv()[ID.."_Thread"])
                getgenv()[ID.."_Thread"] = nil
            end
            ClickerStatus.Text = "Status: Desligado"
            ClickerStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)