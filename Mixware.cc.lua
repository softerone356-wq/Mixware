--// Mixware | @kulscript
--// Author: @anchest
--// Roblox Luau
--// Compact UI
--// Fly + Speed + Jump Boost + Fly Speed

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CLEANUP
--==================================================

pcall(function()
    local old = PlayerGui:FindFirstChild("Mixware")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- THEME
--==================================================

local BLACK = Color3.fromRGB(8, 8, 8)
local DARK = Color3.fromRGB(13, 13, 13)
local WHITE = Color3.fromRGB(235, 235, 235)
local GREY = Color3.fromRGB(145, 145, 145)

local RED = Color3.fromRGB(190, 35, 35)
local RED_HOVER = Color3.fromRGB(225, 45, 45)
local BORDER = Color3.fromRGB(38, 38, 38)

--==================================================
-- STATE
--==================================================

local FlyEnabled = false

local FlySpeed = 60
local SpeedValue = 16
local JumpBoostValue = 50

local Character
local Humanoid
local Root

local BodyVelocity
local BodyGyro

local Keys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Up = false,
    Down = false
}

--==================================================
-- CHARACTER
--==================================================

local function updateCharacter()
    Character = Player.Character

    if not Character then
        Humanoid = nil
        Root = nil
        return
    end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    Root = Character:FindFirstChild("HumanoidRootPart")
end

updateCharacter()

--==================================================
-- FLY PHYSICS
--==================================================

local function startFlyPhysics()
    if not Root then
        return
    end

    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "MixwareFlyVelocity"
    BodyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    BodyVelocity.P = 9000
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = Root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "MixwareFlyGyro"
    BodyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    BodyGyro.P = 9000
    BodyGyro.D = 500
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root
end

local function stopFlyPhysics()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    for key in pairs(Keys) do
        Keys[key] = false
    end
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Mixware"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"

Main.Size = UDim2.fromOffset(380, 350)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)

Main.BackgroundColor3 = BLACK
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = BORDER
MainStroke.Thickness = 1
MainStroke.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = DARK
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Accent = Instance.new("Frame")
Accent.Size = UDim2.fromOffset(3, 32)
Accent.BackgroundColor3 = RED
Accent.BorderSizePixel = 0
Accent.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(12, 0)
Title.Size = UDim2.new(1, -45, 1, 0)

Title.Font = Enum.Font.Code
Title.Text = "Mixware | @kulscript"
Title.TextColor3 = WHITE
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.BackgroundTransparency = 1
Close.Position = UDim2.new(1, -32, 0, 0)
Close.Size = UDim2.fromOffset(32, 32)

Close.Font = Enum.Font.Code
Close.Text = "×"
Close.TextColor3 = GREY
Close.TextSize = 18
Close.AutoButtonColor = false
Close.Parent = TopBar

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0, 32)
Sidebar.Size = UDim2.new(0, 95, 1, -32)

Sidebar.BackgroundColor3 = DARK
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLine = Instance.new("Frame")
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)

SidebarLine.BackgroundColor3 = BORDER
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(95, 32)
Content.Size = UDim2.new(1, -95, 1, -32)

Content.BackgroundColor3 = BLACK
Content.BorderSizePixel = 0
Content.Parent = Main

--==================================================
-- TABS
--==================================================

local function createTab(text, order)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, -12, 0, 27)
    Button.Position = UDim2.fromOffset(
        6,
        8 + ((order - 1) * 33)
    )

    Button.BackgroundColor3 = DARK
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false

    Button.Font = Enum.Font.Code
    Button.Text = text
    Button.TextColor3 = GREY
    Button.TextSize = 12
    Button.TextXAlignment = Enum.TextXAlignment.Left

    Button.Parent = Sidebar

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = BORDER
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Button

    return Button
end

local MainTab = createTab("Main", 1)
local SettingsTab = createTab("Settings", 2)

--==================================================
-- MAIN PAGE
--==================================================

local MainPage = Instance.new("Frame")
MainPage.BackgroundTransparency = 1
MainPage.Size = UDim2.fromScale(1, 1)
MainPage.Parent = Content

