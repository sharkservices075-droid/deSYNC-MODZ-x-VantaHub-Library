

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- [[ ASSETS & CONFIG ]]
local Titanium = {
    Settings = {
        Colors = {
            Main = Color3.fromRGB(28, 28, 30), -- iOS Dark Mode Background
            Sidebar = Color3.fromRGB(36, 36, 38), -- Slightly lighter
            Element = Color3.fromRGB(44, 44, 46), -- Element BG
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(160, 160, 165),
            Stroke = Color3.fromRGB(60, 60, 65),
            Divider = Color3.fromRGB(50, 50, 55),
            Accent = Color3.fromRGB(10, 132, 255), -- iOS Blue
            Green = Color3.fromRGB(48, 209, 88),
            Red = Color3.fromRGB(255, 69, 58)
        },
        Font = {
            Bold = Enum.Font.GothamBold,
            Medium = Enum.Font.GothamMedium,
            Regular = Enum.Font.Gotham
        }
    }
}

-- [[ ICONS (LUCIDE) ]]
local Icons = {
    Home = "rbxassetid://6031091009",
    Settings = "rbxassetid://6031280882",
    Player = "rbxassetid://6031265976",
    Combat = "rbxassetid://6031068428",
    Visuals = "rbxassetid://6031079024",
    List = "rbxassetid://6031094670",
    Search = "rbxassetid://6031154871"
}

-- [[ MODULE: UTILITY ]]
local Utility = {}

function Utility:Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

function Utility:AddShadow(frame, transparency)
    -- Increased transparency for a less intense shadow
    local shadowTransparency = transparency or 0.7 
    local Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = shadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = frame
    })
    -- Add rounding to the shadow itself
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 18), Parent = Shadow})
    return Shadow
end

function Utility:Ripple(obj)
    spawn(function()
        local Ripple = Utility:Create("ImageLabel", {
            Name = "Ripple",
            Parent = obj,
            BackgroundTransparency = 1,
            ZIndex = 9,
            Image = "rbxassetid://2708891598",
            ImageTransparency = 0.8,
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5)
        })
        
        local Size = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        -- Calculate position relative to object
        local relativeX = Mouse.X - obj.AbsolutePosition.X
        local relativeY = Mouse.Y - obj.AbsolutePosition.Y
        
        Ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
        Ripple.Size = UDim2.new(0,0,0,0)
        
        local t1 = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, Size, 0, Size),
            ImageTransparency = 1
        })
        t1:Play()
        t1.Completed:Wait()
        Ripple:Destroy()
    end)
end

