--[[
    Modern UI Library for Roblox
    Version: 2.0
    Advanced UI Library with Animations, Themes, and Modern Components
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration, style, direction, callback)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utility:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Utility:Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

function Utility:AddCorner(instance, radius)
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = instance
    })
    return corner
end

function Utility:AddStroke(instance, color, thickness)
    local stroke = Utility:Create("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Thickness = thickness or 1,
        Parent = instance
    })
    return stroke
end

function Utility:AddGradient(instance, colors, rotation)
    local gradient = Utility:Create("UIGradient", {
        Color = colors or ColorSequence.new(Color3.fromRGB(255, 255, 255)),
        Rotation = rotation or 0,
        Parent = instance
    })
    return gradient
end

function Utility:AddGlow(instance, color, size)
    local glow = Utility:Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, size or 40, 1, size or 40),
        Position = UDim2.new(0.5, -(size or 40)/2, 0.5, -(size or 40)/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.5,
        ZIndex = 0,
        Parent = instance
    })
    return glow
end

function Utility:AddBlur(instance, size)
    local blur = Utility:Create("BlurEffect", {
        Size = size or 10,
        Parent = instance
    })
    return blur
end

function Utility:PulseEffect(instance, property, startValue, endValue, duration)
    spawn(function()
        while instance and instance.Parent do
            Utility:Tween(instance, {[property] = endValue}, duration or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(duration or 1)
            Utility:Tween(instance, {[property] = startValue}, duration or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(duration or 1)
        end
    end)
end

function Utility:ShakeEffect(instance, intensity, duration)
    local originalPos = instance.Position
    spawn(function()
        local elapsed = 0
        while elapsed < duration do
            local offsetX = math.random(-intensity, intensity)
            local offsetY = math.random(-intensity, intensity)
            instance.Position = UDim2.new(
                originalPos.X.Scale, originalPos.X.Offset + offsetX,
                originalPos.Y.Scale, originalPos.Y.Offset + offsetY
            )
            wait(0.05)
            elapsed = elapsed + 0.05
        end
        instance.Position = originalPos
    end)
end

function Utility:GlowEffect(button, color)
    local glow = Utility:Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = button
    })
    
    button.MouseEnter:Connect(function()
        Utility:Tween(glow, {ImageTransparency = 0.3}, 0.3)
    end)
    
    button.MouseLeave:Connect(function()
        Utility:Tween(glow, {ImageTransparency = 1}, 0.3)
    end)
    
    return glow
end

function Utility:RippleEffect(button, color)
    button.ClipsDescendants = true
    
    button.MouseButton1Click:Connect(function()
        local ripple = Utility:Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = button
        })
        
        Utility:AddCorner(ripple, 999)
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        
        Utility:Tween(ripple, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end)
end

-- Theme System
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Tertiary = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        Border = Color3.fromRGB(60, 60, 65),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(235, 235, 240),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Text = Color3.fromRGB(20, 20, 25),
        TextDark = Color3.fromRGB(100, 100, 105),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        Border = Color3.fromRGB(220, 220, 225),
        Shadow = Color3.fromRGB(100, 100, 100)
    },
    Ocean = {
        Background = Color3.fromRGB(15, 23, 42),
        Secondary = Color3.fromRGB(30, 41, 59),
        Tertiary = Color3.fromRGB(51, 65, 85),
        Accent = Color3.fromRGB(14, 165, 233),
        AccentHover = Color3.fromRGB(34, 185, 253),
        Text = Color3.fromRGB(248, 250, 252),
        TextDark = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        Border = Color3.fromRGB(71, 85, 105),
        Shadow = Color3.fromRGB(0, 10, 20)
    },
    Sunset = {
        Background = Color3.fromRGB(26, 20, 35),
        Secondary = Color3.fromRGB(46, 35, 60),
        Tertiary = Color3.fromRGB(66, 50, 85),
        Accent = Color3.fromRGB(236, 72, 153),
        AccentHover = Color3.fromRGB(255, 92, 173),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 180, 210),
        Success = Color3.fromRGB(134, 239, 172),
        Warning = Color3.fromRGB(253, 224, 71),
        Error = Color3.fromRGB(248, 113, 113),
        Border = Color3.fromRGB(86, 70, 105),
        Shadow = Color3.fromRGB(10, 0, 15)
    },
    Crimson = {
        Background = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(28, 25, 30),
        Tertiary = Color3.fromRGB(38, 32, 40),
        Accent = Color3.fromRGB(220, 38, 38),
        AccentHover = Color3.fromRGB(239, 68, 68),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(190, 190, 190),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Border = Color3.fromRGB(55, 48, 60),
        Shadow = Color3.fromRGB(10, 0, 5)
    },
    Neon = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(20, 20, 28),
        Tertiary = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(0, 255, 255),
        AccentHover = Color3.fromRGB(0, 200, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 200, 255),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 100),
        Border = Color3.fromRGB(0, 150, 200),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Forest = {
        Background = Color3.fromRGB(20, 25, 20),
        Secondary = Color3.fromRGB(30, 40, 30),
        Tertiary = Color3.fromRGB(40, 50, 40),
        Accent = Color3.fromRGB(34, 197, 94),
        AccentHover = Color3.fromRGB(74, 222, 128),
        Text = Color3.fromRGB(240, 255, 240),
        TextDark = Color3.fromRGB(180, 200, 180),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Border = Color3.fromRGB(60, 80, 60),
        Shadow = Color3.fromRGB(0, 10, 0)
    },
    Midnight = {
        Background = Color3.fromRGB(12, 15, 25),
        Secondary = Color3.fromRGB(22, 27, 40),
        Tertiary = Color3.fromRGB(32, 37, 50),
        Accent = Color3.fromRGB(99, 102, 241),
        AccentHover = Color3.fromRGB(129, 140, 248),
        Text = Color3.fromRGB(248, 250, 252),
        TextDark = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(16, 185, 129),
        Warning = Color3.fromRGB(245, 158, 11),
        Error = Color3.fromRGB(239, 68, 68),
        Border = Color3.fromRGB(51, 65, 85),
        Shadow = Color3.fromRGB(0, 0, 10)
    },
    Cherry = {
        Background = Color3.fromRGB(25, 15, 20),
        Secondary = Color3.fromRGB(40, 25, 35),
        Tertiary = Color3.fromRGB(55, 35, 50),
        Accent = Color3.fromRGB(244, 63, 94),
        AccentHover = Color3.fromRGB(251, 113, 133),
        Text = Color3.fromRGB(255, 240, 245),
        TextDark = Color3.fromRGB(200, 180, 190),
        Success = Color3.fromRGB(134, 239, 172),
        Warning = Color3.fromRGB(253, 224, 71),
        Error = Color3.fromRGB(248, 113, 113),
        Border = Color3.fromRGB(75, 50, 65),
        Shadow = Color3.fromRGB(10, 0, 5)
    },
    Aqua = {
        Background = Color3.fromRGB(15, 25, 30),
        Secondary = Color3.fromRGB(25, 40, 48),
        Tertiary = Color3.fromRGB(35, 55, 65),
        Accent = Color3.fromRGB(6, 182, 212),
        AccentHover = Color3.fromRGB(34, 211, 238),
        Text = Color3.fromRGB(240, 250, 255),
        TextDark = Color3.fromRGB(165, 200, 215),
        Success = Color3.fromRGB(20, 184, 166),
        Warning = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        Border = Color3.fromRGB(55, 75, 85),
        Shadow = Color3.fromRGB(0, 5, 10)
    }
}

-- Main Library
function UILibrary:New(config)
    local self = setmetatable({}, UILibrary)
    
    self.Config = {
        Title = config.Title or "UI Library",
        Theme = config.Theme or "Dark",
        Size = config.Size or UDim2.new(0, 700, 0, 450),
        Position = config.Position or UDim2.new(0.5, -350, 0.5, -225),
        Draggable = config.Draggable ~= false,
        MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightControl,
        ToggleKey = config.ToggleKey or Enum.KeyCode.Insert,
        SaveConfig = config.SaveConfig ~= false
    }
    
    self.Theme = Themes[self.Config.Theme] or Themes.Dark
    self.Tabs = {}
    self.Notifications = {}
    self.Flags = {}
    self.ConfigData = {}
    
    self:CreateUI()
    self:SetupMinimize()
    
    return self
end

function UILibrary:CreateUI()
    -- Main ScreenGui
    self.ScreenGui = Utility:Create("ScreenGui", {
        Name = "UILibrary_" .. math.random(1000, 9999),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    self.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Size = self.Config.Size,
        Position = self.Config.Position,
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(self.MainFrame, 12)
    Utility:AddStroke(self.MainFrame, self.Theme.Border, 1)
    
    -- Shadow Effect
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = self.MainFrame
    })
    
    -- Top Bar
    self.TopBar = Utility:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utility:AddCorner(self.TopBar, 12)
    
    -- Top Bar Bottom Cover
    local topBarCover = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.TopBar
    })
    
    -- Title
    self.TitleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    -- Control Buttons Container
    local controlsContainer = Utility:Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.TopBar
    })
    
    -- Minimize Button
    self.MinimizeButton = Utility:Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 0, 0.5, -20),
        BackgroundColor3 = self.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "—",
        TextColor3 = self.Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = controlsContainer
    })
    
    Utility:AddCorner(self.MinimizeButton, 8)
    Utility:RippleEffect(self.MinimizeButton, self.Theme.Accent)
    
    self.MinimizeButton.MouseEnter:Connect(function()
        Utility:Tween(self.MinimizeButton, {BackgroundColor3 = self.Theme.Accent}, 0.2)
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        Utility:Tween(self.MinimizeButton, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
    end)
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close Button
    self.CloseButton = Utility:Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 50, 0.5, -20),
        BackgroundColor3 = self.Theme.Error,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = controlsContainer
    })
    
    Utility:AddCorner(self.CloseButton, 8)
    Utility:RippleEffect(self.CloseButton, Color3.fromRGB(255, 255, 255))
    
    self.CloseButton.MouseEnter:Connect(function()
        Utility:Tween(self.CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 91, 91)}, 0.2)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        Utility:Tween(self.CloseButton, {BackgroundColor3 = self.Theme.Error}, 0.2)
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Tab Container
    self.TabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utility:AddCorner(self.TabContainer, 10)
    
    -- Tab List
    self.TabList = Utility:Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.TabContainer
    })
    
    local tabListLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabList
    })
    
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Container
    self.ContentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -175, 1, -60),
        Position = UDim2.new(0, 165, 0, 55),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utility:AddCorner(self.ContentContainer, 10)
    
    -- Make Draggable
    if self.Config.Draggable then
        Utility:MakeDraggable(self.MainFrame, self.TopBar)
    end
    
    -- Intro Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    Utility:Tween(self.MainFrame, {
        Size = self.Config.Size,
        Position = self.Config.Position
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function UILibrary:SetupMinimize()
    self.Minimized = false
    self.Hidden = false
    self.OriginalSize = self.Config.Size
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.MinimizeKey then
            self:ToggleMinimize()
        end
        
        if not gameProcessed and input.KeyCode == self.Config.ToggleKey then
            self:ToggleUI()
        end
    end)
end

function UILibrary:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        Utility:Tween(self.MainFrame, {
            Size = UDim2.new(0, self.OriginalSize.X.Offset, 0, 50)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        self.MinimizeButton.Text = "+"
    else
        Utility:Tween(self.MainFrame, {
            Size = self.OriginalSize
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        self.MinimizeButton.Text = "—"
    end
end

function UILibrary:ToggleUI()
    self.Hidden = not self.Hidden
    
    if self.Hidden then
        Utility:Tween(self.MainFrame, {
            Position = UDim2.new(0.5, 0, 1.5, 0)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    else
        Utility:Tween(self.MainFrame, {
            Position = self.Config.Position
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end

function UILibrary:ChangeTheme(themeName)
    if not Themes[themeName] then return end
    
    self.Theme = Themes[themeName]
    self.Config.Theme = themeName
    
    -- Update colors with animations
    Utility:Tween(self.MainFrame, {BackgroundColor3 = self.Theme.Background}, 0.3)
    Utility:Tween(self.TopBar, {BackgroundColor3 = self.Theme.Secondary}, 0.3)
    Utility:Tween(self.TabContainer, {BackgroundColor3 = self.Theme.Secondary}, 0.3)
    Utility:Tween(self.ContentContainer, {BackgroundColor3 = self.Theme.Secondary}, 0.3)
    Utility:Tween(self.TitleLabel, {TextColor3 = self.Theme.Text}, 0.3)
    
    -- Update all tabs
    for _, tab in pairs(self.Tabs) do
        tab:UpdateTheme()
    end
end

-- Tab System
function UILibrary:CreateTab(name, icon)
    local Tab = {}
    Tab.Name = name
    Tab.Icon = icon
    Tab.Elements = {}
    Tab.Library = self
    
    -- Tab Button
    Tab.Button = Utility:Create("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = self.TabList
    })
    
    Utility:AddCorner(Tab.Button, 8)
    
    -- Tab Icon
    if icon then
        Tab.IconLabel = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = self.Theme.TextDark,
            Parent = Tab.Button
        })
    end
    
    -- Tab Label
    Tab.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, icon and -40 or -20, 1, 0),
        Position = UDim2.new(0, icon and 35 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Tab.Button
    })
    
    -- Tab Content
    Tab.Content = Utility:Create("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.ContentContainer
    })
    
    local contentLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = Tab.Content
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Button Click
    Tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(Tab)
    end)
    
    -- Hover Effects
    Tab.Button.MouseEnter:Connect(function()
        if not Tab.Selected then
            Utility:Tween(Tab.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            Utility:Tween(Tab.Label, {TextColor3 = self.Theme.Text}, 0.2)
            if Tab.IconLabel then
                Utility:Tween(Tab.IconLabel, {ImageColor3 = self.Theme.Text}, 0.2)
            end
        end
    end)
    
    Tab.Button.MouseLeave:Connect(function()
        if not Tab.Selected then
            Utility:Tween(Tab.Button, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
            Utility:Tween(Tab.Label, {TextColor3 = self.Theme.TextDark}, 0.2)
            if Tab.IconLabel then
                Utility:Tween(Tab.IconLabel, {ImageColor3 = self.Theme.TextDark}, 0.2)
            end
        end
    end)
    
    Utility:RippleEffect(Tab.Button, self.Theme.Accent)
    
    -- Update Theme Function
    function Tab:UpdateTheme()
        local theme = self.Library.Theme
        
        if self.Selected then
            Tab.Button.BackgroundColor3 = theme.Accent
            Tab.Label.TextColor3 = theme.Text
            if Tab.IconLabel then
                Tab.IconLabel.ImageColor3 = theme.Text
            end
        else
            Tab.Button.BackgroundColor3 = theme.Tertiary
            Tab.Label.TextColor3 = theme.TextDark
            if Tab.IconLabel then
                Tab.IconLabel.ImageColor3 = theme.TextDark
            end
        end
        
        -- Update all elements
        for _, element in pairs(self.Elements) do
            if element.UpdateTheme then
                element:UpdateTheme()
            end
        end
    end
    
    table.insert(self.Tabs, Tab)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(Tab)
    end
    
    return Tab
end

function UILibrary:SelectTab(tab)
    for _, t in pairs(self.Tabs) do
        t.Selected = false
        t.Content.Visible = false
        Utility:Tween(t.Button, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        Utility:Tween(t.Label, {TextColor3 = self.Theme.TextDark}, 0.2)
        if t.IconLabel then
            Utility:Tween(t.IconLabel, {ImageColor3 = self.Theme.TextDark}, 0.2)
        end
    end
    
    tab.Selected = true
    tab.Content.Visible = true
    Utility:Tween(tab.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
    Utility:Tween(tab.Label, {TextColor3 = self.Theme.Text}, 0.2)
    if tab.IconLabel then
        Utility:Tween(tab.IconLabel, {ImageColor3 = self.Theme.Text}, 0.2)
    end
end

-- Section
function UILibrary:CreateSection(tab, name)
    local Section = {}
    Section.Name = name
    Section.Tab = tab
    Section.Library = tab.Library
    
    Section.Container = Utility:Create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = tab.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = tab.Content
    })
    
    Utility:AddCorner(Section.Container, 8)
    
    Section.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = tab.Library.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Section.Container
    })
    
    Section.ElementsContainer = Utility:Create("Frame", {
        Name = "Elements",
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Parent = Section.Container
    })
    
    local elementsLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = Section.ElementsContainer
    })
    
    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Section.Container.Size = UDim2.new(1, 0, 0, elementsLayout.AbsoluteContentSize.Y + 50)
    end)
    
    function Section:UpdateTheme()
        local theme = self.Library.Theme
        Section.Container.BackgroundColor3 = theme.Tertiary
        Section.Label.TextColor3 = theme.Text
    end
    
    return Section