local MainTitle = Instance.new("TextLabel")
MainTitle.BackgroundTransparency = 1
MainTitle.Position = UDim2.fromOffset(15, 12)
MainTitle.Size = UDim2.new(1, -30, 0, 20)

MainTitle.Font = Enum.Font.Code
MainTitle.Text = "Main"
MainTitle.TextColor3 = WHITE
MainTitle.TextSize = 15
MainTitle.TextXAlignment = Enum.TextXAlignment.Left
MainTitle.Parent = MainPage

local Divider = Instance.new("Frame")
Divider.Position = UDim2.fromOffset(15, 39)
Divider.Size = UDim2.new(1, -30, 0, 1)

Divider.BackgroundColor3 = BORDER
Divider.BorderSizePixel = 0
Divider.Parent = MainPage

--==================================================
-- FLY BUTTON
--==================================================

local FlyButton = Instance.new("TextButton")

FlyButton.Position = UDim2.fromOffset(15, 51)
FlyButton.Size = UDim2.new(1, -30, 0, 34)

FlyButton.BackgroundColor3 = DARK
FlyButton.BorderSizePixel = 0
FlyButton.AutoButtonColor = false

FlyButton.Font = Enum.Font.Code
FlyButton.Text = "Fly                         OFF"
FlyButton.TextColor3 = GREY
FlyButton.TextSize = 12
FlyButton.TextXAlignment = Enum.TextXAlignment.Left

FlyButton.Parent = MainPage

local FlyPadding = Instance.new("UIPadding")
FlyPadding.PaddingLeft = UDim.new(0, 10)
FlyPadding.Parent = FlyButton

local FlyStroke = Instance.new("UIStroke")
FlyStroke.Color = BORDER
FlyStroke.Thickness = 1
FlyStroke.Parent = FlyButton

--==================================================
-- SLIDER CREATOR
--==================================================

local function createSlider(
    parent,
    name,
    position,
    initialValue,
    minValue,
    maxValue
)
    local Container = Instance.new("Frame")

    Container.Position = position
    Container.Size = UDim2.new(1, -30, 0, 58)

    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")

    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(0, 0)
    Label.Size = UDim2.new(1, -75, 0, 19)

    Label.Font = Enum.Font.Code
    Label.Text = name
    Label.TextColor3 = WHITE
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")

    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -75, 0, 0)
    ValueLabel.Size = UDim2.fromOffset(75, 19)

    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = RED
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")

    Track.Position = UDim2.fromOffset(0, 29)
    Track.Size = UDim2.new(1, 0, 0, 6)

    Track.BackgroundColor3 = BORDER
    Track.BorderSizePixel = 0

    Track.Parent = Container

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 3)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")

    Fill.BackgroundColor3 = RED
    Fill.BorderSizePixel = 0

    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")

    Knob.AnchorPoint = Vector2.new(0.5, 0.5)

    Knob.Size = UDim2.fromOffset(12, 12)

    Knob.BackgroundColor3 = WHITE
    Knob.BorderSizePixel = 0

    Knob.ZIndex = 3
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local Hitbox = Instance.new("TextButton")

    Hitbox.BackgroundTransparency = 1

    Hitbox.Position = UDim2.fromOffset(-8, -12)

    Hitbox.Size = UDim2.new(
        1,
        16,
        0,
        30
    )

    Hitbox.Text = ""
    Hitbox.AutoButtonColor = false
    Hitbox.ZIndex = 5
    Hitbox.Parent = Track

    local CurrentValue = initialValue
    local SliderDragging = false

    local function setValue(value)

        value = math.clamp(
            math.floor(value + 0.5),
            minValue,
            maxValue
        )

        CurrentValue = value

        local alpha =
            (value - minValue) /
            (maxValue - minValue)

        Fill.Size =
            UDim2.new(
                alpha,
                0,
                1,
                0
            )

        Knob.Position =
            UDim2.new(
                alpha,
                0,
                0.5,
                0
            )

        ValueLabel.Text =
            tostring(value)
    end

    local function updateFromInput(position)

        local absolutePosition =
            Track.AbsolutePosition

        local absoluteSize =
            Track.AbsoluteSize

        if absoluteSize.X <= 0 then
            return
        end

        local alpha = math.clamp(
            (
                position.X -
                absolutePosition.X
            ) / absoluteSize.X,
            0,
            1
        )

        local value =
            minValue +
            (
                (maxValue - minValue)
                * alpha
            )

        setValue(value)
    end

    Hitbox.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            SliderDragging = true

            updateFromInput(
                input.Position
            )
        end
    end)

    Hitbox.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            SliderDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not SliderDragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or
            input.UserInputType ==
            Enum.UserInputType.Touch
        then

            updateFromInput(
                input.Position
            )
        end
    end)

    setValue(initialValue)

    return {
        GetValue = function()
            return CurrentValue
        end,

        SetValue = setValue
    }
