local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Game ID kontrolü
local ALLOWED_GAMES = {
    [88933961678687]  = true,
}

if not ALLOWED_GAMES[game.PlaceId] then return end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Size = UDim2.new(0, 600, 0, 350)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function spawnStars(parent, count, color)
    for i = 1, count do
        local Star = Instance.new("Frame")
        Star.Size = UDim2.new(0, 4, 0, 4)
        local startX = math.random(1, 98) / 100
        local startY = math.random(1, 98) / 100
        Star.Position = UDim2.new(startX, 0, startY, 0)
        Star.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
        Star.BorderSizePixel = 0
        Star.BackgroundTransparency = math.random(10, 50) / 100
        Star.Parent = parent
        makeCorner(Star, 8)
        task.spawn(function()
            local phase = math.random(0, 628) / 100
            local period = math.random(30, 70) / 10
            local amp = math.random(2, 5) / 1000
            local t = phase
            while true do
                task.wait(0.03)
                t = t + 0.03
                local dx = math.sin(t * (math.pi * 2 / period)) * amp
                Star.Position = UDim2.new(startX + dx, 0, startY, 0)
            end
        end)
    end
end

spawnStars(MainFrame, 80, Color3.fromRGB(255, 255, 255))

-- ============ KEY EKRANI ============
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, 0, 1, 0)
KeyFrame.BackgroundTransparency = 1
KeyFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0.5, -80)
Title.BackgroundTransparency = 1
Title.Text = "Arox Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = KeyFrame

local InputRow = Instance.new("Frame")
InputRow.Size = UDim2.new(0, 420, 0, 40)
InputRow.Position = UDim2.new(0.5, -210, 0.5, -20)
InputRow.BackgroundTransparency = 1
InputRow.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0, 300, 0, 40)
KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Enter key..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.Gotham
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = InputRow
makeCorner(KeyBox)

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(0, 110, 0, 40)
LoginBtn.Position = UDim2.new(0, 310, 0, 0)
LoginBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.BorderSizePixel = 0
LoginBtn.Text = "LOGIN"
LoginBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
LoginBtn.TextSize = 14
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.Parent = InputRow
makeCorner(LoginBtn)

local BtnRow = Instance.new("Frame")
BtnRow.Size = UDim2.new(0, 420, 0, 36)
BtnRow.Position = UDim2.new(0.5, -210, 0.5, 30)
BtnRow.BackgroundTransparency = 1
BtnRow.Parent = KeyFrame

local function buildButtons(buttons)
    for _, child in ipairs(BtnRow:GetChildren()) do child:Destroy() end
    local count = #buttons
    if count == 0 then return end
    local rows = count <= 3 and 1 or 2
    local cols = rows == 2 and 2 or count
    local gap = 4
    BtnRow.Size = UDim2.new(0, 420, 0, rows == 2 and 76 or 36)
    for idx, btnData in ipairs(buttons) do
        local col = (idx - 1) % cols
        local row = math.floor((idx - 1) / cols)
        local btnW = 1 / cols
        local btnH = rows == 2 and 0.5 or 1
        local xOff = col == 0 and 0 or gap
        local wOff = cols == 1 and 0 or -gap/2
        local yOff = rows == 1 and 0 or -gap/2
        local yPos = rows == 1 and 0 or (row == 0 and 0 or gap/2)
        local r,g,b = btnData.color[1], btnData.color[2], btnData.color[3]
        local tr,tg,tb = btnData.textColor[1], btnData.textColor[2], btnData.textColor[3]
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(btnW, wOff, btnH, yOff)
        Btn.Position = UDim2.new(col * btnW, xOff, row * btnH, yPos)
        Btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
        Btn.BorderSizePixel = 0
        Btn.Text = btnData.label
        Btn.TextColor3 = Color3.fromRGB(tr, tg, tb)
        Btn.TextSize = 13
        Btn.Font = Enum.Font.GothamBold
        Btn.Parent = BtnRow
        makeCorner(Btn)
        local link = btnData.link or ""
        Btn.MouseButton1Click:Connect(function()
            if link ~= "" then
                pcall(function() setclipboard(link) end)
                local ok = pcall(function()
                    game:GetService("GuiService"):OpenBrowserWindow(link)
                end)
                if not ok then
                    KeyBox.Text = ""
                    KeyBox.PlaceholderText = link .. " (copied!)"
                end
            else
                KeyBox.Text = ""
                KeyBox.PlaceholderText = btnData.label .. " Not Found!"
            end
        end)
    end