end

-- Button Element
function UILibrary:CreateButton(parent, config)
    local Button = {}
    Button.Name = config.Name or "Button"
    Button.Callback = config.Callback or function() end
    Button.Parent = parent
    Button.Library = parent.Library or parent.Tab.Library
    
    Button.Container = Utility:Create("Frame", {
        Name = Button.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Button.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Button.Container, 8)
    
    Button.ButtonObj = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Button",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = Button.Container
    })
    
    Utility:RippleEffect(Button.Container, Color3.fromRGB(255, 255, 255))
    
    Button.ButtonObj.MouseEnter:Connect(function()
        Utility:Tween(Button.Container, {BackgroundColor3 = Button.Library.Theme.AccentHover}, 0.2)
    end)
    
    Button.ButtonObj.MouseLeave:Connect(function()
        Utility:Tween(Button.Container, {BackgroundColor3 = Button.Library.Theme.Accent}, 0.2)
    end)
    
    Button.ButtonObj.MouseButton1Click:Connect(function()
        Button.Callback()
    end)
    
    function Button:UpdateTheme()
        local theme = self.Library.Theme
        Button.Container.BackgroundColor3 = theme.Accent
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Button)
    end
    
    return Button
end

-- Toggle Element
function UILibrary:CreateToggle(parent, config)
    local Toggle = {}
    Toggle.Name = config.Name or "Toggle"
    Toggle.Default = config.Default or false
    Toggle.Callback = config.Callback or function() end
    Toggle.Flag = config.Flag
    Toggle.Parent = parent
    Toggle.Library = parent.Library or parent.Tab.Library
    Toggle.Value = Toggle.Default
    
    Toggle.Container = Utility:Create("Frame", {
        Name = Toggle.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Toggle.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Toggle.Container, 8)
    Utility:AddStroke(Toggle.Container, Toggle.Library.Theme.Border, 1)
    
    Toggle.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Toggle",
        TextColor3 = Toggle.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Toggle.Container
    })
    
    Toggle.ToggleFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 45, 0, 24),
        Position = UDim2.new(1, -50, 0.5, -12),
        BackgroundColor3 = Toggle.Default and Toggle.Library.Theme.Success or Toggle.Library.Theme.Border,
        BorderSizePixel = 0,
        Parent = Toggle.Container
    })
    
    Utility:AddCorner(Toggle.ToggleFrame, 12)
    
    Toggle.ToggleCircle = Utility:Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = Toggle.Default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = Toggle.ToggleFrame
    })
    
    Utility:AddCorner(Toggle.ToggleCircle, 9)
    
    Toggle.Button = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Toggle.Container
    })
    
    Toggle.Button.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)
    
    function Toggle:SetValue(value)
        self.Value = value
        
        if value then
            Utility:Tween(self.ToggleFrame, {BackgroundColor3 = self.Library.Theme.Success}, 0.2)
            Utility:Tween(self.ToggleCircle, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.2)
        else
            Utility:Tween(self.ToggleFrame, {BackgroundColor3 = self.Library.Theme.Border}, 0.2)
            Utility:Tween(self.ToggleCircle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
        end
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    function Toggle:UpdateTheme()
        local theme = self.Library.Theme
        Toggle.Container.BackgroundColor3 = theme.Background
        Toggle.Label.TextColor3 = theme.Text
        if Toggle.Value then
            Toggle.ToggleFrame.BackgroundColor3 = theme.Success
        else
            Toggle.ToggleFrame.BackgroundColor3 = theme.Border
        end
    end
    
    if Toggle.Flag then
        Toggle.Library.Flags[Toggle.Flag] = Toggle.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Toggle)
    end
    
    return Toggle
end

-- Slider Element
function UILibrary:CreateSlider(parent, config)
    local Slider = {}
    Slider.Name = config.Name or "Slider"
    Slider.Min = config.Min or 0
    Slider.Max = config.Max or 100
    Slider.Default = config.Default or Slider.Min
    Slider.Increment = config.Increment or 1
    Slider.Callback = config.Callback or function() end
    Slider.Flag = config.Flag
    Slider.Parent = parent
    Slider.Library = parent.Library or parent.Tab.Library
    Slider.Value = Slider.Default
    Slider.Dragging = false
    
    Slider.Container = Utility:Create("Frame", {
        Name = Slider.Name,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Slider.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Slider.Container, 8)
    Utility:AddStroke(Slider.Container, Slider.Library.Theme.Border, 1)
    
    Slider.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Slider",
        TextColor3 = Slider.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Slider.Container
    })
    
    Slider.ValueLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(Slider.Default),
        TextColor3 = Slider.Library.Theme.Accent,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Slider.Container
    })
    
    Slider.SliderBack = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 1, -15),
        BackgroundColor3 = Slider.Library.Theme.Border,
        BorderSizePixel = 0,
        Parent = Slider.Container
    })
    
    Utility:AddCorner(Slider.SliderBack, 3)
    
    local fillPercent = (Slider.Default - Slider.Min) / (Slider.Max - Slider.Min)
    
    Slider.SliderFill = Utility:Create("Frame", {
        Size = UDim2.new(fillPercent, 0, 1, 0),
        BackgroundColor3 = Slider.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Slider.SliderBack
    })
    
    Utility:AddCorner(Slider.SliderFill, 3)
    
    Slider.SliderButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(fillPercent, -8, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = "",
        Parent = Slider.SliderBack
    })
    
    Utility:AddCorner(Slider.SliderButton, 8)
    Utility:AddStroke(Slider.SliderButton, Slider.Library.Theme.Accent, 2)
    
    function Slider:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        
        Utility:Tween(self.SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        Utility:Tween(self.SliderButton, {Position = UDim2.new(percent, -8, 0.5, -8)}, 0.1)
        
        self.ValueLabel.Text = tostring(value)
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    Slider.SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = true
            Utility:Tween(Slider.SliderButton, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -10, 0.5, -10)}, 0.2)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = false
            Utility:Tween(Slider.SliderButton, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -8, 0.5, -8)}, 0.2)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = Slider.SliderBack.AbsolutePosition.X
            local sliderSize = Slider.SliderBack.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = Slider.Min + (Slider.Max - Slider.Min) * percent
            
            Slider:SetValue(value)
        end
    end)
    
    function Slider:UpdateTheme()
        local theme = self.Library.Theme
        Slider.Container.BackgroundColor3 = theme.Background
        Slider.Label.TextColor3 = theme.Text
        Slider.ValueLabel.TextColor3 = theme.Accent
        Slider.SliderBack.BackgroundColor3 = theme.Border
        Slider.SliderFill.BackgroundColor3 = theme.Accent
    end
    
    if Slider.Flag then
        Slider.Library.Flags[Slider.Flag] = Slider.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Slider)
    end
    
    return Slider
end

-- Dropdown Element
function UILibrary:CreateDropdown(parent, config)
    local Dropdown = {}
    Dropdown.Name = config.Name or "Dropdown"
    Dropdown.Options = config.Options or {}
    Dropdown.Default = config.Default or (Dropdown.Options[1] or "None")
    Dropdown.Callback = config.Callback or function() end
    Dropdown.Flag = config.Flag
    Dropdown.Parent = parent
    Dropdown.Library = parent.Library or parent.Tab.Library
    Dropdown.Value = Dropdown.Default
    Dropdown.Open = false
    
    Dropdown.Container = Utility:Create("Frame", {
        Name = Dropdown.Name,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Dropdown.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Dropdown.Container, 8)
    Utility:AddStroke(Dropdown.Container, Dropdown.Library.Theme.Border, 1)
    
    Dropdown.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Dropdown",
        TextColor3 = Dropdown.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Dropdown.Container
    })
    
    Dropdown.SelectedFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Dropdown.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = Dropdown.Container
    })
    
    Utility:AddCorner(Dropdown.SelectedFrame, 6)
    
    Dropdown.SelectedLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Dropdown.Default,
        TextColor3 = Dropdown.Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Dropdown.SelectedFrame
    })
    
    Dropdown.Arrow = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -25, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Dropdown.Library.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = Dropdown.SelectedFrame
    })
    
    Dropdown.OptionsFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundColor3 = Dropdown.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = Dropdown.Container
    })
    
    Utility:AddCorner(Dropdown.OptionsFrame, 6)
    
    Dropdown.OptionsList = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Dropdown.Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Dropdown.OptionsFrame
    })
    
    local optionsLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = Dropdown.OptionsList
    })
    
    Dropdown.Button = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Dropdown.Container
    })
    
    Dropdown.Button.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    function Dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            self.OptionsFrame.Visible = true
            local targetHeight = math.min(#self.Options * 32, 150)
            
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 70 + targetHeight + 10)}, 0.3)
            Utility:Tween(self.OptionsFrame, {Size = UDim2.new(1, -20, 0, targetHeight)}, 0.3)
            Utility:Tween(self.Arrow, {Rotation = 180}, 0.3)
        else
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 70)}, 0.3)
            Utility:Tween(self.OptionsFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.3, nil, nil, function()
                self.OptionsFrame.Visible = false
            end)
            Utility:Tween(self.Arrow, {Rotation = 0}, 0.3)
        end
    end
    
    function Dropdown:SetValue(value)
        self.Value = value
        self.SelectedLabel.Text = value
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
        self:Toggle()
    end
    
    function Dropdown:Refresh(options)
        self.Options = options
        
        for _, child in pairs(self.OptionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, option in pairs(options) do
            local optionButton = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = self.Library.Theme.Background,
                BorderSizePixel = 0,
                Text = option,
                TextColor3 = self.Library.Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                Parent = self.OptionsList
            })
            
            Utility:AddCorner(optionButton, 4)
            
            optionButton.MouseEnter:Connect(function()
                Utility:Tween(optionButton, {BackgroundColor3 = self.Library.Theme.Accent}, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                Utility:Tween(optionButton, {BackgroundColor3 = self.Library.Theme.Background}, 0.2)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                self:SetValue(option)
            end)
        end
        
        optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            self.OptionsList.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y)
        end)
    end
    
    Dropdown:Refresh(Dropdown.Options)
    
    function Dropdown:UpdateTheme()
        local theme = self.Library.Theme
        Dropdown.Container.BackgroundColor3 = theme.Background
        Dropdown.Label.TextColor3 = theme.Text
        Dropdown.SelectedFrame.BackgroundColor3 = theme.Tertiary
        Dropdown.SelectedLabel.TextColor3 = theme.Text
        Dropdown.Arrow.TextColor3 = theme.TextDark
        Dropdown.OptionsFrame.BackgroundColor3 = theme.Tertiary
        
        for _, child in pairs(Dropdown.OptionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = theme.Background
                child.TextColor3 = theme.Text
            end
        end
    end
    
    if Dropdown.Flag then
        Dropdown.Library.Flags[Dropdown.Flag] = Dropdown.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Dropdown)
    end
    
    return Dropdown