end

--==================================================
-- SLIDERS
--==================================================

local SpeedSlider = createSlider(
    MainPage,
    "Speed",
    UDim2.fromOffset(15, 94),
    SpeedValue,
    1,
    100000
)

local JumpSlider = createSlider(
    MainPage,
    "Jump Boost",
    UDim2.fromOffset(15, 152),
    JumpBoostValue,
    1,
    100000
)

local FlySpeedSlider = createSlider(
    MainPage,
    "Fly Speed",
    UDim2.fromOffset(15, 210),
    FlySpeed,
    1,
    100000
)

--==================================================
-- MOBILE FLY CONTROLS
--==================================================

local MobileControls = Instance.new("Frame")

MobileControls.Name = "MobileControls"

MobileControls.Size =
    UDim2.fromOffset(210, 155)

MobileControls.Position =
    UDim2.new(
        1,
        -225,
        1,
        -170
    )

MobileControls.BackgroundTransparency = 1

MobileControls.Visible =
    false

MobileControls.ZIndex = 20

MobileControls.Parent =
    ScreenGui

local function createMobileButton(
    name,
    text,
    position
)

    local Button =
        Instance.new("TextButton")

    Button.Name = name

    Button.Size =
        UDim2.fromOffset(58, 42)

    Button.Position = position

    Button.BackgroundColor3 =
        DARK

    Button.BackgroundTransparency =
        0.08

    Button.BorderSizePixel = 0

    Button.AutoButtonColor =
        false

    Button.Font =
        Enum.Font.Code

    Button.Text = text

    Button.TextColor3 =
        WHITE

    Button.TextSize = 14

    Button.ZIndex = 21

    Button.Parent =
        MobileControls

    local Stroke =
        Instance.new("UIStroke")

    Stroke.Color =
        RED

    Stroke.Thickness = 1

    Stroke.Parent =
        Button

    return Button
end

local UpButton =
    createMobileButton(
        "Up",
        "UP",
        UDim2.fromOffset(76, 0)
    )

local DownButton =
    createMobileButton(
        "Down",
        "DOWN",
        UDim2.fromOffset(76, 50)
    )

local WButton =
    createMobileButton(
        "Forward",
        "W",
        UDim2.fromOffset(76, 100)
    )

local AButton =
    createMobileButton(
        "Left",
        "A",
        UDim2.fromOffset(12, 100)
    )

local SButton =
    createMobileButton(
        "Back",
        "S",
        UDim2.fromOffset(140, 100)
    )

local function bindMobileButton(
    button,
    key
)

    button.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or
            input.UserInputType ==
            Enum.UserInputType.MouseButton1
        then

            Keys[key] = true

            button.TextColor3 =
                RED_HOVER
        end
    end)

    button.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or
            input.UserInputType ==
            Enum.UserInputType.MouseButton1
        then

            Keys[key] = false

            button.TextColor3 =
                WHITE
        end
    end)
end

bindMobileButton(
    UpButton,
    "Up"
)

bindMobileButton(
    DownButton,
    "Down"
)

bindMobileButton(
    WButton,
    "W"
)

bindMobileButton(
    AButton,
    "A"
)

bindMobileButton(
    SButton,
    "S"
)

