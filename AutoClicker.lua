-- ============================================
-- PRO AUTO CLICKER v5.0 - ROBLOX
-- Полностью рабочий с множеством методов клика
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local settings = {
    interval = 50,
    randomOffset = 20,
    clickButton = "Left",
    clickType = "Single",
    repeatMode = "UntilStopped",
    repeatCount = 10,
    cursorMode = "Current",
    customX = 0,
    customY = 0,
    holdDuration = 100,
    clickMethod = "Auto"
}

local isRunning = false
local clickCount = 0
local totalClicks = 0
local isMinimized = false
local clickTimer = nil
local isHolding = false
local lastClickTime = 0

-- ============================================
-- РАБОЧИЙ МЕТОД КЛИКА (МНОЖЕСТВО СПОСОБОВ)
-- ============================================
local function clickMouse(x, y, button)
    -- Способ 1: mouseclick (Synapse X, Krnl, Script-Ware)
    if mouseclick then
        if button == "Left" then
            mouseclick(x, y)
        elseif button == "Right" then
            mouseclick(x, y, 2)
        elseif button == "Middle" then
            mouseclick(x, y, 3)
        end
        return true
    end
    
    -- Способ 2: VirtualInputManager
    local success, err = pcall(function()
        local btn = Enum.UserInputType.MouseButton1
        if button == "Right" then
            btn = Enum.UserInputType.MouseButton2
        elseif button == "Middle" then
            btn = Enum.UserInputType.MouseButton3
        end
        
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, btn, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, btn, 0)
    end)
    if success then return true end
    
    -- Способ 3: mousemove + mouseclick
    if mousemove and mouseclick then
        mousemove(x, y)
        task.wait(0.02)
        if button == "Left" then
            mouseclick(1)
        elseif button == "Right" then
            mouseclick(2)
        elseif button == "Middle" then
            mouseclick(3)
        end
        return true
    end
    
    -- Способ 4: Через InputService (эмуляция)
    success, err = pcall(function()
        local btn = Enum.UserInputType.MouseButton1
        if button == "Right" then
            btn = Enum.UserInputType.MouseButton2
        elseif button == "Middle" then
            btn = Enum.UserInputType.MouseButton3
        end
        
        local inputDown = Instance.new("InputObject")
        inputDown.Type = Enum.InputType.MouseButton1
        inputDown.UserInputType = btn
        inputDown.Position = Vector2.new(x, y)
        inputDown.Delta = Vector2.new(0, 0)
        
        UserInputService:SendInputObject(inputDown)
        task.wait(0.02)
        
        local inputUp = Instance.new("InputObject")
        inputUp.Type = Enum.InputType.MouseButton1
        inputUp.UserInputType = btn
        inputUp.Position = Vector2.new(x, y)
        inputUp.Delta = Vector2.new(0, 0)
        
        UserInputService:SendInputObject(inputUp)
    end)
    if success then return true end
    
    return false
end

-- ============================================
-- ФУНКЦИЯ КЛИКА С ЗАДЕРЖКОЙ
-- ============================================
local function performClick()
    local x, y
    if settings.cursorMode == "Pick" then
        x = settings.customX
        y = settings.customY
    else
        x = mouse.X
        y = mouse.Y
    end
    
    local button = settings.clickButton
    local success = clickMouse(x, y, button)
    
    if not success then
        warn("⚠️ Не удалось выполнить клик! Используйте другой экзекьютор.")
        return false
    end
    
    if settings.clickType == "Double" then
        task.wait(0.06)
        clickMouse(x, y, button)
    end
    
    if settings.clickType == "Hold" then
        if not isHolding then
            isHolding = true
            clickMouse(x, y, button)
            task.wait(settings.holdDuration / 1000)
            clickMouse(x, y, button)
            isHolding = false
        end
    end
    
    totalClicks = totalClicks + 1
    clickCount = clickCount + 1
    updateCounter(totalClicks)
    return true
end