-- [[ MAIN UI ]]
function Titanium:Window(Config)
    local Title = Config.Name or "Titanium V4"
    local IsMobile = InputService.TouchEnabled
    
    local GUI = Utility:Create("ScreenGui", {
        Name = "Titanium_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    if syn and syn.protect_gui then 
        syn.protect_gui(GUI)
        GUI.Parent = CoreGui
    elseif gethui then
        GUI.Parent = gethui()
    else
        GUI.Parent = Player:WaitForChild("PlayerGui")
    end

    -- // MAIN FRAME //
    -- Using CanvasGroup for that crisp Corner Clipping
    local Main = Utility:Create("CanvasGroup", {
        Name = "Main",
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Titanium.Settings.Colors.Main,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        Parent = GUI
    })
    
    -- Mobile Sizing
    if IsMobile then
        Main.Size = UDim2.new(0, 500, 0, 320)
        Main.Position = UDim2.new(0.5, -250, 0.5, -160)
    end
    
    -- Styling
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Main})
    Utility:Create("UIStroke", {
        Color = Titanium.Settings.Colors.Stroke, 
        Thickness = 1, 
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.5,
        Parent = Main
    })
    
    -- Shadow (Behind Main)
    local MainShadow = Utility:Create("Frame", {
        Name = "ShadowHolder",
        BackgroundTransparency = 1,
        Size = Main.Size,
        Position = Main.Position,
        ZIndex = -1,
        Parent = GUI
    })
    -- Increased transparency and added rounding to shadow
    Utility:AddShadow(MainShadow, 0.7)

    -- // SIDEBAR //
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 170, 1, 0),
        BackgroundColor3 = Titanium.Settings.Colors.Sidebar,
        BorderSizePixel = 0,
        -- Important for rounded corners on the left side
        ClipsDescendants = true,
        Parent = Main
    })
    
    -- Sidebar Divider
    Utility:Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Titanium.Settings.Colors.Divider,
        BorderSizePixel = 0,
        Parent = Sidebar
    })
    
    -- App Title
    local AppTitle = Utility:Create("TextLabel", {
        Text = Title,
        Font = Titanium.Settings.Font.Bold,
        TextColor3 = Titanium.Settings.Colors.Text,
        TextSize = 18,
        -- Adjusted size to prevent overlap and allow truncation
        Size = UDim2.new(1, -30, 0, 60),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        -- Truncate text if it's too long
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Sidebar
    })
    
    local TabContainer = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    
    local TabLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabContainer
    })

    -- // CONTENT AREA //
    local Content = Utility:Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 170, 0, 0),
        BackgroundTransparency = 1,
        -- Important for rounded corners on the right side
        ClipsDescendants = true,
        Parent = Main
    })
    
    -- // DRAGGING //
    local function MakeDraggable(dragPart)
        local dragging, dragInput, dragStart, startPos
        dragPart.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragPart.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        InputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                Main.Position = target
                MainShadow.Position = target
            end
        end)
    end
    MakeDraggable(Sidebar)
    MakeDraggable(AppTitle)

    -- // MOBILE TOGGLE //
    if IsMobile then
        local MobBtn = Utility:Create("ImageButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 45, 0, 45),
            -- Adjusted position for better mobile access
            Position = UDim2.new(0, 20, 0.2, 0),
            BackgroundColor3 = Titanium.Settings.Colors.Sidebar,
            Image = Icons.List,
            ImageColor3 = Titanium.Settings.Colors.Accent,
            Parent = GUI
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MobBtn})
        Utility:Create("UIStroke", {Color = Titanium.Settings.Colors.Stroke, Thickness = 1, Parent = MobBtn})
        Utility:AddShadow(MobBtn, 0.5)
        
        local open = true
        MobBtn.MouseButton1Click:Connect(function()
            open = not open
            Main.Visible = open
            MainShadow.Visible = open
        end)
    end

    -- // NOTIFICATION SYSTEM //
    local NotifyHolder = Utility:Create("Frame", {
        Size = UDim2.new(0, 280, 1, 0),
        -- Adjusted position for mobile
        Position = IsMobile and UDim2.new(1, -290, 0, 60) or UDim2.new(1, -290, 0, 20),
        BackgroundTransparency = 1,
        Parent = GUI
    })
    local NotifyLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = NotifyHolder
    })

    function Titanium:Notify(data)
        local NFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(1, 20, 0, 0),
            BackgroundColor3 = Titanium.Settings.Colors.Sidebar,
            BorderSizePixel = 0,
            Parent = NotifyHolder
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NFrame})
        Utility:Create("UIStroke", {Color = Titanium.Settings.Colors.Stroke, Thickness = 1, Parent = NFrame})
        Utility:AddShadow(NFrame, 0.4)
        
        local NTit = Utility:Create("TextLabel", {
            Text = data.Title or "Alert",
            Font = Titanium.Settings.Font.Bold,
            TextSize = 14,
            TextColor3 = Titanium.Settings.Colors.Text,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 12, 0, 10),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NFrame
        })
        
        local NDesc = Utility:Create("TextLabel", {
            Text = data.Content or "",
            Font = Titanium.Settings.Font.Medium,
            TextSize = 12,
            TextColor3 = Titanium.Settings.Colors.TextDim,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 12, 0, 30),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NFrame
        })
        
        TweenService:Create(NFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0,0,0,0)}):Play()
        
        task.delay(data.Duration or 3, function()
            local t = TweenService:Create(NFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1})
            t:Play()
            t.Completed:Wait()
            NFrame:Destroy()
        end)
    end

    -- // TABS LOGIC //
    local Tabs = {}
    local FirstTab = true
    
    local Functions = {}
    
    function Functions:Tab(Name, Icon)
        local TabFuncs = {}
        
        -- Tab Button
        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(0, 150, 0, 36),
            BackgroundColor3 = Titanium.Settings.Colors.Sidebar, -- start transparent-ish
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabContainer
        })
        local BtnCorner = Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        
        local TabIcon = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 12, 0.5, -9),
            BackgroundTransparency = 1,
            Image = Icon or Icons.Home,
            ImageColor3 = Titanium.Settings.Colors.TextDim,
            Parent = TabBtn
        })
        
        local TabText = Utility:Create("TextLabel", {
            Text = Name,
            Font = Titanium.Settings.Font.Medium,
            TextSize = 13,
            TextColor3 = Titanium.Settings.Colors.TextDim,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            -- Truncate text if too long
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TabBtn
        })
        
        -- Page
        local Page = Utility:Create("ScrollingFrame", {
            Size = UDim2.new(1, -24, 1, -24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Titanium.Settings.Colors.Accent,
            Visible = false,
            ClipsDescendants = false, -- Allow shadows from elements to show
            Parent = Content
        })
        local PageLayout = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Activation Logic
        local function Activate()
            for _, t in pairs(Tabs) do
                TweenService:Create(t.Text, TweenInfo.new(0.2), {TextColor3 = Titanium.Settings.Colors.TextDim}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Titanium.Settings.Colors.TextDim}):Play()
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                t.Page.Visible = false
            end
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {TextColor3 = Titanium.Settings.Colors.Text}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Titanium.Settings.Colors.Accent}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Titanium.Settings.Colors.Element}):Play()
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            FirstTab = false
            Activate()
        end
        
        table.insert(Tabs, {Btn = TabBtn, Text = TabText, Icon = TabIcon, Page = Page})

        -- // ELEMENTS // --
        
        function TabFuncs:Section(text)
            local Sec = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page
            })
            Utility:Create("TextLabel", {
                Text = string.upper(text),
                Font = Titanium.Settings.Font.Bold,
                TextSize = 11,
                TextColor3 = Titanium.Settings.Colors.TextDim,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 4, 0, 5),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Sec
            })
        end

        function TabFuncs:Button(text, callback)
            local BtnFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Titanium.Settings.Colors.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BtnFrame})
            
            local Label = Utility:Create("TextLabel", {
                Text = text,
                Font = Titanium.Settings.Font.Medium,
                TextSize = 13,
                TextColor3 = Titanium.Settings.Colors.Text,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = BtnFrame
            })
            
            local Trigger = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = BtnFrame
            })
            
            Trigger.MouseButton1Click:Connect(function()
                Utility:Ripple(BtnFrame)
                callback()
                -- Bounce Effect
                local t1 = TweenService:Create(BtnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 36)})
                t1:Play()
                t1.Completed:Wait()
                TweenService:Create(BtnFrame, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            end)
        end

        function TabFuncs:Toggle(text, default, callback)
            local toggled = default or false
            
            local TogFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Titanium.Settings.Colors.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TogFrame})
            
            local Label = Utility:Create("TextLabel", {
                Text = text,
                Font = Titanium.Settings.Font.Medium,
                TextSize = 13,
                TextColor3 = Titanium.Settings.Colors.Text,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TogFrame
            })
            
            local Switch = Utility:Create("Frame", {
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -56, 0.5, -12),
                BackgroundColor3 = toggled and Titanium.Settings.Colors.Green or Titanium.Settings.Colors.Stroke,
                Parent = TogFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
            
            local Knob = Utility:Create("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = Switch
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})
            
            local Trigger = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = TogFrame
            })
            
            Trigger.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                local TargetPos = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                local TargetCol = toggled and Titanium.Settings.Colors.Green or Titanium.Settings.Colors.Stroke
                
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetCol}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = TargetPos}):Play()
                
                callback(toggled)
            end)
        end
        
        function TabFuncs:Slider(text, min, max, default, callback)
            local value = default or min
            
            local SFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Titanium.Settings.Colors.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SFrame})
            
            local Label = Utility:Create("TextLabel", {
                Text = text,
                Font = Titanium.Settings.Font.Medium,
                TextSize = 13,
                TextColor3 = Titanium.Settings.Colors.Text,
                Size = UDim2.new(0.5, 0, 0, 30),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SFrame
            })
            
            local ValLabel = Utility:Create("TextLabel", {
                Text = tostring(value),
                Font = Titanium.Settings.Font.Bold,
                TextSize = 13,
                TextColor3 = Titanium.Settings.Colors.TextDim,
                Size = UDim2.new(0.5, -12, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SFrame
            })
            
            local BarBG = Utility:Create("Frame", {
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, 40),
                BackgroundColor3 = Titanium.Settings.Colors.Stroke,
                Parent = SFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBG})
            
            local Fill = Utility:Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Titanium.Settings.Colors.Accent,
                Parent = BarBG
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
            
            local Knob = Utility:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = Fill
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})
            
            local Trigger = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "",
                Parent = SFrame
            })
            
            local dragging = false
            local function Update(input)
                local percent = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percent)
                ValLabel.Text = tostring(value)
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                callback(value)
            end
            
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    Update(input)
                end
            end)
            
            InputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 14, 0, 14)}):Play()
                end
            end)
            
            InputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end
        
        return TabFuncs
    end

    return Functions
end

return Titanium
