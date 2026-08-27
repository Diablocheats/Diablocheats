-- Auto Clicker для Roblox (Lua) - ИСПРАВЛЕННАЯ ВЕРСИЯ С КЛИКАМИ
-- Вставьте в Executor (Synapse X, Krnl, Script-Ware, etc.)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- === НАСТРОЙКИ ПО УМОЛЧАНИЮ ===
local settings = {
    interval = 10,
    randomOffset = 40,
    clickButton = "Left",
    clickType = "Single",
    repeatMode = "UntilStopped",
    repeatCount = 1,
    cursorMode = "Current",
    customX = 0,
    customY = 0
}

local isRunning = false
local clickCount = 0
local clickTimer = nil
local isMinimized = false

-- === ФУНКЦИЯ КЛИКА (РАБОЧАЯ) ===
local function doClick(x, y, button)
    -- Метод 1: Через mouseclick (работает в большинстве экзекьюторов)
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
    
    -- Метод 2: Через VirtualInputManager
    local success, err = pcall(function()
        local btn = Enum.UserInputType.MouseButton1
        if button == "Right" then
            btn = Enum.UserInputType.MouseButton2
        elseif button == "Middle" then
            btn = Enum.UserInputType.MouseButton3
        end
        
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, btn, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, btn, 0)
    end)
    
    if success then return true end
    
    -- Метод 3: Через мос (для старых экзекьюторов)
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
    
    return false
end

-- === СОЗДАНИЕ GUI (БЕЗ ФОНА) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "AutoClickerGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основное окно (без затемнения)
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true

-- Скругление углов
local corner = Instance.new("UICorner")
corner.Parent = frame
corner.CornerRadius = UDim.new(0, 12)

-- Тень
local shadow = Instance.new("Frame")
shadow.Parent = screenGui
shadow.Size = UDim2.new(0, 400, 0, 500)
shadow.Position = UDim2.new(0.5, -200, 0.5, -250)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = 0

local shadowCorner = Instance.new("UICorner")
shadowCorner.Parent = shadow
shadowCorner.CornerRadius = UDim.new(0, 12)

-- Заголовок
local header = Instance.new("Frame")
header.Parent = frame
header.Size = UDim2.new(1, 0, 0, 45)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
header.BorderSizePixel = 0
header.ZIndex = 2

local headerCorner = Instance.new("UICorner")
headerCorner.Parent = header
headerCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Auto Clicker 4.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2

-- Кнопка свернуть
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = header
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -80, 0, 7)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minimizeBtn.BackgroundTransparency = 0.8
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
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
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minimizeBtn.Text = "+"
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 45)}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 45)}):Play()
        content.Visible = false
    else
        minimizeBtn.Text = "−"
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 500)}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 500)}):Play()
        content.Visible = true
    end
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BackgroundTransparency = 0.8
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
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    if isRunning then stopClicker() end
    screenGui:Destroy()
end)

-- Контейнер для содержимого
local content = Instance.new("ScrollingFrame")
content.Parent = frame
content.Size = UDim2.new(1, -20, 1, -55)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 0, 500)
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
content.Visible = true

-- === ФУНКЦИЯ СОЗДАНИЯ ЭЛЕМЕНТОВ ===
local function createLabel(text, x, y, w, h, color)
    color = color or Color3.fromRGB(180, 180, 200)
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
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = tostring(default)
    box.TextSize = 13
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.PlaceholderText = "0"
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.Parent = box
    boxCorner.CornerRadius = UDim.new(0, 4)
    
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
    dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Text = default
    dropdown.TextSize = 13
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.BorderSizePixel = 0
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.Parent = dropdown
    dropCorner.CornerRadius = UDim.new(0, 4)
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = dropdown
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 200)
    arrow.TextSize = 12
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
        listFrame.Size = UDim2.new(0, w, 0, #options * 25)
        listFrame.Position = UDim2.new(0, x, 0, y + h + 2)
        listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 10
        
        local listCorner = Instance.new("UICorner")
        listCorner.Parent = listFrame
        listCorner.CornerRadius = UDim.new(0, 4)
        
        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Parent = listFrame
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*25)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.TextColor3 = Color3.fromRGB(220, 220, 255)
            btn.Text = opt
            btn.TextSize = 13
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.ZIndex = 11
            
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
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
    btn.Size = UDim2.new(0, 130, 0, 22)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local check = Instance.new("Frame")
    check.Parent = btn
    check.Size = UDim2.new(0, 16, 0, 16)
    check.Position = UDim2.new(1, -20, 0, 3)
    check.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
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
    checkMark.TextSize = 12
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