-- ============================================
-- ОСНОВНОЙ ЦИКЛ КЛИКЕРА
-- ============================================
local function clickLoop()
    if not isRunning then return end
    
    local delay = settings.interval / 1000
    local offset = (math.random() * settings.randomOffset * 2 - settings.randomOffset) / 1000
    delay = math.max(0.001, delay + offset)
    
    local success = performClick()
    
    if settings.repeatMode == "Count" and clickCount >= settings.repeatCount then
        stopClicker()
        return
    end
    
    if success then
        clickTimer = task.wait(delay)
        if isRunning then
            clickLoop()
        end
    else
        clickTimer = task.wait(0.5)
        if isRunning then
            clickLoop()
        end
    end
end

-- ============================================
-- УПРАВЛЕНИЕ КЛИКЕРОМ
-- ============================================
function startClicker()
    if isRunning then return end
    isRunning = true
    clickCount = 0
    updateStatus(true)
    print("⚡ Автокликер ЗАПУЩЕН!")
    clickLoop()
end

function stopClicker()
    isRunning = false
    if clickTimer then
        task.cancel(clickTimer)
        clickTimer = nil
    end
    isHolding = false
    updateStatus(false)
    print("⏹ Автокликер ОСТАНОВЛЕН! Всего кликов: " .. totalClicks)
end

-- ============================================
-- СОЗДАНИЕ GUI (БОЛЬШОЙ И КРАСИВЫЙ)
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "ProClickerGUI"

-- ОСНОВНОЕ ОКНО
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 480, 0, 600)
frame.Position = UDim2.new(0.5, -240, 0.5, -300)
frame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.Parent = frame
mainCorner.CornerRadius = UDim.new(0, 16)

-- ТЕНЬ
local shadow = Instance.new("Frame")
shadow.Parent = screenGui
shadow.Size = UDim2.new(0, 480, 0, 600)
shadow.Position = UDim2.new(0.5, -240, 0.5, -300)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel = 0
shadow.ZIndex = 0

local shadowCorner = Instance.new("UICorner")
shadowCorner.Parent = shadow
shadowCorner.CornerRadius = UDim.new(0, 16)

-- ЗАГОЛОВОК С ГРАДИЕНТОМ
local header = Instance.new("Frame")
header.Parent = frame
header.Size = UDim2.new(1, 0, 0, 55)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
header.BorderSizePixel = 0
header.ZIndex = 2

local headerCorner = Instance.new("UICorner")
headerCorner.Parent = header
headerCorner.CornerRadius = UDim.new(0, 16)

-- Логотип
local logo = Instance.new("TextLabel")
logo.Parent = header
logo.Size = UDim2.new(0, 40, 1, 0)
logo.Position = UDim2.new(0, 10, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "⚡"
logo.TextColor3 = Color3.fromRGB(255, 200, 50)
logo.TextSize = 28
logo.Font = Enum.Font.GothamBold

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1, -160, 1, 0)
title.Position = UDim2.new(0, 55, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PRO AUTO CLICKER v5.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2

-- Подзаголовок
local subtitle = Instance.new("TextLabel")
subtitle.Parent = header
subtitle.Size = UDim2.new(1, -160, 1, 0)
subtitle.Position = UDim2.new(0, 55, 0, 25)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by Gothbreach"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 2

-- Кнопка свернуть
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = header
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -85, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
minimizeBtn.BackgroundTransparency = 0.5
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 2

local minCorner = Instance.new("UICorner")
minCorner.Parent = minimizeBtn
minCorner.CornerRadius = UDim.new(1, 0)

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minimizeBtn.Text = "+"
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 55)}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 55)}):Play()
        content.Visible = false
    else
        minimizeBtn.Text = "−"
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 600)}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 600)}):Play()
        content.Visible = true
    end
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 2

local closeCorner = Instance.new("UICorner")
closeCorner.Parent = closeBtn
closeCorner.CornerRadius = UDim.new(1, 0)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    if isRunning then stopClicker() end
    screenGui:Destroy()
end)

-- КОНТЕЙНЕР СОДЕРЖИМОГО
local content = Instance.new("ScrollingFrame")
content.Parent = frame
content.Size = UDim2.new(1, -30, 1, -70)
content.Position = UDim2.new(0, 15, 0, 60)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 0, 750)
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 100)
content.Visible = true

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ GUI
-- ============================================
local function createSection(titleText, yPos)
    local line = Instance.new("Frame")
    line.Parent = content
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, yPos)
    line.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    line.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel")
    label.Parent = content
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(0, 0, 0, yPos + 5)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(150, 200, 255)
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    return yPos + 35
end