--==================================================
-- KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(function(
    input,
    processed
)

    if processed then
        return
    end

    if input.KeyCode ==
        Enum.KeyCode.W
    then
        Keys.W = true

    elseif input.KeyCode ==
        Enum.KeyCode.A
    then
        Keys.A = true

    elseif input.KeyCode ==
        Enum.KeyCode.S
    then
        Keys.S = true

    elseif input.KeyCode ==
        Enum.KeyCode.D
    then
        Keys.D = true

    elseif input.KeyCode ==
        Enum.KeyCode.Space
    then
        Keys.Up = true

    elseif input.KeyCode ==
        Enum.KeyCode.LeftControl
    then
        Keys.Down = true
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.KeyCode ==
        Enum.KeyCode.W
    then
        Keys.W = false

    elseif input.KeyCode ==
        Enum.KeyCode.A
    then
        Keys.A = false

    elseif input.KeyCode ==
        Enum.KeyCode.S
    then
        Keys.S = false

    elseif input.KeyCode ==
        Enum.KeyCode.D
    then
        Keys.D = false

    elseif input.KeyCode ==
        Enum.KeyCode.Space
    then
        Keys.Up = false

    elseif input.KeyCode ==
        Enum.KeyCode.LeftControl
    then
        Keys.Down = false
    end
end)

--==================================================
-- FLY
--==================================================

local function enableFly()

    updateCharacter()

    if not Root then
        return
    end

    FlyEnabled = true

    startFlyPhysics()

    if Humanoid then
        Humanoid.AutoRotate = false
    end

    MobileControls.Visible =
        UserInputService.TouchEnabled

    FlyButton.Text =
        "Fly                         ON"

    FlyButton.TextColor3 =
        RED
end

local function disableFly()

    FlyEnabled = false

    stopFlyPhysics()

    if Humanoid then
        Humanoid.AutoRotate = true
    end

    MobileControls.Visible =
        false

    FlyButton.Text =
        "Fly                         OFF"

    FlyButton.TextColor3 =
        GREY
end

FlyButton.MouseButton1Click:Connect(function()

    if FlyEnabled then
        disableFly()
    else
        enableFly()
    end
end)

--==================================================
-- FLY UPDATE
--==================================================

RunService.RenderStepped:Connect(function()

    if not FlyEnabled then
        return
    end

    if not Root
        or not BodyVelocity
        or not BodyGyro
    then

        updateCharacter()

        if Root then
            startFlyPhysics()
        end

        return
    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    FlySpeed =
        FlySpeedSlider:GetValue()

    local direction =
        Vector3.zero

    local forward =
        Camera.CFrame.LookVector

    local right =
        Camera.CFrame.RightVector

    if Keys.W then
        direction += forward
    end

    if Keys.S then
        direction -= forward
    end

    if Keys.D then
        direction += right
    end

    if Keys.A then
        direction -= right
    end

    if Keys.Up then
        direction +=
            Vector3.new(0, 1, 0)
    end

    if Keys.Down then
        direction -=
            Vector3.new(0, 1, 0)
    end

    if direction.Magnitude > 0 then

        direction =
            direction.Unit

        BodyVelocity.Velocity =
            direction * FlySpeed

    else

        BodyVelocity.Velocity =
            Vector3.zero
    end

    local look =
        Vector3.new(
            forward.X,
            0,
            forward.Z
        )

    if look.Magnitude > 0 then

        BodyGyro.CFrame =
            CFrame.lookAt(
                Root.Position,
                Root.Position + look.Unit
            )
    end
end)

--==================================================
-- MOVEMENT UPDATE
--==================================================

RunService.Heartbeat:Connect(function()

    if not Humanoid then
        updateCharacter()
        return
    end

    SpeedValue =
        SpeedSlider:GetValue()

    JumpBoostValue =
        JumpSlider:GetValue()

    Humanoid.WalkSpeed =
        SpeedValue

    pcall(function()

        Humanoid.UseJumpPower =
            true

        Humanoid.JumpPower =
            JumpBoostValue
    end)
end)