end

-- ============ ANA MENÜ ============
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(1, 0, 1, 0)
MenuFrame.BackgroundTransparency = 1
MenuFrame.Visible = false
MenuFrame.Parent = MainFrame

local SIDEBAR_W = 140
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MenuFrame
makeCorner(Sidebar, 15)

spawnStars(Sidebar, 30, Color3.fromRGB(160, 160, 180))

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, 0, 0, 50)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Text = "Arox Hub"
SidebarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SidebarTitle.TextSize = 16
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.Parent = Sidebar

local SidebarList = Instance.new("Frame")
SidebarList.Size = UDim2.new(1, 0, 1, -50)
SidebarList.Position = UDim2.new(0, 0, 0, 50)
SidebarList.BackgroundTransparency = 1
SidebarList.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.Parent = SidebarList

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = SidebarList

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
ContentArea.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MenuFrame

local activeTab = nil
local tabPages = {}

local function setActiveTab(tabBtn, page)
    if activeTab then
        activeTab.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        activeTab.TextColor3 = Color3.fromRGB(160, 160, 160)
    end
    for _, p in pairs(tabPages) do p.Visible = false end
    tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    page.Visible = true
    activeTab = tabBtn
end

local function addTab(name, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.LayoutOrder = order or 99
    TabBtn.Parent = SidebarList
    makeCorner(TabBtn, 6)

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentArea
    tabPages[name] = Page

    TabBtn.MouseButton1Click:Connect(function()
        setActiveTab(TabBtn, Page)
    end)
    return TabBtn, Page
end

-- ============ AUTO FARM SAYFASI ============
local afBtn, afPage = addTab("Auto Farm", 1)

local afTitle = Instance.new("TextLabel")
afTitle.Size = UDim2.new(1, 0, 0, 50)
afTitle.Position = UDim2.new(0, 0, 0, 0)
afTitle.BackgroundTransparency = 1
afTitle.Text = "Auto Farm"
afTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
afTitle.TextSize = 18
afTitle.Font = Enum.Font.GothamBold
afTitle.TextXAlignment = Enum.TextXAlignment.Center
afTitle.Parent = afPage

local function makeCheckbox(parent, label, labelColor, yPos, defaultOn)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -20, 0, 28)
    Row.Position = UDim2.new(0, 10, 0, yPos)
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Box = Instance.new("TextButton")
    Box.Size = UDim2.new(0, 18, 0, 18)
    Box.Position = UDim2.new(0, 0, 0.5, -9)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.BorderSizePixel = 0
    Box.Text = ""
    Box.Parent = Row
    makeCorner(Box, 4)

    local Check = Instance.new("TextLabel")
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = "✓"
    Check.TextColor3 = Color3.fromRGB(0, 0, 0)
    Check.TextSize = 13
    Check.Font = Enum.Font.GothamBold
    Check.Visible = defaultOn or false
    Check.Parent = Box

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -28, 1, 0)
    Lbl.Position = UDim2.new(0, 28, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = labelColor or Color3.fromRGB(200, 200, 200)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local enabled = defaultOn or false
    Box.MouseButton1Click:Connect(function()
        enabled = not enabled
        Check.Visible = enabled
        Box.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
    end)

    return function() return enabled end
end

-- World Forest (W1) — yeşil
local w1Label = Instance.new("TextLabel")
w1Label.Size = UDim2.new(1, -20, 0, 28)
w1Label.Position = UDim2.new(0, 10, 0, 55)
w1Label.BackgroundTransparency = 1
w1Label.Text = "World 1"
w1Label.TextColor3 = Color3.fromRGB(60, 200, 80)
w1Label.TextSize = 15
w1Label.Font = Enum.Font.GothamBold
w1Label.TextXAlignment = Enum.TextXAlignment.Left
w1Label.Parent = afPage

local getW1 = makeCheckbox(afPage, "Start AutoFarm", Color3.fromRGB(200, 200, 200), 88, false)

-- TP koordinatları
local W1_X, W1_Y, W1_Z = 3.9463701248168945, 8.378718376159668, -9075.109375

task.spawn(function()
    while true do
        task.wait(0.5)
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local rot = hrp.CFrame - hrp.CFrame.Position
            if getW1() then
                hrp.CFrame = CFrame.new(W1_X, W1_Y, W1_Z) * rot
            end
        end
    end
end)

-- ============ MENÜ SÜRÜKLEME ============
local dragging = false
local dragStart, startPos = nil, nil

Sidebar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============ SETTINGS ============
local settingsBtn, settingsPage = addTab("Settings", 2)

local stTitle = Instance.new("TextLabel")
stTitle.Size = UDim2.new(1, 0, 0, 50)
stTitle.BackgroundTransparency = 1
stTitle.Text = "Settings"
stTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stTitle.TextSize = 18
stTitle.Font = Enum.Font.GothamBold
stTitle.TextXAlignment = Enum.TextXAlignment.Center
stTitle.Parent = settingsPage

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -20, 0, 24)
keyLabel.Position = UDim2.new(0, 10, 0, 55)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Toggle Key (default: Insert)"
keyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
keyLabel.TextSize = 12
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = settingsPage