end

-- Textbox Element
function UILibrary:CreateTextbox(parent, config)
    local Textbox = {}
    Textbox.Name = config.Name or "Textbox"
    Textbox.Default = config.Default or ""
    Textbox.Placeholder = config.Placeholder or "Enter text..."
    Textbox.Callback = config.Callback or function() end
    Textbox.Flag = config.Flag
    Textbox.Parent = parent
    Textbox.Library = parent.Library or parent.Tab.Library
    Textbox.Value = Textbox.Default
    
    Textbox.Container = Utility:Create("Frame", {
        Name = Textbox.Name,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Textbox.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Textbox.Container, 8)
    Utility:AddStroke(Textbox.Container, Textbox.Library.Theme.Border, 1)
    
    Textbox.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Textbox",
        TextColor3 = Textbox.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Textbox.Container
    })
    
    Textbox.InputFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Textbox.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = Textbox.Container
    })
    
    Utility:AddCorner(Textbox.InputFrame, 6)
    
    Textbox.Input = Utility:Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Textbox.Default,
        PlaceholderText = Textbox.Placeholder,
        TextColor3 = Textbox.Library.Theme.Text,
        PlaceholderColor3 = Textbox.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = Textbox.InputFrame
    })
    
    Textbox.Input.Focused:Connect(function()
        Utility:Tween(Textbox.InputFrame, {BackgroundColor3 = Textbox.Library.Theme.Accent}, 0.2)
    end)
    
    Textbox.Input.FocusLost:Connect(function()
        Utility:Tween(Textbox.InputFrame, {BackgroundColor3 = Textbox.Library.Theme.Tertiary}, 0.2)
        Textbox:SetValue(Textbox.Input.Text)
    end)
    
    function Textbox:SetValue(value)
        self.Value = value
        self.Input.Text = value
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    function Textbox:UpdateTheme()
        local theme = self.Library.Theme
        Textbox.Container.BackgroundColor3 = theme.Background
        Textbox.Label.TextColor3 = theme.Text
        Textbox.InputFrame.BackgroundColor3 = theme.Tertiary
        Textbox.Input.TextColor3 = theme.Text
        Textbox.Input.PlaceholderColor3 = theme.TextDark
    end
    
    if Textbox.Flag then
        Textbox.Library.Flags[Textbox.Flag] = Textbox.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Textbox)
    end
    
    return Textbox
end

-- Keybind Element
function UILibrary:CreateKeybind(parent, config)
    local Keybind = {}
    Keybind.Name = config.Name or "Keybind"
    Keybind.Default = config.Default or Enum.KeyCode.E
    Keybind.Callback = config.Callback or function() end
    Keybind.Flag = config.Flag
    Keybind.Parent = parent
    Keybind.Library = parent.Library or parent.Tab.Library
    Keybind.Value = Keybind.Default
    Keybind.Binding = false
    
    Keybind.Container = Utility:Create("Frame", {
        Name = Keybind.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Keybind.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Keybind.Container, 8)
    Utility:AddStroke(Keybind.Container, Keybind.Library.Theme.Border, 1)
    
    Keybind.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Keybind",
        TextColor3 = Keybind.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Keybind.Container
    })
    
    Keybind.KeyButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(1, -90, 0.5, -15),
        BackgroundColor3 = Keybind.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = Keybind.Default.Name,
        TextColor3 = Keybind.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = Keybind.Container
    })
    
    Utility:AddCorner(Keybind.KeyButton, 6)
    
    Keybind.KeyButton.MouseButton1Click:Connect(function()
        Keybind.Binding = true
        Keybind.KeyButton.Text = "..."
        Utility:Tween(Keybind.KeyButton, {BackgroundColor3 = Keybind.Library.Theme.Accent}, 0.2)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if Keybind.Binding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind:SetValue(input.KeyCode)
                Keybind.Binding = false
                Utility:Tween(Keybind.KeyButton, {BackgroundColor3 = Keybind.Library.Theme.Tertiary}, 0.2)
            end
        elseif not gameProcessed and input.KeyCode == Keybind.Value then
            Keybind.Callback(Keybind.Value)
        end
    end)
    
    function Keybind:SetValue(keycode)
        self.Value = keycode
        self.KeyButton.Text = keycode.Name
        
        if self.Flag then
            self.Library.Flags[self.Flag] = keycode
        end
    end
    
    function Keybind:UpdateTheme()
        local theme = self.Library.Theme
        Keybind.Container.BackgroundColor3 = theme.Background
        Keybind.Label.TextColor3 = theme.Text
        Keybind.KeyButton.BackgroundColor3 = theme.Tertiary
        Keybind.KeyButton.TextColor3 = theme.Text
    end
    
    if Keybind.Flag then
        Keybind.Library.Flags[Keybind.Flag] = Keybind.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Keybind)
    end
    
    return Keybind
end

-- Color Picker Element
function UILibrary:CreateColorPicker(parent, config)
    local ColorPicker = {}
    ColorPicker.Name = config.Name or "Color Picker"
    ColorPicker.Default = config.Default or Color3.fromRGB(255, 255, 255)
    ColorPicker.Callback = config.Callback or function() end
    ColorPicker.Flag = config.Flag
    ColorPicker.Parent = parent
    ColorPicker.Library = parent.Library or parent.Tab.Library
    ColorPicker.Value = ColorPicker.Default
    ColorPicker.Open = false
    
    ColorPicker.Container = Utility:Create("Frame", {
        Name = ColorPicker.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ColorPicker.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(ColorPicker.Container, 8)
    Utility:AddStroke(ColorPicker.Container, ColorPicker.Library.Theme.Border, 1)
    
    ColorPicker.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Color Picker",
        TextColor3 = ColorPicker.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ColorPicker.Container
    })
    
    ColorPicker.ColorDisplay = Utility:Create("Frame", {
        Size = UDim2.new(0, 40, 0, 30),
        Position = UDim2.new(1, -50, 0.5, -15),
        BackgroundColor3 = ColorPicker.Default,
        BorderSizePixel = 0,
        Parent = ColorPicker.Container
    })
    
    Utility:AddCorner(ColorPicker.ColorDisplay, 6)
    Utility:AddStroke(ColorPicker.ColorDisplay, ColorPicker.Library.Theme.Border, 2)
    
    ColorPicker.Button = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ColorPicker.Container
    })
    
    ColorPicker.PickerFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundColor3 = ColorPicker.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = ColorPicker.Container
    })
    
    Utility:AddCorner(ColorPicker.PickerFrame, 8)
    
    -- RGB Sliders
    local rgbLabels = {"R", "G", "B"}
    local rgbValues = {ColorPicker.Default.R * 255, ColorPicker.Default.G * 255, ColorPicker.Default.B * 255}
    ColorPicker.RGBSliders = {}
    
    for i, label in ipairs(rgbLabels) do
        local sliderContainer = Utility:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 35),
            BackgroundTransparency = 1,
            Parent = ColorPicker.PickerFrame
        })
        
        local sliderLabel = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = ColorPicker.Library.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = sliderContainer
        })
        
        local sliderValue = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(math.floor(rgbValues[i])),
            TextColor3 = ColorPicker.Library.Theme.Accent,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = sliderContainer
        })
        
        local sliderBack = Utility:Create("Frame", {
            Size = UDim2.new(1, -70, 0, 6),
            Position = UDim2.new(0, 30, 0.5, -3),
            BackgroundColor3 = ColorPicker.Library.Theme.Border,
            BorderSizePixel = 0,
            Parent = sliderContainer
        })
        
        Utility:AddCorner(sliderBack, 3)
        
        local sliderFill = Utility:Create("Frame", {
            Size = UDim2.new(rgbValues[i] / 255, 0, 1, 0),
            BackgroundColor3 = ColorPicker.Library.Theme.Accent,
            BorderSizePixel = 0,
            Parent = sliderBack
        })
        
        Utility:AddCorner(sliderFill, 3)
        
        local sliderButton = Utility:Create("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(rgbValues[i] / 255, -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Text = "",
            Parent = sliderBack
        })
        
        Utility:AddCorner(sliderButton, 6)
        
        local dragging = false
        
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position.X
                local sliderPos = sliderBack.AbsolutePosition.X
                local sliderSize = sliderBack.AbsoluteSize.X
                
                local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                local value = math.floor(percent * 255)
                
                rgbValues[i] = value
                sliderValue.Text = tostring(value)
                
                Utility:Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                Utility:Tween(sliderButton, {Position = UDim2.new(percent, -6, 0.5, -6)}, 0.05)
                
                ColorPicker:SetValue(Color3.fromRGB(rgbValues[1], rgbValues[2], rgbValues[3]))
            end
        end)
        
        ColorPicker.RGBSliders[i] = {
            Value = sliderValue,
            Fill = sliderFill,
            Button = sliderButton
        }
    end
    
    ColorPicker.Button.MouseButton1Click:Connect(function()
        ColorPicker:Toggle()
    end)
    
    function ColorPicker:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            self.PickerFrame.Visible = true
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 165)}, 0.3)
            Utility:Tween(self.PickerFrame, {Size = UDim2.new(0, 200, 0, 120)}, 0.3)
        else
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 40)}, 0.3)
            Utility:Tween(self.PickerFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.3, nil, nil, function()
                self.PickerFrame.Visible = false
            end)
        end
    end
    
    function ColorPicker:SetValue(color)
        self.Value = color
        self.ColorDisplay.BackgroundColor3 = color
        
        if self.Flag then
            self.Library.Flags[self.Flag] = color
        end
        
        self.Callback(color)
    end
    
    function ColorPicker:UpdateTheme()
        local theme = self.Library.Theme
        ColorPicker.Container.BackgroundColor3 = theme.Background
        ColorPicker.Label.TextColor3 = theme.Text
        ColorPicker.PickerFrame.BackgroundColor3 = theme.Tertiary
    end
    
    if ColorPicker.Flag then
        ColorPicker.Library.Flags[ColorPicker.Flag] = ColorPicker.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, ColorPicker)
    end
    
    return ColorPicker
end

-- Label Element
function UILibrary:CreateLabel(parent, config)
    local Label = {}
    Label.Name = config.Name or "Label"
    Label.Text = config.Text or "Label Text"
    Label.Parent = parent
    Label.Library = parent.Library or parent.Tab.Library
    
    Label.Container = Utility:Create("Frame", {
        Name = Label.Name,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Label.TextLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Label Text",
        TextColor3 = Label.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = Label.Container
    })
    
    function Label:SetText(text)
        self.Text = text
        self.TextLabel.Text = text
    end
    
    function Label:UpdateTheme()
        local theme = self.Library.Theme
        Label.TextLabel.TextColor3 = theme.TextDark
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Label)
    end
    
    return Label
end