--==================================================
-- RESPAWN
--==================================================

Player.CharacterAdded:Connect(function(character)

    Character = character

    Humanoid =
        character:WaitForChild(
            "Humanoid",
            5
        )

    Root =
        character:WaitForChild(
            "HumanoidRootPart",
            5
        )

    task.wait(0.25)

    if Humanoid then

        Humanoid.WalkSpeed =
            SpeedSlider:GetValue()

        pcall(function()

            Humanoid.UseJumpPower =
                true

            Humanoid.JumpPower =
                JumpSlider:GetValue()
        end)
    end

    if FlyEnabled and Root then

        startFlyPhysics()

        if Humanoid then
            Humanoid.AutoRotate =
                false
        end
    end
end)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsPage = Instance.new("Frame")

SettingsPage.BackgroundTransparency = 1
SettingsPage.Size = UDim2.fromScale(1, 1)

SettingsPage.Visible = false

SettingsPage.Parent = Content

local SettingsTitle = Instance.new("TextLabel")

SettingsTitle.BackgroundTransparency = 1

SettingsTitle.Position =
    UDim2.fromOffset(15, 12)

SettingsTitle.Size =
    UDim2.new(
        1,
        -30,
        0,
        20
    )

SettingsTitle.Font =
    Enum.Font.Code

SettingsTitle.Text =
    "Settings"

SettingsTitle.TextColor3 =
    WHITE

SettingsTitle.TextSize = 15

SettingsTitle.TextXAlignment =
    Enum.TextXAlignment.Left

SettingsTitle.Parent =
    SettingsPage

local SettingsDivider =
    Instance.new("Frame")

SettingsDivider.Position =
    UDim2.fromOffset(15, 39)

SettingsDivider.Size =
    UDim2.new(
        1,
        -30,
        0,
        1
    )

SettingsDivider.BackgroundColor3 =
    BORDER

SettingsDivider.BorderSizePixel =
    0

SettingsDivider.Parent =
    SettingsPage

local InfoBox =
    Instance.new("Frame")

InfoBox.Position =
    UDim2.fromOffset(15, 54)

InfoBox.Size =
    UDim2.new(
        1,
        -30,
        0,
        90
    )

InfoBox.BackgroundColor3 =
    DARK

InfoBox.BorderSizePixel =
    0

InfoBox.Parent =
    SettingsPage

local InfoStroke =
    Instance.new("UIStroke")

InfoStroke.Color =
    BORDER

InfoStroke.Thickness = 1

InfoStroke.Parent =
    InfoBox

local InfoTitle =
    Instance.new("TextLabel")

InfoTitle.BackgroundTransparency = 1

InfoTitle.Position =
    UDim2.fromOffset(10, 8)

InfoTitle.Size =
    UDim2.new(
        1,
        -20,
        0,
        20
    )

InfoTitle.Font =
    Enum.Font.Code

InfoTitle.Text =
    "Mixware | @kulscript"

InfoTitle.TextColor3 =
    WHITE

InfoTitle.TextSize = 13

InfoTitle.TextXAlignment =
    Enum.TextXAlignment.Left

InfoTitle.Parent =
    InfoBox

local Author =
    Instance.new("TextLabel")

Author.BackgroundTransparency = 1

Author.Position =
    UDim2.fromOffset(10, 34)

Author.Size =
    UDim2.new(
        1,
        -20,
        0,
        18
    )

Author.Font =
    Enum.Font.Code

Author.Text =
    "Author: @anchest"

Author.TextColor3 =
    RED

Author.TextSize = 11

Author.TextXAlignment =
    Enum.TextXAlignment.Left

Author.Parent =
    InfoBox

local Version =
    Instance.new("TextLabel")

Version.BackgroundTransparency = 1

Version.Position =
    UDim2.fromOffset(10, 58)

Version.Size =
    UDim2.new(
        1,
        -20,
        0,
        16
    )

Version.Font =
    Enum.Font.Code

Version.Text =
    "Version: 0.5"

Version.TextColor3 =
    GREY

Version.TextSize = 10