local function createLabel(text, x, y, w, h, color)
    color = color or Color3.fromRGB(180, 180, 210)
    local label = Instance.new("TextLabel")
    label.Parent = content
    label.Size = UDim2.new(0, w, 0, h)
    label.Position = UDim2.new(0, x, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createTextBox(default, x, y, w, h, callback)
    local box = Instance.new("TextBox")
    box.Parent = content
    box.Size = UDim2.new(0, w, 0, h)
    box.Position = UDim2.new(0, x, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = tostring(default)
    box.TextSize = 14
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.PlaceholderText = "0"
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.Parent = box
    boxCorner.CornerRadius = UDim.new(0, 6)
    
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            callback(val)
        else
            box.Text = tostring(default)
        end
    end)
    return box
end

local function createDropdown(options, default, x, y, w, h, callback)
    local dropdown = Instance.new("TextButton")
    dropdown.Parent = content
    dropdown.Size = UDim2.new(0, w, 0, h)
    dropdown.Position = UDim2.new(0, x, 0, y)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Text = default
    dropdown.TextSize = 14
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.BorderSizePixel = 0
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.Parent = dropdown
    dropCorner.CornerRadius = UDim.new(0, 6)
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = dropdown
    arrow.Size = UDim2.new(0, 25, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamMedium
    
    local isOpen = false
    local listFrame = nil
    
    dropdown.MouseButton1Click:Connect(function()
        if isOpen then
            if listFrame then listFrame:Destroy() end
            isOpen = false
            return
        end
        
        listFrame = Instance.new("Frame")
        listFrame.Parent = content
        listFrame.Size = UDim2.new(0, w, 0, #options * 28)
        listFrame.Position = UDim2.new(0, x, 0, y + h + 3)
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 50)
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 10
        
        local listCorner = Instance.new("UICorner")
        listCorner.Parent = listFrame
        listCorner.CornerRadius = UDim.new(0, 6)
        
        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Parent = listFrame
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*28)
            btn.BackgroundColor3 = Color3.fromRGB(35, 37, 55)
            btn.TextColor3 = Color3.fromRGB(220, 220, 255)
            btn.Text = opt
            btn.TextSize = 13
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.ZIndex = 11
            
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(55, 57, 85)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(35, 37, 55)
            end)
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Text = opt
                callback(opt)
                listFrame:Destroy()
                isOpen = false
            end)
        end
        isOpen = true
    end)
    return dropdown
end

local function createRadioButton(text, x, y, group, default, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = content
    btn.Size = UDim2.new(0, 140, 0, 25)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 230)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local check = Instance.new("Frame")
    check.Parent = btn
    check.Size = UDim2.new(0, 18, 0, 18)
    check.Position = UDim2.new(1, -25, 0, 3)
    check.BackgroundColor3 = Color3.fromRGB(40, 42, 60)
    check.BorderSizePixel = 0
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.Parent = check
    checkCorner.CornerRadius = UDim.new(1, 0)
    
    local checkMark = Instance.new("TextLabel")
    checkMark.Parent = check
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = default and "✓" or ""
    checkMark.TextColor3 = Color3.fromRGB(100, 200, 255)
    checkMark.TextSize = 14
    checkMark.Font = Enum.Font.GothamBold
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(content:GetChildren()) do
            if v:IsA("TextButton") and v.Name == "Radio_"..group then
                local c = v:FindFirstChildWhichIsA("Frame")
                if c then
                    local m = c:FindFirstChildWhichIsA("TextLabel")
                    if m then m.Text = "" end
                end
            end
        end
        checkMark.Text = "✓"
        callback(true)
    end)
    btn.Name = "Radio_"..group
    return btn
end

-- ============================================
-- ПОСТРОЕНИЕ GUI
-- ============================================
local yOffset = 0