-- Paragraph Element
function UILibrary:CreateParagraph(parent, config)
    local Paragraph = {}
    Paragraph.Name = config.Name or "Paragraph"
    Paragraph.Title = config.Title or "Title"
    Paragraph.Content = config.Content or "Content"
    Paragraph.Parent = parent
    Paragraph.Library = parent.Library or parent.Tab.Library
    
    Paragraph.Container = Utility:Create("Frame", {
        Name = Paragraph.Name,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = Paragraph.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Paragraph.Container, 8)
    Utility:AddStroke(Paragraph.Container, Paragraph.Library.Theme.Border, 1)
    
    Paragraph.TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Title or "Title",
        TextColor3 = Paragraph.Library.Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Paragraph.Container
    })
    
    Paragraph.ContentLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, -35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = config.Content or "Content",
        TextColor3 = Paragraph.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Paragraph.Container
    })
    
    function Paragraph:SetTitle(title)
        self.Title = title
        self.TitleLabel.Text = title
    end
    
    function Paragraph:SetContent(content)
        self.Content = content
        self.ContentLabel.Text = content
    end
    
    function Paragraph:UpdateTheme()
        local theme = self.Library.Theme
        Paragraph.Container.BackgroundColor3 = theme.Background
        Paragraph.TitleLabel.TextColor3 = theme.Text
        Paragraph.ContentLabel.TextColor3 = theme.TextDark
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Paragraph)
    end
    
    return Paragraph
end

-- Divider Element
function UILibrary:CreateDivider(parent)
    local Divider = {}
    Divider.Parent = parent
    Divider.Library = parent.Library or parent.Tab.Library
    
    Divider.Container = Utility:Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Divider.Line = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 0.5, -1),
        BackgroundColor3 = Divider.Library.Theme.Border,
        BorderSizePixel = 0,
        Parent = Divider.Container
    })
    
    function Divider:UpdateTheme()
        local theme = self.Library.Theme
        Divider.Line.BackgroundColor3 = theme.Border
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Divider)
    end
    
    return Divider
end

-- Notification System
function UILibrary:Notify(config)
    local Notification = {}
    Notification.Title = config.Title or "Notification"
    Notification.Content = config.Content or "Content"
    Notification.Duration = config.Duration or 3
    Notification.Type = config.Type or "Info" -- Info, Success, Warning, Error
    
    local typeColors = {
        Info = self.Theme.Accent,
        Success = self.Theme.Success,
        Warning = self.Theme.Warning,
        Error = self.Theme.Error
    }
    
    Notification.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, 100),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(Notification.Container, 10)
    Utility:AddStroke(Notification.Container, typeColors[Notification.Type] or self.Theme.Accent, 2)
    
    local shadow = Utility:Create("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = Notification.Container
    })
    
    local iconLabel = Utility:Create("Frame", {
        Size = UDim2.new(0, 6, 1, 0),
        BackgroundColor3 = typeColors[Notification.Type] or self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Notification.Container
    })
    
    Utility:AddCorner(iconLabel, 10)
    
    local iconCover = Utility:Create("Frame", {
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundColor3 = typeColors[Notification.Type] or self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Notification.Container
    })
    
    local titleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 25),
        Position = UDim2.new(0, 20, 0, 10),
        BackgroundTransparency = 1,
        Text = Notification.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification.Container
    })
    
    local contentLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 35),
        Position = UDim2.new(0, 20, 0, 35),
        BackgroundTransparency = 1,
        Text = Notification.Content,
        TextColor3 = self.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Notification.Container
    })
    
    local closeButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = self.Theme.TextDark,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = Notification.Container
    })
    
    closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {TextColor3 = self.Theme.Text}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {TextColor3 = self.Theme.TextDark}, 0.2)
    end)
    
    -- Slide in animation
    local targetPos = UDim2.new(1, -320, 1, -(100 + #self.Notifications * 90))
    Utility:Tween(Notification.Container, {Position = targetPos}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    table.insert(self.Notifications, Notification)
    
    local function Close()
        Utility:Tween(Notification.Container, {
            Position = UDim2.new(1, -320, 1, 100)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            Notification.Container:Destroy()
            
            for i, notif in pairs(self.Notifications) do
                if notif == Notification then
                    table.remove(self.Notifications, i)
                    break
                end
            end
            
            -- Reposition remaining notifications
            for i, notif in pairs(self.Notifications) do
                Utility:Tween(notif.Container, {
                    Position = UDim2.new(1, -320, 1, -(100 + (i - 1) * 90))
                }, 0.3)
            end
        end)
    end
    
    closeButton.MouseButton1Click:Connect(Close)
    
    -- Auto close
    task.delay(Notification.Duration, Close)
    
    return Notification
end

-- Config System
function UILibrary:SaveConfig(name)
    name = name or "default"
    local config = {}
    
    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = {value.R, value.G, value.B}
        elseif typeof(value) == "EnumItem" then
            config[flag] = tostring(value)
        else
            config[flag] = value
        end
    end
    
    writefile(self.Config.Title .. "_" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
    
    self:Notify({
        Title = "Config Saved",
        Content = "Configuration '" .. name .. "' has been saved!",
        Type = "Success",
        Duration = 2
    })
end

function UILibrary:LoadConfig(name)
    name = name or "default"
    local fileName = self.Config.Title .. "_" .. name .. ".json"
    
    if not isfile(fileName) then
        self:Notify({
            Title = "Config Not Found",
            Content = "Configuration '" .. name .. "' does not exist!",
            Type = "Error",
            Duration = 2
        })
        return
    end
    
    local config = game:GetService("HttpService"):JSONDecode(readfile(fileName))
    
    for flag, value in pairs(config) do
        if self.Flags[flag] ~= nil then
            if type(value) == "table" and #value == 3 then
                self.Flags[flag] = Color3.new(value[1], value[2], value[3])
            else
                self.Flags[flag] = value
            end
        end
    end
    
    self:Notify({
        Title = "Config Loaded",
        Content = "Configuration '" .. name .. "' has been loaded!",
        Type = "Success",
        Duration = 2
    })
end

-- Multi-Select Element
function UILibrary:CreateMultiSelect(parent, config)
    local MultiSelect = {}
    MultiSelect.Name = config.Name or "Multi Select"
    MultiSelect.Options = config.Options or {}
    MultiSelect.Default = config.Default or {}
    MultiSelect.Callback = config.Callback or function() end
    MultiSelect.Flag = config.Flag
    MultiSelect.Parent = parent
    MultiSelect.Library = parent.Library or parent.Tab.Library
    MultiSelect.Value = MultiSelect.Default
    MultiSelect.Open = false
    
    MultiSelect.Container = Utility:Create("Frame", {
        Name = MultiSelect.Name,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = MultiSelect.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(MultiSelect.Container, 8)
    Utility:AddStroke(MultiSelect.Container, MultiSelect.Library.Theme.Border, 1)
    
    MultiSelect.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Multi Select",
        TextColor3 = MultiSelect.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = MultiSelect.Container
    })
    
    MultiSelect.SelectedFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = MultiSelect.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = MultiSelect.Container
    })
    
    Utility:AddCorner(MultiSelect.SelectedFrame, 6)
    
    MultiSelect.SelectedLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = #MultiSelect.Default > 0 and table.concat(MultiSelect.Default, ", ") or "None",
        TextColor3 = MultiSelect.Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = MultiSelect.SelectedFrame
    })
    
    MultiSelect.Arrow = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -25, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = MultiSelect.Library.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = MultiSelect.SelectedFrame
    })
    
    MultiSelect.OptionsFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundColor3 = MultiSelect.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = MultiSelect.Container
    })
    
    Utility:AddCorner(MultiSelect.OptionsFrame, 6)
    
    MultiSelect.OptionsList = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = MultiSelect.Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = MultiSelect.OptionsFrame
    })
    
    local optionsLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = MultiSelect.OptionsList
    })
    
    MultiSelect.Button = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "",
        Parent = MultiSelect.Container
    })
    
    MultiSelect.Button.MouseButton1Click:Connect(function()
        MultiSelect:Toggle()
    end)
    
    function MultiSelect:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            self.OptionsFrame.Visible = true
            local targetHeight = math.min(#self.Options * 32, 150)
            
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 70 + targetHeight + 10)}, 0.3)
            Utility:Tween(self.OptionsFrame, {Size = UDim2.new(1, -20, 0, targetHeight)}, 0.3)
            Utility:Tween(self.Arrow, {Rotation = 180}, 0.3)
        else
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 70)}, 0.3)
            Utility:Tween(self.OptionsFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.3, nil, nil, function()
                self.OptionsFrame.Visible = false
            end)
            Utility:Tween(self.Arrow, {Rotation = 0}, 0.3)
        end
    end
    
    function MultiSelect:SetValue(values)
        self.Value = values
        self.SelectedLabel.Text = #values > 0 and table.concat(values, ", ") or "None"
        
        if self.Flag then
            self.Library.Flags[self.Flag] = values
        end
        
        self.Callback(values)
    end
    
    function MultiSelect:Refresh(options)
        self.Options = options
        
        for _, child in pairs(self.OptionsList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, option in pairs(options) do
            local optionFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = self.Library.Theme.Background,
                BorderSizePixel = 0,
                Parent = self.OptionsList
            })
            
            Utility:AddCorner(optionFrame, 4)
            
            local checkbox = Utility:Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 8, 0.5, -9),
                BackgroundColor3 = self.Library.Theme.Tertiary,
                BorderSizePixel = 0,
                Parent = optionFrame
            })
            
            Utility:AddCorner(checkbox, 4)
            Utility:AddStroke(checkbox, self.Library.Theme.Border, 2)
            
            local checkmark = Utility:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "✓",
                TextColor3 = self.Library.Theme.Success,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                Visible = table.find(self.Value, option) ~= nil,
                Parent = checkbox
            })
            
            local optionLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                BackgroundTransparency = 1,
                Text = option,
                TextColor3 = self.Library.Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = optionFrame
            })
            
            local optionButton = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = optionFrame
            })
            
            optionButton.MouseEnter:Connect(function()
                Utility:Tween(optionFrame, {BackgroundColor3 = self.Library.Theme.Accent}, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                Utility:Tween(optionFrame, {BackgroundColor3 = self.Library.Theme.Background}, 0.2)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                local index = table.find(self.Value, option)
                
                if index then
                    table.remove(self.Value, index)
                    checkmark.Visible = false
                else
                    table.insert(self.Value, option)
                    checkmark.Visible = true
                end
                
                self:SetValue(self.Value)
            end)
        end
        
        optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            self.OptionsList.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y)
        end)
    end
    
    MultiSelect:Refresh(MultiSelect.Options)
    
    function MultiSelect:UpdateTheme()
        local theme = self.Library.Theme
        MultiSelect.Container.BackgroundColor3 = theme.Background
        MultiSelect.Label.TextColor3 = theme.Text
        MultiSelect.SelectedFrame.BackgroundColor3 = theme.Tertiary
        MultiSelect.SelectedLabel.TextColor3 = theme.Text
        MultiSelect.Arrow.TextColor3 = theme.TextDark
        MultiSelect.OptionsFrame.BackgroundColor3 = theme.Tertiary
    end
    
    if MultiSelect.Flag then
        MultiSelect.Library.Flags[MultiSelect.Flag] = MultiSelect.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, MultiSelect)
    end
    
    return MultiSelect
end

-- Progress Bar Element
function UILibrary:CreateProgressBar(parent, config)
    local ProgressBar = {}
    ProgressBar.Name = config.Name or "Progress Bar"
    ProgressBar.Max = config.Max or 100
    ProgressBar.Value = config.Value or 0
    ProgressBar.Parent = parent
    ProgressBar.Library = parent.Library or parent.Tab.Library
    
    ProgressBar.Container = Utility:Create("Frame", {
        Name = ProgressBar.Name,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = ProgressBar.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(ProgressBar.Container, 8)
    Utility:AddStroke(ProgressBar.Container, ProgressBar.Library.Theme.Border, 1)
    
    ProgressBar.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Progress Bar",
        TextColor3 = ProgressBar.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ProgressBar.Container
    })
    
    ProgressBar.PercentLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 70, 0, 20),
        Position = UDim2.new(1, -75, 0, 5),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = ProgressBar.Library.Theme.Accent,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = ProgressBar.Container
    })
    
    ProgressBar.BarBack = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 12),
        Position = UDim2.new(0, 10, 1, -18),
        BackgroundColor3 = ProgressBar.Library.Theme.Border,
        BorderSizePixel = 0,
        Parent = ProgressBar.Container
    })
    
    Utility:AddCorner(ProgressBar.BarBack, 6)
    
    ProgressBar.BarFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ProgressBar.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = ProgressBar.BarBack
    })
    
    Utility:AddCorner(ProgressBar.BarFill, 6)
    
    Utility:AddGradient(ProgressBar.BarFill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, ProgressBar.Library.Theme.Accent)
    }), 0)
    
    function ProgressBar:SetValue(value)
        self.Value = math.clamp(value, 0, self.Max)
        local percent = (self.Value / self.Max)
        
        Utility:Tween(self.BarFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.3)
        self.PercentLabel.Text = math.floor(percent * 100) .. "%"
    end
    
    function ProgressBar:UpdateTheme()
        local theme = self.Library.Theme
        ProgressBar.Container.BackgroundColor3 = theme.Background
        ProgressBar.Label.TextColor3 = theme.Text
        ProgressBar.PercentLabel.TextColor3 = theme.Accent
        ProgressBar.BarBack.BackgroundColor3 = theme.Border
        ProgressBar.BarFill.BackgroundColor3 = theme.Accent
    end
    
    ProgressBar:SetValue(ProgressBar.Value)
    
    if parent.Elements then
        table.insert(parent.Elements, ProgressBar)
    end
    
    return ProgressBar