Version.TextXAlignment =
    Enum.TextXAlignment.Left

Version.Parent =
    InfoBox

--==================================================
-- TAB SWITCH
--==================================================

local function selectTab(tab)

    MainPage.Visible = false
    SettingsPage.Visible = false

    MainTab.TextColor3 =
        GREY

    SettingsTab.TextColor3 =
        GREY

    if tab == "Main" then

        MainPage.Visible = true
        MainTab.TextColor3 = RED

    elseif tab == "Settings" then

        SettingsPage.Visible = true
        SettingsTab.TextColor3 = RED
    end
end

MainTab.MouseButton1Click:Connect(function()
    selectTab("Main")
end)

SettingsTab.MouseButton1Click:Connect(function()
    selectTab("Settings")
end)

selectTab("Main")

--==================================================
-- DRAG
--==================================================

local draggingWindow = false
local dragStart
local dragStartPosition

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        draggingWindow = true

        dragStart =
            input.Position

        dragStartPosition =
            Main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End
            then

                draggingWindow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not draggingWindow then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        local delta =
            input.Position -
            dragStart

        Main.Position =
            UDim2.new(
                dragStartPosition.X.Scale,
                dragStartPosition.X.Offset + delta.X,

                dragStartPosition.Y.Scale,
                dragStartPosition.Y.Offset + delta.Y
            )
    end
end)

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton =
    Instance.new("TextButton")

OpenButton.Name =
    "OpenButton"

OpenButton.AnchorPoint =
    Vector2.new(0.5, 0)

OpenButton.Size =
    UDim2.fromOffset(155, 25)

OpenButton.Position =
    UDim2.new(
        0.5,
        0,
        0,
        10
    )

OpenButton.BackgroundColor3 =
    DARK

OpenButton.BorderSizePixel =
    0

OpenButton.Visible = false

OpenButton.AutoButtonColor =
    false

OpenButton.Font =
    Enum.Font.Code

OpenButton.Text =
    "Mixware | @kulscript"

OpenButton.TextColor3 =
    WHITE

OpenButton.TextSize = 10

OpenButton.ZIndex = 50

OpenButton.Parent =
    ScreenGui

local OpenStroke =
    Instance.new("UIStroke")

OpenStroke.Color =
    RED

OpenStroke.Thickness = 1

OpenStroke.Parent =
    OpenButton

OpenButton.MouseEnter:Connect(function()

    OpenButton.TextColor3 =
        RED_HOVER
end)

OpenButton.MouseLeave:Connect(function()

    OpenButton.TextColor3 =
        WHITE
end)

OpenButton.MouseButton1Click:Connect(function()

    Main.Visible = true
    OpenButton.Visible = false
end)

--==================================================
-- CLOSE
--==================================================

Close.MouseEnter:Connect(function()

    Close.TextColor3 =
        RED_HOVER
end)

Close.MouseLeave:Connect(function()

    Close.TextColor3 =
        GREY
end)

Close.MouseButton1Click:Connect(function()

    Main.Visible = false
    OpenButton.Visible = true
end)

--==================================================
-- HOTKEY
--==================================================

UserInputService.InputBegan:Connect(function(
    input,
    processed
)

    if processed then
        return
    end

    if input.KeyCode ==
        Enum.KeyCode.RightShift
    then

        Main.Visible =
            not Main.Visible

        OpenButton.Visible =
            not Main.Visible

    elseif input.KeyCode ==
        Enum.KeyCode.Escape
    then

        Main.Visible = false
        OpenButton.Visible = true
    end
end)

--==================================================
-- STARTUP
--==================================================

task.defer(function()

    updateCharacter()

    if Humanoid then

        Humanoid.WalkSpeed =
            SpeedSlider:GetValue()

        pcall(function()

            Humanoid.UseJumpPower =
                true

            Humanoid.JumpPower =
                JumpSlider:GetValue()
        end)
    end

    Main.Visible = true
    OpenButton.Visible = false

    print(
        "[Mixware] Loaded | Fly + Speed + Jump Boost + Fly Speed"
    )
end)