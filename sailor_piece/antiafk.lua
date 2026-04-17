local ID = "AntiAFK_Script"
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if guiParent:FindFirstChild(ID) then
    guiParent[ID]:Destroy()
end
if getgenv()[ID.."_Drag"] then getgenv()[ID.."_Drag"]:Disconnect() end
if getgenv()[ID.."_Render"] then getgenv()[ID.."_Render"]:Disconnect() end
if getgenv()[ID.."_Idled"] then getgenv()[ID.."_Idled"]:Disconnect() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ID
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.8, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Anti-AFK System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.4, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Active"
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.TextSize = 14
Status.Font = Enum.Font.SourceSans
Status.Parent = MainFrame

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(1, 0, 0, 30)
TimeLabel.Position = UDim2.new(0, 0, 0.7, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "Time Active: 0s"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextSize = 14
TimeLabel.Font = Enum.Font.SourceSans
TimeLabel.Parent = MainFrame

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

local startTime = tick()
local lastMove = tick()

getgenv()[ID.."_Render"] = RunService.PreRender:Connect(function()
    local currentTime = tick() - startTime
    TimeLabel.Text = string.format("Time Active: %02d:%02d:%02d", math.floor(currentTime / 3600), math.floor((currentTime / 60) % 60), math.floor(currentTime % 60))
    
    if tick() - lastMove >= 900 then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            Status.Text = "Status: Simulating Activity"
            Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            task.wait(0.1)
            Status.Text = "Status: Active"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        end)
        lastMove = tick()
    end
end)

getgenv()[ID.."_Idled"] = LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)