end

-- Image Element
function UILibrary:CreateImage(parent, config)
    local Image = {}
    Image.Name = config.Name or "Image"
    Image.ImageId = config.ImageId or ""
    Image.Size = config.Size or UDim2.new(1, -20, 0, 150)
    Image.Parent = parent
    Image.Library = parent.Library or parent.Tab.Library
    
    Image.Container = Utility:Create("Frame", {
        Name = Image.Name,
        Size = Image.Size,
        BackgroundColor3 = Image.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Image.Container, 8)
    Utility:AddStroke(Image.Container, Image.Library.Theme.Border, 1)
    
    Image.ImageLabel = Utility:Create("ImageLabel", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Image = config.ImageId or "",
        ScaleType = config.ScaleType or Enum.ScaleType.Fit,
        Parent = Image.Container
    })
    
    Utility:AddCorner(Image.ImageLabel, 6)
    
    function Image:SetImage(imageId)
        self.ImageId = imageId
        self.ImageLabel.Image = imageId
    end
    
    function Image:UpdateTheme()
        local theme = self.Library.Theme
        Image.Container.BackgroundColor3 = theme.Background
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Image)
    end
    
    return Image
end

-- Search Box Element
function UILibrary:CreateSearchBox(parent, config)
    local SearchBox = {}
    SearchBox.Name = config.Name or "Search"
    SearchBox.Placeholder = config.Placeholder or "Search..."
    SearchBox.Callback = config.Callback or function() end
    SearchBox.Parent = parent
    SearchBox.Library = parent.Library or parent.Tab.Library
    SearchBox.Value = ""
    
    SearchBox.Container = Utility:Create("Frame", {
        Name = SearchBox.Name,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = SearchBox.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(SearchBox.Container, 8)
    Utility:AddStroke(SearchBox.Container, SearchBox.Library.Theme.Border, 1)
    
    SearchBox.InputFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundColor3 = SearchBox.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = SearchBox.Container
    })
    
    Utility:AddCorner(SearchBox.InputFrame, 6)
    
    local searchIcon = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextColor3 = SearchBox.Library.Theme.TextDark,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        Parent = SearchBox.InputFrame
    })
    
    SearchBox.Input = Utility:Create("TextBox", {
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = SearchBox.Placeholder,
        TextColor3 = SearchBox.Library.Theme.Text,
        PlaceholderColor3 = SearchBox.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchBox.InputFrame
    })
    
    SearchBox.Input.Focused:Connect(function()
        Utility:Tween(SearchBox.InputFrame, {BackgroundColor3 = SearchBox.Library.Theme.Accent}, 0.2)
        Utility:Tween(searchIcon, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
    end)
    
    SearchBox.Input.FocusLost:Connect(function()
        Utility:Tween(SearchBox.InputFrame, {BackgroundColor3 = SearchBox.Library.Theme.Tertiary}, 0.2)
        Utility:Tween(searchIcon, {TextColor3 = SearchBox.Library.Theme.TextDark}, 0.2)
    end)
    
    SearchBox.Input:GetPropertyChangedSignal("Text"):Connect(function()
        SearchBox.Value = SearchBox.Input.Text
        SearchBox.Callback(SearchBox.Value)
    end)
    
    function SearchBox:SetValue(value)
        self.Value = value
        self.Input.Text = value
    end
    
    function SearchBox:UpdateTheme()
        local theme = self.Library.Theme
        SearchBox.Container.BackgroundColor3 = theme.Background
        SearchBox.InputFrame.BackgroundColor3 = theme.Tertiary
        SearchBox.Input.TextColor3 = theme.Text
        SearchBox.Input.PlaceholderColor3 = theme.TextDark
        searchIcon.TextColor3 = theme.TextDark
    end
    
    if parent.Elements then
        table.insert(parent.Elements, SearchBox)
    end
    
    return SearchBox
end

-- Chip/Tag Element
function UILibrary:CreateChip(parent, config)
    local Chip = {}
    Chip.Name = config.Name or "Chip"
    Chip.Text = config.Text or "Tag"
    Chip.Color = config.Color or parent.Library.Theme.Accent
    Chip.Removable = config.Removable or false
    Chip.OnRemove = config.OnRemove or function() end
    Chip.Parent = parent
    Chip.Library = parent.Library or parent.Tab.Library
    
    Chip.Container = Utility:Create("Frame", {
        Name = Chip.Name,
        Size = UDim2.new(0, 80, 0, 28),
        BackgroundColor3 = Chip.Color,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Chip.Container, 14)
    
    Chip.Label = Utility:Create("TextLabel", {
        Size = Chip.Removable and UDim2.new(1, -35, 1, 0) or UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Tag",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Chip.Container
    })
    
    if Chip.Removable then
        Chip.RemoveButton = Utility:Create("TextButton", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -24, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            Parent = Chip.Container
        })
        
        Utility:AddCorner(Chip.RemoveButton, 10)
        
        Chip.RemoveButton.MouseButton1Click:Connect(function()
            Utility:Tween(Chip.Container, {
                Size = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1
            }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                Chip.Container:Destroy()
                Chip.OnRemove()
            end)
        end)
    end
    
    function Chip:SetText(text)
        self.Text = text
        self.Label.Text = text
        
        local textSize = game:GetService("TextService"):GetTextSize(
            text,
            12,
            Enum.Font.GothamSemibold,
            Vector2.new(math.huge, math.huge)
        )
        
        self.Container.Size = UDim2.new(0, textSize.X + (self.Removable and 45 or 20), 0, 28)
    end
    
    function Chip:UpdateTheme()
        -- Chips maintain their custom colors
    end
    
    Chip:SetText(Chip.Text)
    
    if parent.Elements then
        table.insert(parent.Elements, Chip)
    end
    
    return Chip
end

-- Card Element
function UILibrary:CreateCard(parent, config)
    local Card = {}
    Card.Name = config.Name or "Card"
    Card.Title = config.Title or "Card Title"
    Card.Description = config.Description or "Card description"
    Card.Icon = config.Icon
    Card.Parent = parent
    Card.Library = parent.Library or parent.Tab.Library
    
    Card.Container = Utility:Create("Frame", {
        Name = Card.Name,
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundColor3 = Card.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Card.Container, 10)
    Utility:AddStroke(Card.Container, Card.Library.Theme.Border, 1)
    
    if Card.Icon then
        Card.IconLabel = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1,
            Image = Card.Icon,
            Parent = Card.Container
        })
        
        Utility:AddCorner(Card.IconLabel, 8)
    end
    
    Card.TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, Card.Icon and -80 or -30, 0, 25),
        Position = UDim2.new(0, Card.Icon and 75 or 15, 0, 15),
        BackgroundTransparency = 1,
        Text = Card.Title,
        TextColor3 = Card.Library.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card.Container
    })
    
    Card.DescLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, Card.Icon and -80 or -30, 0, 50),
        Position = UDim2.new(0, Card.Icon and 75 or 15, 0, 40),
        BackgroundTransparency = 1,
        Text = Card.Description,
        TextColor3 = Card.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Card.Container
    })
    
    function Card:SetTitle(title)
        self.Title = title
        self.TitleLabel.Text = title
    end
    
    function Card:SetDescription(desc)
        self.Description = desc
        self.DescLabel.Text = desc
    end
    
    function Card:UpdateTheme()
        local theme = self.Library.Theme
        Card.Container.BackgroundColor3 = theme.Background
        Card.TitleLabel.TextColor3 = theme.Text
        Card.DescLabel.TextColor3 = theme.TextDark
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Card)
    end
    
    return Card
end

-- Destroy Function
function UILibrary:Destroy()
    Utility:Tween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        self.ScreenGui:Destroy()
    end)
end

-- Get Flag Value
function UILibrary:GetFlag(flag)
    return self.Flags[flag]
end

-- Set Flag Value
function UILibrary:SetFlag(flag, value)
    self.Flags[flag] = value
end

-- Watermark System
function UILibrary:CreateWatermark(config)
    local Watermark = {}
    Watermark.Text = config.Text or "UI Library"
    Watermark.Position = config.Position or UDim2.new(0, 10, 0, 10)
    
    Watermark.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 30),
        Position = Watermark.Position,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(Watermark.Container, 8)
    Utility:AddStroke(Watermark.Container, self.Theme.Border, 1)
    
    Watermark.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Watermark.Text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark.Container
    })
    
    function Watermark:SetText(text)
        self.Text = text
        self.Label.Text = text
        
        local textSize = game:GetService("TextService"):GetTextSize(
            text,
            13,
            Enum.Font.GothamSemibold,
            Vector2.new(math.huge, math.huge)
        )
        
        self.Container.Size = UDim2.new(0, textSize.X + 20, 0, 30)
    end
    
    function Watermark:Destroy()
        self.Container:Destroy()
    end
    
    Watermark:SetText(Watermark.Text)
    
    return Watermark
end

-- FPS Counter
function UILibrary:CreateFPSCounter(config)
    local FPSCounter = {}
    FPSCounter.Position = config.Position or UDim2.new(1, -110, 0, 10)
    FPSCounter.UpdateRate = config.UpdateRate or 0.5
    
    FPSCounter.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = FPSCounter.Position,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(FPSCounter.Container, 8)
    Utility:AddStroke(FPSCounter.Container, self.Theme.Border, 1)
    
    FPSCounter.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "FPS: 0",
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = FPSCounter.Container
    })
    
    local lastUpdate = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        if tick() - lastUpdate >= FPSCounter.UpdateRate then
            local fps = math.floor(frameCount / (tick() - lastUpdate))
            FPSCounter.Label.Text = "FPS: " .. fps
            
            -- Color based on FPS
            if fps >= 55 then
                FPSCounter.Label.TextColor3 = self.Theme.Success
            elseif fps >= 30 then
                FPSCounter.Label.TextColor3 = self.Theme.Warning
            else
                FPSCounter.Label.TextColor3 = self.Theme.Error
            end
            
            frameCount = 0
            lastUpdate = tick()
        end
    end)
    
    function FPSCounter:Destroy()
        self.Container:Destroy()
    end
    
    return FPSCounter
end

-- Ping Display
function UILibrary:CreatePingDisplay(config)
    local PingDisplay = {}
    PingDisplay.Position = config.Position or UDim2.new(1, -110, 0, 50)
    PingDisplay.UpdateRate = config.UpdateRate or 1
    
    PingDisplay.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = PingDisplay.Position,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(PingDisplay.Container, 8)
    Utility:AddStroke(PingDisplay.Container, self.Theme.Border, 1)
    
    PingDisplay.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Ping: 0ms",
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = PingDisplay.Container
    })
    
    spawn(function()
        while PingDisplay.Container.Parent do
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            PingDisplay.Label.Text = "Ping: " .. ping .. "ms"
            
            -- Color based on ping
            if ping <= 100 then
                PingDisplay.Label.TextColor3 = self.Theme.Success
            elseif ping <= 200 then
                PingDisplay.Label.TextColor3 = self.Theme.Warning
            else
                PingDisplay.Label.TextColor3 = self.Theme.Error
            end
            
            wait(PingDisplay.UpdateRate)
        end
    end)
    
    function PingDisplay:Destroy()
        self.Container:Destroy()
    end
    
    return PingDisplay
end