-- === СЕКЦИЯ 1: ИНТЕРВАЛ ===
yOffset = createSection("⚙️ CLICK INTERVAL", yOffset)

createLabel("Interval (ms):", 0, yOffset, 100, 25)
local intervalBox = createTextBox(settings.interval, 110, yOffset, 60, 25, function(v)
    settings.interval = v
end)

createLabel("Random offset (ms):", 190, yOffset, 130, 25)
local randomBox = createTextBox(settings.randomOffset, 330, yOffset, 60, 25, function(v)
    settings.randomOffset = v
end)

yOffset = yOffset + 40

-- === СЕКЦИЯ 2: НАСТРОЙКИ КЛИКА ===
yOffset = createSection("🖱️ CLICK OPTIONS", yOffset)

createLabel("Mouse button:", 0, yOffset, 100, 25)
local buttonDropdown = createDropdown({"Left", "Right", "Middle"}, settings.clickButton, 110, yOffset, 95, 25, function(v)
    settings.clickButton = v
end)

createLabel("Click type:", 220, yOffset, 80, 25)
local typeDropdown = createDropdown({"Single", "Double", "Hold"}, settings.clickType, 310, yOffset, 100, 25, function(v)
    settings.clickType = v
end)

yOffset = yOffset + 40

-- Hold duration
createLabel("Hold duration (ms):", 0, yOffset, 130, 25)
local holdBox = createTextBox(settings.holdDuration, 140, yOffset, 60, 25, function(v)
    settings.holdDuration = v
end)

yOffset = yOffset + 45

-- === СЕКЦИЯ 3: ПОВТОР ===
yOffset = createSection("🔄 REPEAT MODE", yOffset)

local repeatUntil = createRadioButton("Repeat until stopped", 0, yOffset, "repeat", true, function(v)
    settings.repeatMode = "UntilStopped"
end)

local repeatCountRadio = createRadioButton("Repeat count:", 180, yOffset, "repeat", false, function(v)
    settings.repeatMode = "Count"
end)

local countBox = createTextBox(settings.repeatCount, 280, yOffset, 60, 25, function(v)
    settings.repeatCount = v
end)

createLabel("times", 345, yOffset, 50, 25)

yOffset = yOffset + 45

-- === СЕКЦИЯ 4: ПОЗИЦИЯ КУРСОРА ===
yOffset = createSection("📍 CURSOR POSITION", yOffset)

local currentPos = createRadioButton("Current location", 0, yOffset, "cursor", true, function(v)
    settings.cursorMode = "Current"
end)

local pickPos = createRadioButton("Pick location", 180, yOffset, "cursor", false, function(v)
    settings.cursorMode = "Pick"
end)

yOffset = yOffset + 35

createLabel("X:", 0, yOffset, 20, 25)
local xBox = createTextBox(settings.customX, 25, yOffset, 60, 25, function(v)
    settings.customX = v
end)

createLabel("Y:", 100, yOffset, 20, 25)
local yBox = createTextBox(settings.customY, 125, yOffset, 60, 25, function(v)
    settings.customY = v
end)

-- Кнопка Pick current
local pickBtn = Instance.new("TextButton")
pickBtn.Parent = content
pickBtn.Size = UDim2.new(0, 140, 0, 30)
pickBtn.Position = UDim2.new(0, 210, 0, yOffset)
pickBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 180)
pickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pickBtn.Text = "📌 Pick Current"
pickBtn.TextSize = 13
pickBtn.Font = Enum.Font.GothamBold
pickBtn.BorderSizePixel = 0

local pickCorner = Instance.new("UICorner")
pickCorner.Parent = pickBtn
pickCorner.CornerRadius = UDim.new(0, 6)

pickBtn.MouseEnter:Connect(function()
    TweenService:Create(pickBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 90, 210)}):Play()
end)

pickBtn.MouseLeave:Connect(function()
    TweenService:Create(pickBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 70, 180)}):Play()
end)

