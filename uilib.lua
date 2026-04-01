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
        Border = Color3.fromRGB(60, 60, 65)
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
        Border = Color3.fromRGB(220, 220, 225)
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
        Border = Color3.fromRGB(71, 85, 105)
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
        Border = Color3.fromRGB(86, 70, 105)
    }
}

-- Main Library
function UILibrary:New(config)
    local self = setmetatable({}, UILibrary)
    
    self.Config = {
        Title = config.Title or "UI Library",
        Theme = config.Theme or "Dark",
        Size = config.Size or UDim2.new(0, 550, 0, 600),
        Position = config.Position or UDim2.new(0.5, -275, 0.5, -300),
        Draggable = config.Draggable ~= false,
        MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightControl,
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
    self.OriginalSize = self.Config.Size
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.MinimizeKey then
            self:ToggleMinimize()
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