-- Console/Log Element
function UILibrary:CreateConsole(parent, config)
    local Console = {}
    Console.Name = config.Name or "Console"
    Console.MaxLines = config.MaxLines or 100
    Console.Parent = parent
    Console.Library = parent.Library or parent.Tab.Library
    Console.Lines = {}
    
    Console.Container = Utility:Create("Frame", {
        Name = Console.Name,
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = Console.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Console.Container, 8)
    Utility:AddStroke(Console.Container, Console.Library.Theme.Border, 1)
    
    Console.Header = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Console.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = Console.Container
    })
    
    Utility:AddCorner(Console.Header, 8)
    
    local headerCover = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Console.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = Console.Header
    })
    
    Console.Title = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Console",
        TextColor3 = Console.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Console.Header
    })
    
    Console.ClearButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 22),
        Position = UDim2.new(1, -70, 0.5, -11),
        BackgroundColor3 = Console.Library.Theme.Error,
        BorderSizePixel = 0,
        Text = "Clear",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = Console.Header
    })
    
    Utility:AddCorner(Console.ClearButton, 6)
    
    Console.ClearButton.MouseButton1Click:Connect(function()
        Console:Clear()
    end)
    
    Console.LogFrame = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Console.Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Console.Container
    })
    
    Utility:AddCorner(Console.LogFrame, 6)
    
    Console.LogLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = Console.LogFrame
    })
    
    Console.LogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Console.LogFrame.CanvasSize = UDim2.new(0, 0, 0, Console.LogLayout.AbsoluteContentSize.Y + 5)
        Console.LogFrame.CanvasPosition = Vector2.new(0, Console.LogFrame.CanvasSize.Y.Offset)
    end)
    
    function Console:Log(message, color)
        color = color or self.Library.Theme.Text
        
        local logLine = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -10, 0, 18),
            BackgroundTransparency = 1,
            Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(message),
            TextColor3 = color,
            TextSize = 12,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = false,
            Parent = self.LogFrame
        })
        
        table.insert(self.Lines, logLine)
        
        -- Remove old lines if exceeds max
        if #self.Lines > self.MaxLines then
            self.Lines[1]:Destroy()
            table.remove(self.Lines, 1)
        end
    end
    
    function Console:Clear()
        for _, line in pairs(self.Lines) do
            line:Destroy()
        end
        self.Lines = {}
    end
    
    function Console:UpdateTheme()
        local theme = self.Library.Theme
        Console.Container.BackgroundColor3 = theme.Background
        Console.Header.BackgroundColor3 = theme.Tertiary
        Console.Title.TextColor3 = theme.Text
        Console.ClearButton.BackgroundColor3 = theme.Error
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Console)
    end
    
    return Console
end

-- Tabs with Icons Helper
function UILibrary:AddTabIcon(tab, iconId)
    if tab.IconLabel then
        tab.IconLabel.Image = iconId
    else
        tab.IconLabel = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = self.Theme.TextDark,
            Parent = tab.Button
        })
        
        tab.Label.Position = UDim2.new(0, 35, 0, 0)
        tab.Label.Size = UDim2.new(1, -40, 1, 0)
    end
end

-- Quick Settings Panel
function UILibrary:CreateQuickSettings()
    local QuickSettings = {}
    
    QuickSettings.Button = Utility:Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 1, -50),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "⚙",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(QuickSettings.Button, 20)
    
    local shadow = Utility:Create("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = QuickSettings.Button
    })
    
    QuickSettings.Panel = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 200),
        Position = UDim2.new(1, -50, 1, -260),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(QuickSettings.Panel, 10)
    
    QuickSettings.Open = false
    
    QuickSettings.Button.MouseButton1Click:Connect(function()
        QuickSettings.Open = not QuickSettings.Open
        
        if QuickSettings.Open then
            QuickSettings.Panel.Visible = true
            Utility:Tween(QuickSettings.Panel, {Size = UDim2.new(0, 200, 0, 200)}, 0.3, Enum.EasingStyle.Back)
            Utility:Tween(QuickSettings.Button, {Rotation = 180}, 0.3)
        else
            Utility:Tween(QuickSettings.Panel, {Size = UDim2.new(0, 0, 0, 200)}, 0.3, Enum.EasingStyle.Quad, nil, function()
                QuickSettings.Panel.Visible = false
            end)
            Utility:Tween(QuickSettings.Button, {Rotation = 0}, 0.3)
        end
    end)
    
    -- Theme Selector
    local themeLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Theme",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = QuickSettings.Panel
    })
    
    local themeButtons = {"Dark", "Light", "Ocean", "Sunset"}
    for i, themeName in ipairs(themeButtons) do
        local themeButton = Utility:Create("TextButton", {
            Size = UDim2.new(0, 85, 0, 30),
            Position = UDim2.new(0, 10 + ((i - 1) % 2) * 95, 0, 40 + math.floor((i - 1) / 2) * 35),
            BackgroundColor3 = self.Theme.Tertiary,
            BorderSizePixel = 0,
            Text = themeName,
            TextColor3 = self.Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            Parent = QuickSettings.Panel
        })
        
        Utility:AddCorner(themeButton, 6)
        
        themeButton.MouseEnter:Connect(function()
            Utility:Tween(themeButton, {BackgroundColor3 = self.Theme.Accent}, 0.2)
        end)
        
        themeButton.MouseLeave:Connect(function()
            Utility:Tween(themeButton, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        end)
        
        themeButton.MouseButton1Click:Connect(function()
            self:ChangeTheme(themeName)
        end)
    end
    
    -- Save/Load Config Buttons
    local saveButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 85, 0, 30),
        Position = UDim2.new(0, 10, 0, 150),
        BackgroundColor3 = self.Theme.Success,
        BorderSizePixel = 0,
        Text = "Save",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = QuickSettings.Panel
    })
    
    Utility:AddCorner(saveButton, 6)
    
    saveButton.MouseButton1Click:Connect(function()
        self:SaveConfig()
    end)
    
    local loadButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 85, 0, 30),
        Position = UDim2.new(0, 105, 0, 150),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "Load",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = QuickSettings.Panel
    })
    
    Utility:AddCorner(loadButton, 6)
    
    loadButton.MouseButton1Click:Connect(function()
        self:LoadConfig()
    end)
    
    return QuickSettings
end

return UILibrary

-- Custom Theme Creator
function UILibrary:CreateCustomTheme(name, colors)
    if not colors then return end
    
    Themes[name] = {
        Background = colors.Background or Color3.fromRGB(20, 20, 25),
        Secondary = colors.Secondary or Color3.fromRGB(30, 30, 35),
        Tertiary = colors.Tertiary or Color3.fromRGB(40, 40, 45),
        Accent = colors.Accent or Color3.fromRGB(88, 101, 242),
        AccentHover = colors.AccentHover or Color3.fromRGB(108, 121, 255),
        Text = colors.Text or Color3.fromRGB(255, 255, 255),
        TextDark = colors.TextDark or Color3.fromRGB(180, 180, 180),
        Success = colors.Success or Color3.fromRGB(67, 181, 129),
        Warning = colors.Warning or Color3.fromRGB(250, 166, 26),
        Error = colors.Error or Color3.fromRGB(240, 71, 71),
        Border = colors.Border or Color3.fromRGB(60, 60, 65),
        Shadow = colors.Shadow or Color3.fromRGB(0, 0, 0)
    }
    
    self:Notify({
        Title = "Custom Theme",
        Content = "Theme '" .. name .. "' has been created!",
        Type = "Success",
        Duration = 2
    })
end

-- Get All Theme Names
function UILibrary:GetThemes()
    local themeNames = {}
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    return themeNames
end

-- Animated Background
function UILibrary:CreateAnimatedBackground()
    local animBg = Utility:Create("Frame", {
        Name = "AnimatedBackground",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 0,
        Parent = self.MainFrame
    })
    
    -- Create floating particles
    for i = 1, 15 do
        local particle = Utility:Create("Frame", {
            Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8)),
            Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0),
            BackgroundColor3 = self.Theme.Accent,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 0,
            Parent = animBg
        })
        
        Utility:AddCorner(particle, 999)
        
        -- Animate particles
        spawn(function()
            while particle and particle.Parent do
                local randomX = math.random(0, 100) / 100
                local randomY = math.random(0, 100) / 100
                local duration = math.random(5, 10)
                
                Utility:Tween(particle, {
                    Position = UDim2.new(randomX, 0, randomY, 0),
                    BackgroundTransparency = math.random(50, 90) / 100
                }, duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                
                wait(duration)
            end
        end)
    end
    
    return animBg
end

-- Tooltip System
function UILibrary:CreateTooltip(element, text)
    local tooltip = Utility:Create("Frame", {
        Name = "Tooltip",
        Size = UDim2.new(0, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0, -35),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = self.Theme.Tertiary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
        Parent = element
    })
    
    Utility:AddCorner(tooltip, 6)
    Utility:AddStroke(tooltip, self.Theme.Border, 1)
    
    local tooltipLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = tooltip
    })
    
    local textSize = game:GetService("TextService"):GetTextSize(
        text, 12, Enum.Font.Gotham, Vector2.new(math.huge, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, textSize.X + 20, 0, 30)
    
    element.MouseEnter:Connect(function()
        tooltip.Visible = true
        tooltip.Size = UDim2.new(0, 0, 0, 30)
        Utility:Tween(tooltip, {Size = UDim2.new(0, textSize.X + 20, 0, 30)}, 0.2, Enum.EasingStyle.Back)
    end)
    
    element.MouseLeave:Connect(function()
        Utility:Tween(tooltip, {Size = UDim2.new(0, 0, 0, 30)}, 0.2, Enum.EasingStyle.Quad, nil, function()
            tooltip.Visible = false
        end)
    end)
    
    return tooltip
end

-- Badge System
function UILibrary:CreateBadge(parent, config)
    local Badge = {}
    Badge.Text = config.Text or "NEW"
    Badge.Color = config.Color or parent.Library.Theme.Accent
    Badge.Position = config.Position or UDim2.new(1, -5, 0, 5)
    Badge.Parent = parent
    Badge.Library = parent.Library or parent.Tab.Library
    
    Badge.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 18),
        Position = Badge.Position,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Badge.Color,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = parent.Container or parent.Button
    })
    
    Utility:AddCorner(Badge.Container, 9)
    
    Badge.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = Badge.Text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Badge.Container
    })
    
    local textSize = game:GetService("TextService"):GetTextSize(
        Badge.Text, 10, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge)
    )
    
    Badge.Container.Size = UDim2.new(0, textSize.X + 10, 0, 18)
    
    -- Pulse animation
    Utility:PulseEffect(Badge.Container, "Size", UDim2.new(0, textSize.X + 10, 0, 18), UDim2.new(0, textSize.X + 14, 0, 20), 1)
    
    function Badge:Remove()
        Utility:Tween(self.Container, {
            Size = UDim2.new(0, 0, 0, 18),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            self.Container:Destroy()
        end)
    end
    
    return Badge
end

-- Loading Screen
function UILibrary:CreateLoadingScreen(duration)
    local LoadingScreen = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = self.MainFrame
    })
    
    local loadingCircle = Utility:Create("Frame", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.5, -30, 0.5, -30),
        BackgroundTransparency = 1,
        Parent = LoadingScreen
    })
    
    for i = 1, 8 do
        local dot = Utility:Create("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0.5, -4, 0.5, -4),
            BackgroundColor3 = self.Theme.Accent,
            BorderSizePixel = 0,
            Parent = loadingCircle
        })
        
        Utility:AddCorner(dot, 4)
        
        local angle = (i - 1) * (360 / 8)
        local rad = math.rad(angle)
        local x = math.cos(rad) * 25
        local y = math.sin(rad) * 25
        
        dot.Position = UDim2.new(0.5, x - 4, 0.5, y - 4)
        
        spawn(function()
            while dot and dot.Parent do
                Utility:Tween(dot, {BackgroundTransparency = 0.8}, 0.4)
                wait(0.1 * i)
                Utility:Tween(dot, {BackgroundTransparency = 0}, 0.4)
                wait(0.8 - (0.1 * i))
            end
        end)
    end
    
    local loadingText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0.5, -100, 0.5, 50),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = LoadingScreen
    })
    
    task.delay(duration or 2, function()
        Utility:Tween(LoadingScreen, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            LoadingScreen:Destroy()
        end)
        
        for _, child in pairs(loadingCircle:GetChildren()) do
            Utility:Tween(child, {BackgroundTransparency = 1}, 0.5)
        end
        
        Utility:Tween(loadingText, {TextTransparency = 1}, 0.5)
    end)
    
    return LoadingScreen
end

-- Context Menu
function UILibrary:CreateContextMenu(options, position)
    local ContextMenu = {}
    ContextMenu.Options = options or {}
    ContextMenu.Position = position or UDim2.new(0, Mouse.X, 0, Mouse.Y)
    
    ContextMenu.Container = Utility:Create("Frame", {
        Size = UDim2.new(0, 150, 0, #options * 32 + 10),
        Position = ContextMenu.Position,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(ContextMenu.Container, 8)
    Utility:AddStroke(ContextMenu.Container, self.Theme.Border, 1)
    
    local shadow = Utility:Create("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 199,
        Parent = ContextMenu.Container
    })
    
    local listLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = ContextMenu.Container
    })
    
    Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = ContextMenu.Container
    })
    
    for _, option in pairs(options) do
        local optionButton = Utility:Create("TextButton", {
            Size = UDim2.new(1, -10, 0, 28),
            BackgroundColor3 = self.Theme.Tertiary,
            BorderSizePixel = 0,
            Text = option.Name or "Option",
            TextColor3 = self.Theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ContextMenu.Container
        })
        
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = optionButton
        })
        
        Utility:AddCorner(optionButton, 6)
        
        optionButton.MouseEnter:Connect(function()
            Utility:Tween(optionButton, {BackgroundColor3 = self.Theme.Accent}, 0.2)
        end)
        
        optionButton.MouseLeave:Connect(function()
            Utility:Tween(optionButton, {BackgroundColor3 = self.Theme.Tertiary}, 0.2)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            if option.Callback then
                option.Callback()
            end
            ContextMenu:Close()
        end)
    end
    
    function ContextMenu:Close()
        Utility:Tween(self.Container, {
            Size = UDim2.new(0, 150, 0, 0),
            BackgroundTransparency = 1
        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            self.Container:Destroy()
        end)
    end
    
    -- Close on click outside
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local containerPos = ContextMenu.Container.AbsolutePosition
            local containerSize = ContextMenu.Container.AbsoluteSize
            
            if mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
               mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + containerSize.Y then
                ContextMenu:Close()
                closeConnection:Disconnect()
            end
        end
    end)
    
    return ContextMenu