-- === СОЗДАНИЕ GUI ЭЛЕМЕНТОВ ===
local yOffset = 0

-- Интервал
createLabel("⏱ Click interval", 0, yOffset, 120, 20, Color3.fromRGB(150, 200, 255))
local intervalBox = createTextBox(settings.interval, 0, yOffset+20, 45, 22, function(v)
    settings.interval = v
end)
createLabel("ms", 50, yOffset+20, 30, 22)

createLabel("🎲 Random offset", 130, yOffset, 120, 20, Color3.fromRGB(150, 200, 255))
local randomBox = createTextBox(settings.randomOffset, 130, yOffset+20, 45, 22, function(v)
    settings.randomOffset = v
end)
createLabel("ms", 180, yOffset+20, 30, 22)

yOffset = yOffset + 50

-- Click options
createLabel("🖱 Click options", 0, yOffset, 120, 20, Color3.fromRGB(150, 200, 255))
local buttonDropdown = createDropdown({"Left", "Right", "Middle"}, settings.clickButton, 0, yOffset+20, 95, 22, function(v)
    settings.clickButton = v
end)
local typeDropdown = createDropdown({"Single", "Double"}, settings.clickType, 105, yOffset+20, 95, 22, function(v)
    settings.clickType = v
end)

yOffset = yOffset + 55

-- Click repeat
createLabel("🔄 Click repeat", 0, yOffset, 120, 20, Color3.fromRGB(150, 200, 255))
local repeatUntil = createRadioButton("Until stopped", 0, yOffset+20, "repeat", true, function(v)
    settings.repeatMode = "UntilStopped"
end)
local repeatCount = createRadioButton("Repeat", 140, yOffset+20, "repeat", false, function(v)
    settings.repeatMode = "Count"
end)
local countBox = createTextBox(settings.repeatCount, 0, yOffset+45, 45, 22, function(v)
    settings.repeatCount = v
end)
createLabel("times", 50, yOffset+45, 40, 22)

yOffset = yOffset + 75

-- Cursor position
createLabel("📍 Cursor position", 0, yOffset, 120, 20, Color3.fromRGB(150, 200, 255))
local currentPos = createRadioButton("Current location", 0, yOffset+20, "cursor", true, function(v)
    settings.cursorMode = "Current"
end)
local pickPos = createRadioButton("Pick location", 140, yOffset+20, "cursor", false, function(v)
    settings.cursorMode = "Pick"
end)
createLabel("X:", 0, yOffset+45, 15, 22)
local xBox = createTextBox(settings.customX, 20, yOffset+45, 45, 22, function(v)
    settings.customX = v
end)
createLabel("Y:", 75, yOffset+45, 15, 22)
local yBox = createTextBox(settings.customY, 95, yOffset+45, 45, 22, function(v)
    settings.customY = v
end)

-- Кнопка "Pick from cursor"
local pickBtn = Instance.new("TextButton")
pickBtn.Parent = content
pickBtn.Size = UDim2.new(0, 120, 0, 22)
pickBtn.Position = UDim2.new(0, 150, 0, yOffset+45)
pickBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
pickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pickBtn.Text = "📌 Pick current"
pickBtn.TextSize = 12
pickBtn.Font = Enum.Font.GothamMedium
pickBtn.BorderSizePixel = 0

local pickCorner = Instance.new("UICorner")
pickCorner.Parent = pickBtn
pickCorner.CornerRadius = UDim.new(0, 4)