local KeyBindBtn = Instance.new("TextButton")
KeyBindBtn.Size = UDim2.new(0, 120, 0, 34)
KeyBindBtn.Position = UDim2.new(0, 10, 0, 82)
KeyBindBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
KeyBindBtn.BorderSizePixel = 0
KeyBindBtn.Text = "Insert"
KeyBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBindBtn.TextSize = 13
KeyBindBtn.Font = Enum.Font.GothamBold
KeyBindBtn.Parent = settingsPage
makeCorner(KeyBindBtn)

local toggleKey = Enum.KeyCode.Insert
local listeningForKey = false

KeyBindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    KeyBindBtn.Text = "Press a key..."
    KeyBindBtn.TextColor3 = Color3.fromRGB(255, 220, 80)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        KeyBindBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        KeyBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        listeningForKey = false
        return
    end
    if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey and MenuFrame.Visible then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

setActiveTab(afBtn, afPage)

-- ============ JSON YÜKLEMESİ ============
local jsonData = nil

task.spawn(function()
    local ok, raw = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Lucaroxs/CrimsonHub/refs/heads/main/keys.json")
    end)
    if ok then
        local parsed = HttpService:JSONDecode(raw)
        jsonData = parsed

        if parsed.active == 0 then
            InputRow.Visible = false
            BtnRow.Visible = false
            Title.Text = "Arox Hub"
            Title.Position = UDim2.new(0, 0, 0.5, -40)

            local MaintLabel = Instance.new("TextLabel")
            MaintLabel.Size = UDim2.new(1, 0, 0, 30)
            MaintLabel.Position = UDim2.new(0, 0, 0.5, -5)
            MaintLabel.BackgroundTransparency = 1
            MaintLabel.Text = "Script is currently under maintenance."
            MaintLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            MaintLabel.TextSize = 14
            MaintLabel.Font = Enum.Font.Gotham
            MaintLabel.Parent = KeyFrame

            local SubLabel = Instance.new("TextLabel")
            SubLabel.Size = UDim2.new(1, 0, 0, 20)
            SubLabel.Position = UDim2.new(0, 0, 0.5, 25)
            SubLabel.BackgroundTransparency = 1
            SubLabel.Text = "Please check back later."
            SubLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
            SubLabel.TextSize = 12
            SubLabel.Font = Enum.Font.Gotham
            SubLabel.Parent = KeyFrame
            return
        end

        if parsed.buttons then
            buildButtons(parsed.buttons)
        end
    end
end)

-- ============ LOGIN ============
LoginBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyBox.Text
    if not jsonData then
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Connection error!"
        return
    end
    local valid = false
    for _, keyData in ipairs(jsonData.keys) do
        if keyData.code == enteredKey then
            if keyData.expiresAt > os.time() then
                valid = true
            end
            break
        end
    end
    if valid then
        KeyFrame.Visible = false
        MenuFrame.Visible = true
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Invalid key!"
    end
end)