end

-- Tabs with Badges
function UILibrary:AddTabBadge(tab, text, color)
    return self:CreateBadge(tab, {
        Text = text,
        Color = color,
        Position = UDim2.new(1, -5, 0, 5)
    })
end

-- Animated Title
function UILibrary:AnimateTitle(text, duration)
    local originalText = self.TitleLabel.Text
    self.TitleLabel.Text = ""
    
    spawn(function()
        for i = 1, #text do
            self.TitleLabel.Text = string.sub(text, 1, i)
            wait((duration or 1) / #text)
        end
    end)
end

-- Rainbow Mode
function UILibrary:EnableRainbowMode(enabled)
    if enabled then
        self.RainbowMode = true
        spawn(function()
            while self.RainbowMode do
                for hue = 0, 1, 0.01 do
                    if not self.RainbowMode then break end
                    local color = Color3.fromHSV(hue, 1, 1)
                    
                    for _, tab in pairs(self.Tabs) do
                        if tab.Selected then
                            Utility:Tween(tab.Button, {BackgroundColor3 = color}, 0.1)
                        end
                    end
                    
                    wait(0.05)
                end
            end
        end)
    else
        self.RainbowMode = false
    end
end

-- Advanced Slider with Input
function UILibrary:CreateAdvancedSlider(parent, config)
    local Slider = {}
    Slider.Name = config.Name or "Slider"
    Slider.Min = config.Min or 0
    Slider.Max = config.Max or 100
    Slider.Default = config.Default or Slider.Min
    Slider.Increment = config.Increment or 1
    Slider.Callback = config.Callback or function() end
    Slider.Flag = config.Flag
    Slider.Parent = parent
    Slider.Library = parent.Library or parent.Tab.Library
    Slider.Value = Slider.Default
    Slider.Dragging = false
    
    Slider.Container = Utility:Create("Frame", {
        Name = Slider.Name,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Slider.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Slider.Container, 8)
    Utility:AddStroke(Slider.Container, Slider.Library.Theme.Border, 1)
    
    Slider.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Slider",
        TextColor3 = Slider.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Slider.Container
    })
    
    -- Value Input Box
    Slider.ValueInput = Utility:Create("TextBox", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = Slider.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = tostring(Slider.Default),
        TextColor3 = Slider.Library.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Slider.Container
    })
    
    Utility:AddCorner(Slider.ValueInput, 4)
    
    Slider.ValueInput.FocusLost:Connect(function()
        local value = tonumber(Slider.ValueInput.Text)
        if value then
            Slider:SetValue(value)
        else
            Slider.ValueInput.Text = tostring(Slider.Value)
        end
    end)
    
    Slider.SliderBack = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 8),
        Position = UDim2.new(0, 10, 1, -18),
        BackgroundColor3 = Slider.Library.Theme.Border,
        BorderSizePixel = 0,
        Parent = Slider.Container
    })
    
    Utility:AddCorner(Slider.SliderBack, 4)
    
    local fillPercent = (Slider.Default - Slider.Min) / (Slider.Max - Slider.Min)
    
    Slider.SliderFill = Utility:Create("Frame", {
        Size = UDim2.new(fillPercent, 0, 1, 0),
        BackgroundColor3 = Slider.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Slider.SliderBack
    })
    
    Utility:AddCorner(Slider.SliderFill, 4)
    Utility:AddGradient(Slider.SliderFill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Slider.Library.Theme.Accent),
        ColorSequenceKeypoint.new(1, Slider.Library.Theme.AccentHover)
    }), 90)
    
    Slider.SliderButton = Utility:Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(fillPercent, -9, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = Slider.SliderBack
    })
    
    Utility:AddCorner(Slider.SliderButton, 9)
    Utility:AddStroke(Slider.SliderButton, Slider.Library.Theme.Accent, 3)
    Utility:GlowEffect(Slider.SliderButton, Slider.Library.Theme.Accent)
    
    local sliderButtonInput = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Slider.SliderButton
    })
    
    function Slider:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        
        Utility:Tween(self.SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        Utility:Tween(self.SliderButton, {Position = UDim2.new(percent, -9, 0.5, -9)}, 0.1)
        
        self.ValueInput.Text = tostring(value)
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    sliderButtonInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = true
            Utility:Tween(Slider.SliderButton, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -11, 0.5, -11)}, 0.2)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = false
            Utility:Tween(Slider.SliderButton, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -9, 0.5, -9)}, 0.2)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = Slider.SliderBack.AbsolutePosition.X
            local sliderSize = Slider.SliderBack.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = Slider.Min + (Slider.Max - Slider.Min) * percent
            
            Slider:SetValue(value)
        end
    end)
    
    function Slider:UpdateTheme()
        local theme = self.Library.Theme
        Slider.Container.BackgroundColor3 = theme.Background
        Slider.Label.TextColor3 = theme.Text
        Slider.ValueInput.BackgroundColor3 = theme.Tertiary
        Slider.ValueInput.TextColor3 = theme.Accent
        Slider.SliderBack.BackgroundColor3 = theme.Border
        Slider.SliderFill.BackgroundColor3 = theme.Accent
    end
    
    if Slider.Flag then
        Slider.Library.Flags[Slider.Flag] = Slider.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Slider)
    end
    
    return Slider
end

-- Radio Button Group
function UILibrary:CreateRadioGroup(parent, config)
    local RadioGroup = {}
    RadioGroup.Name = config.Name or "Radio Group"
    RadioGroup.Options = config.Options or {}
    RadioGroup.Default = config.Default or (RadioGroup.Options[1] or "None")
    RadioGroup.Callback = config.Callback or function() end
    RadioGroup.Flag = config.Flag
    RadioGroup.Parent = parent
    RadioGroup.Library = parent.Library or parent.Tab.Library
    RadioGroup.Value = RadioGroup.Default
    RadioGroup.Buttons = {}
    
    local height = 30 + (#RadioGroup.Options * 32)
    
    RadioGroup.Container = Utility:Create("Frame", {
        Name = RadioGroup.Name,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = RadioGroup.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(RadioGroup.Container, 8)
    Utility:AddStroke(RadioGroup.Container, RadioGroup.Library.Theme.Border, 1)
    
    RadioGroup.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Radio Group",
        TextColor3 = RadioGroup.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = RadioGroup.Container
    })
    
    for i, option in ipairs(RadioGroup.Options) do
        local radioButton = Utility:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.new(0, 10, 0, 30 + (i - 1) * 32),
            BackgroundColor3 = RadioGroup.Library.Theme.Tertiary,
            BorderSizePixel = 0,
            Parent = RadioGroup.Container
        })
        
        Utility:AddCorner(radioButton, 6)
        
        local radioCircle = Utility:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 8, 0.5, -8),
            BackgroundColor3 = RadioGroup.Library.Theme.Background,
            BorderSizePixel = 0,
            Parent = radioButton
        })
        
        Utility:AddCorner(radioCircle, 8)
        Utility:AddStroke(radioCircle, RadioGroup.Library.Theme.Border, 2)
        
        local radioInner = Utility:Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = RadioGroup.Library.Theme.Accent,
            BorderSizePixel = 0,
            Parent = radioCircle
        })
        
        Utility:AddCorner(radioInner, 999)
        
        local radioLabel = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = RadioGroup.Library.Theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = radioButton
        })
        
        local radioButtonClick = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = radioButton
        })
        
        radioButtonClick.MouseEnter:Connect(function()
            Utility:Tween(radioButton, {BackgroundColor3 = RadioGroup.Library.Theme.Accent}, 0.2)
        end)
        
        radioButtonClick.MouseLeave:Connect(function()
            Utility:Tween(radioButton, {BackgroundColor3 = RadioGroup.Library.Theme.Tertiary}, 0.2)
        end)
        
        radioButtonClick.MouseButton1Click:Connect(function()
            RadioGroup:SetValue(option)
        end)
        
        RadioGroup.Buttons[option] = {
            Button = radioButton,
            Circle = radioCircle,
            Inner = radioInner
        }
        
        if option == RadioGroup.Default then
            Utility:Tween(radioInner, {Size = UDim2.new(0, 8, 0, 8)}, 0.2)
        end
    end
    
    function RadioGroup:SetValue(value)
        self.Value = value
        
        for option, elements in pairs(self.Buttons) do
            if option == value then
                Utility:Tween(elements.Inner, {Size = UDim2.new(0, 8, 0, 8)}, 0.2, Enum.EasingStyle.Back)
            else
                Utility:Tween(elements.Inner, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            end
        end
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    function RadioGroup:UpdateTheme()
        local theme = self.Library.Theme
        RadioGroup.Container.BackgroundColor3 = theme.Background
        RadioGroup.Label.TextColor3 = theme.Text
        
        for _, elements in pairs(RadioGroup.Buttons) do
            elements.Button.BackgroundColor3 = theme.Tertiary
            elements.Circle.BackgroundColor3 = theme.Background
            elements.Inner.BackgroundColor3 = theme.Accent
        end
    end
    
    if RadioGroup.Flag then
        RadioGroup.Library.Flags[RadioGroup.Flag] = RadioGroup.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, RadioGroup)
    end
    
    return RadioGroup
end

-- Accordion/Collapsible Section
function UILibrary:CreateAccordion(parent, config)
    local Accordion = {}
    Accordion.Name = config.Name or "Accordion"
    Accordion.Content = config.Content or "Content"
    Accordion.Open = config.DefaultOpen or false
    Accordion.Parent = parent
    Accordion.Library = parent.Library or parent.Tab.Library
    
    Accordion.Container = Utility:Create("Frame", {
        Name = Accordion.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Accordion.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Accordion.Container, 8)
    Utility:AddStroke(Accordion.Container, Accordion.Library.Theme.Border, 1)
    
    Accordion.Header = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Accordion.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = Accordion.Container
    })
    
    Utility:AddCorner(Accordion.Header, 8)
    
    Accordion.Arrow = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▶",
        TextColor3 = Accordion.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Rotation = Accordion.Open and 90 or 0,
        Parent = Accordion.Header
    })
    
    Accordion.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Accordion",
        TextColor3 = Accordion.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Accordion.Header
    })
    
    Accordion.ContentFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = Accordion.Open,
        Parent = Accordion.Container
    })
    
    Accordion.ContentLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Content or "Content",
        TextColor3 = Accordion.Library.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Accordion.ContentFrame
    })
    
    local textSize = game:GetService("TextService"):GetTextSize(
        config.Content or "Content",
        13,
        Enum.Font.Gotham,
        Vector2.new(Accordion.ContentFrame.AbsoluteSize.X, math.huge)
    )
    
    local contentHeight = textSize.Y + 10
    
    if Accordion.Open then
        Accordion.ContentFrame.Size = UDim2.new(1, -20, 0, contentHeight)
        Accordion.Container.Size = UDim2.new(1, 0, 0, 50 + contentHeight)
    end
    
    local headerButton = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Accordion.Header
    })
    
    headerButton.MouseButton1Click:Connect(function()
        Accordion:Toggle()
    end)
    
    function Accordion:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            self.ContentFrame.Visible = true
            Utility:Tween(self.Arrow, {Rotation = 90}, 0.3)
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 50 + contentHeight)}, 0.3)
            Utility:Tween(self.ContentFrame, {Size = UDim2.new(1, -20, 0, contentHeight)}, 0.3)
        else
            Utility:Tween(self.Arrow, {Rotation = 0}, 0.3)
            Utility:Tween(self.Container, {Size = UDim2.new(1, 0, 0, 40)}, 0.3)
            Utility:Tween(self.ContentFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.3, nil, nil, function()
                self.ContentFrame.Visible = false
            end)
        end
    end
    
    function Accordion:UpdateTheme()
        local theme = self.Library.Theme
        Accordion.Container.BackgroundColor3 = theme.Background
        Accordion.Header.BackgroundColor3 = theme.Tertiary
        Accordion.Label.TextColor3 = theme.Text
        Accordion.Arrow.TextColor3 = theme.Text
        Accordion.ContentLabel.TextColor3 = theme.TextDark
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Accordion)
    end
    
    return Accordion
end