pickBtn.MouseButton1Click:Connect(function()
    settings.customX = mouse.X
    settings.customY = mouse.Y
    xBox.Text = tostring(mouse.X)
    yBox.Text = tostring(mouse.Y)
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
    settings.cursorMode = "Pick"
end)

yOffset = yOffset + 80

-- Кнопки управления
local function createStyledButton(text, x, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = content
    btn.Size = UDim2.new(0, 110, 0, 35)
    btn.Position = UDim2.new(0, x, 0, yOffset)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color + Color3.fromRGB(20, 20, 20)}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 115, 0, 37)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 110, 0, 35)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local startBtn = createStyledButton("▶ Start (F6)", 0, Color3.fromRGB(0, 180, 80), function()
    startClicker()
end)

local stopBtn = createStyledButton("⏹ Stop (F6)", 120, Color3.fromRGB(200, 50, 50), function()
    stopClicker()
end)

local recordBtn = createStyledButton("⏺ Record", 240, Color3.fromRGB(60, 60, 180), function()
    print("🎥 Record & Playback функция в разработке")
end)

yOffset = yOffset + 45

-- Hotkey info
createLabel("⌨ Hotkey: F6 - Start/Stop", 0, yOffset, 250, 20, Color3.fromRGB(150, 200, 150))

-- Статус
local statusText = createLabel("● Stopped", 0, yOffset+22, 200, 20, Color3.fromRGB(255, 100, 100))

-- Счетчик кликов
local clickCounter = createLabel("Clicks: 0", 180, yOffset+22, 150, 20, Color3.fromRGB(200, 200, 150))

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ СТАТУСА ===
local function updateStatus(running)
    if running then
        statusText.Text = "● Running"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusText.Text = "● Stopped"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

local function updateCounter(count)
    clickCounter.Text = "Clicks: " .. count
end

-- === ОБНОВЛЕНИЕ CANVAS ===
content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 70)

-- === ЛОГИКА КЛИКЕРА (С ПРОВЕРКОЙ) ===
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
    
    -- Пробуем разные методы клика
    local clicked = doClick(x, y, button)
    
    if not clicked then
        warn("Не удалось выполнить клик! Попробуйте другой экзекьютор.")
        return false
    end
    
    if settings.clickType == "Double" then
        task.wait(0.05)
        doClick(x, y, button)
    end
    
    clickCount = clickCount + 1
    updateCounter(clickCount)
    return true
end

local function clickLoop()
    if not isRunning then return end
    
    local delay = settings.interval / 1000
    local offset = (math.random() * settings.randomOffset * 2 - settings.randomOffset) / 1000
    delay = math.max(0.001, delay + offset)
    
    local success = performClick()
    
    if settings.repeatMode == "Count" then
        if clickCount >= settings.repeatCount then
            stopClicker()
            return
        end
    end
    
    clickTimer = task.wait(delay)
    if isRunning then
        clickLoop()
    end
end

function startClicker()
    if isRunning then return end
    isRunning = true
    if settings.repeatMode == "Count" then
        clickCount = 0
    end
    updateStatus(true)
    print("⚡ Автокликер запущен!")
    clickLoop()
end

function stopClicker()
    isRunning = false
    if clickTimer then
        task.cancel(clickTimer)
        clickTimer = nil
    end
    updateStatus(false)
    print("⏹ Автокликер остановлен!")
end

-- === ГОРЯЧИЕ КЛАВИШИ ===
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

-- === ПЕРЕМЕЩЕНИЕ ОКНА ===
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

-- Обновление тени при перемещении
frame:GetPropertyChangedSignal("Position"):Connect(function()
    shadow.Position = frame.Position
end)

updateStatus(false)
updateCounter(0)
print("⚡ Auto Clicker 4.0 загружен! Нажмите F6 для старта/остановки.")
print("📌 Перетащите окно за заголовок, чтобы переместить.")
print("🔄 Кнопка − свернуть окно.")