pickBtn.MouseButton1Click:Connect(function()
    settings.customX = mouse.X
    settings.customY = mouse.Y
    xBox.Text = tostring(mouse.X)
    yBox.Text = tostring(mouse.Y)
    settings.cursorMode = "Pick"
    for _, v in pairs(content:GetChildren()) do
        if v:IsA("TextButton") and v.Name == "Radio_cursor" then
            local c = v:FindFirstChildWhichIsA("Frame")
            if c then
                local m = c:FindFirstChildWhichIsA("TextLabel")
                if m then m.Text = "" end
            end
        end
    end
    local c = pickPos:FindFirstChildWhichIsA("Frame")
    if c then
        local m = c:FindFirstChildWhichIsA("TextLabel")
        if m then m.Text = "✓" end
    end
end)

yOffset = yOffset + 45

-- === СЕКЦИЯ 5: УПРАВЛЕНИЕ ===
yOffset = createSection("🎮 CONTROLS", yOffset)

-- Кнопки управления (большие)
local function createBigButton(text, x, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = content
    btn.Size = UDim2.new(0, 130, 0, 40)
    btn.Position = UDim2.new(0, x, 0, yOffset)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color + Color3.fromRGB(25, 25, 25)}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 135, 0, 43)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 130, 0, 40)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local startBtn = createBigButton("▶ START (F6)", 0, Color3.fromRGB(0, 200, 80), function()
    startClicker()
end)

local stopBtn = createBigButton("⏹ STOP (F6)", 145, Color3.fromRGB(220, 50, 50), function()
    stopClicker()
end)

local resetBtn = createBigButton("🔄 RESET", 290, Color3.fromRGB(200, 160, 0), function()
    totalClicks = 0
    clickCount = 0
    updateCounter(0)
    print("🔄 Счетчик кликов сброшен!")
end)

yOffset = yOffset + 55

-- === СТАТУС И ИНФОРМАЦИЯ ===
yOffset = createSection("📊 STATUS", yOffset)

-- Статус
local statusText = createLabel("● STOPPED", 0, yOffset, 200, 30, Color3.fromRGB(255, 100, 100))
statusText.TextSize = 16
statusText.Font = Enum.Font.GothamBold

-- Счетчик
local clickCounter = createLabel("Total clicks: 0", 220, yOffset, 200, 30, Color3.fromRGB(200, 200, 150))
clickCounter.TextSize = 16
clickCounter.Font = Enum.Font.GothamBold

yOffset = yOffset + 40

-- Hotkey info
local hotkeyLabel = createLabel("⌨️ Hotkey: F6 - Start/Stop", 0, yOffset, 300, 25, Color3.fromRGB(150, 200, 150))

yOffset = yOffset + 35

-- Версия
local versionLabel = createLabel("📌 Version 5.0 | Made by Gothbreach", 0, yOffset, 350, 20, Color3.fromRGB(100, 100, 150))

-- ============================================
-- ФУНКЦИИ ОБНОВЛЕНИЯ
-- ============================================
local function updateStatus(running)
    if running then
        statusText.Text = "● RUNNING"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        startBtn.Text = "▶ RUNNING..."
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
    else
        statusText.Text = "● STOPPED"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        startBtn.Text = "▶ START (F6)"
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    end
end

local function updateCounter(count)
    clickCounter.Text = "Total clicks: " .. count
end

-- ============================================
-- ОБНОВЛЕНИЕ CANVAS
-- ============================================
content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 50)

-- ============================================
-- ПЕРЕМЕЩЕНИЕ ОКНА
-- ============================================
local dragging = false
local dragStartPos = nil
local dragStartMouse = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = frame.Position
        dragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartMouse
        frame.Position = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
        shadow.Position = frame.Position
    end
end)

frame:GetPropertyChangedSignal("Position"):Connect(function()
    shadow.Position = frame.Position
end)

-- ============================================
-- ГОРЯЧИЕ КЛАВИШИ
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        if isRunning then
            stopClicker()
        else
            startClicker()
        end
    end
end)

-- ============================================
-- ЗАПУСК
-- ============================================
updateStatus(false)
updateCounter(0)

print("========================================")
print("⚡ PRO AUTO CLICKER v5.0 ЗАГРУЖЕН!")
print("📌 Нажмите F6 для старта/остановки")
print("📌 Перетащите окно за заголовок")
print("📌 Кнопка − для сворачивания")
print("========================================")