-- Tab Groups (Sub-tabs)
function UILibrary:CreateTabGroup(tab, name)
    local TabGroup = {}
    TabGroup.Name = name
    TabGroup.Tab = tab
    TabGroup.Library = tab.Library
    TabGroup.SubTabs = {}
    
    TabGroup.Container = Utility:Create("Frame", {
        Name = name .. "Group",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = TabGroup.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = tab.Content
    })
    
    Utility:AddCorner(TabGroup.Container, 8)
    
    TabGroup.SubTabList = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Parent = TabGroup.Container
    })
    
    local subTabLayout = Utility:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabGroup.SubTabList
    })
    
    function TabGroup:CreateSubTab(name)
        local SubTab = {}
        SubTab.Name = name
        SubTab.Group = self
        SubTab.Library = self.Library
        SubTab.Elements = {}
        
        SubTab.Button = Utility:Create("TextButton", {
            Size = UDim2.new(0, 100, 0, 32),
            BackgroundColor3 = self.Library.Theme.Background,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = self.Library.Theme.TextDark,
            TextSize = 13,
            Font = Enum.Font.GothamSemibold,
            Parent = self.SubTabList
        })
        
        Utility:AddCorner(SubTab.Button, 6)
        
        SubTab.Content = Utility:Create("ScrollingFrame", {
            Name = name .. "SubContent",
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 50),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = self.Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = self.Tab.Content
        })
        
        local contentLayout = Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = SubTab.Content
        })
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SubTab.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        SubTab.Button.MouseButton1Click:Connect(function()
            self:SelectSubTab(SubTab)
        end)
        
        SubTab.Button.MouseEnter:Connect(function()
            if not SubTab.Selected then
                Utility:Tween(SubTab.Button, {BackgroundColor3 = self.Library.Theme.Accent}, 0.2)
                Utility:Tween(SubTab.Button, {TextColor3 = self.Library.Theme.Text}, 0.2)
            end
        end)
        
        SubTab.Button.MouseLeave:Connect(function()
            if not SubTab.Selected then
                Utility:Tween(SubTab.Button, {BackgroundColor3 = self.Library.Theme.Background}, 0.2)
                Utility:Tween(SubTab.Button, {TextColor3 = self.Library.Theme.TextDark}, 0.2)
            end
        end)
        
        table.insert(self.SubTabs, SubTab)
        
        if #self.SubTabs == 1 then
            self:SelectSubTab(SubTab)
        end
        
        return SubTab
    end
    
    function TabGroup:SelectSubTab(subTab)
        for _, st in pairs(self.SubTabs) do
            st.Selected = false
            st.Content.Visible = false
            Utility:Tween(st.Button, {BackgroundColor3 = self.Library.Theme.Background}, 0.2)
            Utility:Tween(st.Button, {TextColor3 = self.Library.Theme.TextDark}, 0.2)
        end
        
        subTab.Selected = true
        subTab.Content.Visible = true
        Utility:Tween(subTab.Button, {BackgroundColor3 = self.Library.Theme.Accent}, 0.2)
        Utility:Tween(subTab.Button, {TextColor3 = self.Library.Theme.Text}, 0.2)
    end
    
    return TabGroup
end

-- Stepper Element
function UILibrary:CreateStepper(parent, config)
    local Stepper = {}
    Stepper.Name = config.Name or "Stepper"
    Stepper.Min = config.Min or 0
    Stepper.Max = config.Max or 100
    Stepper.Default = config.Default or Stepper.Min
    Stepper.Increment = config.Increment or 1
    Stepper.Callback = config.Callback or function() end
    Stepper.Flag = config.Flag
    Stepper.Parent = parent
    Stepper.Library = parent.Library or parent.Tab.Library
    Stepper.Value = Stepper.Default
    
    Stepper.Container = Utility:Create("Frame", {
        Name = Stepper.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Stepper.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(Stepper.Container, 8)
    Utility:AddStroke(Stepper.Container, Stepper.Library.Theme.Border, 1)
    
    Stepper.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Stepper",
        TextColor3 = Stepper.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Stepper.Container
    })
    
    Stepper.ValueLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 30),
        Position = UDim2.new(1, -120, 0.5, -15),
        BackgroundColor3 = Stepper.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = tostring(Stepper.Default),
        TextColor3 = Stepper.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = Stepper.Container
    })
    
    Utility:AddCorner(Stepper.ValueLabel, 6)
    
    Stepper.MinusButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -60, 0.5, -15),
        BackgroundColor3 = Stepper.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = Stepper.Library.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Stepper.Container
    })
    
    Utility:AddCorner(Stepper.MinusButton, 6)
    
    Stepper.PlusButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -25, 0.5, -15),
        BackgroundColor3 = Stepper.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "+",
        TextColor3 = Stepper.Library.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Stepper.Container
    })
    
    Utility:AddCorner(Stepper.PlusButton, 6)
    
    Stepper.MinusButton.MouseEnter:Connect(function()
        Utility:Tween(Stepper.MinusButton, {BackgroundColor3 = Stepper.Library.Theme.Accent}, 0.2)
    end)
    
    Stepper.MinusButton.MouseLeave:Connect(function()
        Utility:Tween(Stepper.MinusButton, {BackgroundColor3 = Stepper.Library.Theme.Tertiary}, 0.2)
    end)
    
    Stepper.PlusButton.MouseEnter:Connect(function()
        Utility:Tween(Stepper.PlusButton, {BackgroundColor3 = Stepper.Library.Theme.Accent}, 0.2)
    end)
    
    Stepper.PlusButton.MouseLeave:Connect(function()
        Utility:Tween(Stepper.PlusButton, {BackgroundColor3 = Stepper.Library.Theme.Tertiary}, 0.2)
    end)
    
    Stepper.MinusButton.MouseButton1Click:Connect(function()
        Stepper:SetValue(Stepper.Value - Stepper.Increment)
    end)
    
    Stepper.PlusButton.MouseButton1Click:Connect(function()
        Stepper:SetValue(Stepper.Value + Stepper.Increment)
    end)
    
    function Stepper:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        self.Value = value
        
        self.ValueLabel.Text = tostring(value)
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    function Stepper:UpdateTheme()
        local theme = self.Library.Theme
        Stepper.Container.BackgroundColor3 = theme.Background
        Stepper.Label.TextColor3 = theme.Text
        Stepper.ValueLabel.BackgroundColor3 = theme.Tertiary
        Stepper.ValueLabel.TextColor3 = theme.Text
        Stepper.MinusButton.BackgroundColor3 = theme.Tertiary
        Stepper.MinusButton.TextColor3 = theme.Text
        Stepper.PlusButton.BackgroundColor3 = theme.Tertiary
        Stepper.PlusButton.TextColor3 = theme.Text
    end
    
    if Stepper.Flag then
        Stepper.Library.Flags[Stepper.Flag] = Stepper.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, Stepper)
    end
    
    return Stepper
end

-- Time Picker
function UILibrary:CreateTimePicker(parent, config)
    local TimePicker = {}
    TimePicker.Name = config.Name or "Time Picker"
    TimePicker.Default = config.Default or {Hour = 12, Minute = 0}
    TimePicker.Callback = config.Callback or function() end
    TimePicker.Flag = config.Flag
    TimePicker.Parent = parent
    TimePicker.Library = parent.Library or parent.Tab.Library
    TimePicker.Value = TimePicker.Default
    
    TimePicker.Container = Utility:Create("Frame", {
        Name = TimePicker.Name,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = TimePicker.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(TimePicker.Container, 8)
    Utility:AddStroke(TimePicker.Container, TimePicker.Library.Theme.Border, 1)
    
    TimePicker.Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Name or "Time Picker",
        TextColor3 = TimePicker.Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TimePicker.Container
    })
    
    -- Hour Input
    TimePicker.HourInput = Utility:Create("TextBox", {
        Size = UDim2.new(0, 50, 0, 35),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = TimePicker.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = string.format("%02d", TimePicker.Default.Hour),
        PlaceholderText = "HH",
        TextColor3 = TimePicker.Library.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = TimePicker.Container
    })
    
    Utility:AddCorner(TimePicker.HourInput, 6)
    
    -- Separator
    local separator = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 35),
        Position = UDim2.new(0, 65, 0, 30),
        BackgroundTransparency = 1,
        Text = ":",
        TextColor3 = TimePicker.Library.Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = TimePicker.Container
    })
    
    -- Minute Input
    TimePicker.MinuteInput = Utility:Create("TextBox", {
        Size = UDim2.new(0, 50, 0, 35),
        Position = UDim2.new(0, 90, 0, 30),
        BackgroundColor3 = TimePicker.Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = string.format("%02d", TimePicker.Default.Minute),
        PlaceholderText = "MM",
        TextColor3 = TimePicker.Library.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = TimePicker.Container
    })
    
    Utility:AddCorner(TimePicker.MinuteInput, 6)
    
    TimePicker.HourInput.FocusLost:Connect(function()
        local hour = tonumber(TimePicker.HourInput.Text) or 0
        hour = math.clamp(hour, 0, 23)
        TimePicker.HourInput.Text = string.format("%02d", hour)
        TimePicker:SetValue({Hour = hour, Minute = TimePicker.Value.Minute})
    end)
    
    TimePicker.MinuteInput.FocusLost:Connect(function()
        local minute = tonumber(TimePicker.MinuteInput.Text) or 0
        minute = math.clamp(minute, 0, 59)
        TimePicker.MinuteInput.Text = string.format("%02d", minute)
        TimePicker:SetValue({Hour = TimePicker.Value.Hour, Minute = minute})
    end)
    
    function TimePicker:SetValue(value)
        self.Value = value
        self.HourInput.Text = string.format("%02d", value.Hour)
        self.MinuteInput.Text = string.format("%02d", value.Minute)
        
        if self.Flag then
            self.Library.Flags[self.Flag] = value
        end
        
        self.Callback(value)
    end
    
    function TimePicker:UpdateTheme()
        local theme = self.Library.Theme
        TimePicker.Container.BackgroundColor3 = theme.Background
        TimePicker.Label.TextColor3 = theme.Text
        TimePicker.HourInput.BackgroundColor3 = theme.Tertiary
        TimePicker.HourInput.TextColor3 = theme.Text
        TimePicker.MinuteInput.BackgroundColor3 = theme.Tertiary
        TimePicker.MinuteInput.TextColor3 = theme.Text
    end
    
    if TimePicker.Flag then
        TimePicker.Library.Flags[TimePicker.Flag] = TimePicker.Value
    end
    
    if parent.Elements then
        table.insert(parent.Elements, TimePicker)
    end
    
    return TimePicker
end

-- Info Box with Icon
function UILibrary:CreateInfoBox(parent, config)
    local InfoBox = {}
    InfoBox.Name = config.Name or "Info"
    InfoBox.Text = config.Text or "Information"
    InfoBox.Type = config.Type or "Info" -- Info, Success, Warning, Error
    InfoBox.Parent = parent
    InfoBox.Library = parent.Library or parent.Tab.Library
    
    local typeColors = {
        Info = InfoBox.Library.Theme.Accent,
        Success = InfoBox.Library.Theme.Success,
        Warning = InfoBox.Library.Theme.Warning,
        Error = InfoBox.Library.Theme.Error
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✕"
    }
    
    InfoBox.Container = Utility:Create("Frame", {
        Name = InfoBox.Name,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = InfoBox.Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = parent.ElementsContainer or parent.Content
    })
    
    Utility:AddCorner(InfoBox.Container, 8)
    Utility:AddStroke(InfoBox.Container, typeColors[InfoBox.Type], 2)
    
    InfoBox.IconFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 40, 1, 0),
        BackgroundColor3 = typeColors[InfoBox.Type],
        BorderSizePixel = 0,
        Parent = InfoBox.Container
    })
    
    Utility:AddCorner(InfoBox.IconFrame, 8)
    
    local iconCover = Utility:Create("Frame", {
        Size = UDim2.new(0, 8, 1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        BackgroundColor3 = typeColors[InfoBox.Type],
        BorderSizePixel = 0,
        Parent = InfoBox.IconFrame
    })
    
    InfoBox.Icon = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = typeIcons[InfoBox.Type],
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = InfoBox.IconFrame
    })
    
    InfoBox.TextLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, -10),
        Position = UDim2.new(0, 50, 0, 5),
        BackgroundTransparency = 1,
        Text = config.Text or "Information",
        TextColor3 = InfoBox.Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Parent = InfoBox.Container
    })
    
    function InfoBox:SetText(text)
        self.Text = text
        self.TextLabel.Text = text
    end
    
    function InfoBox:UpdateTheme()
        local theme = self.Library.Theme
        InfoBox.Container.BackgroundColor3 = theme.Background
        InfoBox.TextLabel.TextColor3 = theme.Text
    end
    
    if parent.Elements then
        table.insert(parent.Elements, InfoBox)
    end
    
    return InfoBox
end

return UILibrary
