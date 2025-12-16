local ZayHub = {}
ZayHub.__index = ZayHub

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local Config = {
	MainColor = Color3.fromRGB(20, 20, 20),
	SecondaryColor = Color3.fromRGB(30, 30, 30),
	AccentColor = Color3.fromRGB(60, 60, 60),
	HoverColor = Color3.fromRGB(45, 45, 45),
	TextColor = Color3.fromRGB(255, 255, 255),
	BorderColor = Color3.fromRGB(50, 50, 50),
	Font = Enum.Font.GothamBold,
	TweenSpeed = 0.15
}

-- Utility Functions
local function tween(obj, props, duration)
	duration = duration or Config.TweenSpeed
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function create(class, props)
	local obj = Instance.new(class)
	for prop, val in pairs(props) do
		if prop ~= "Parent" then
			obj[prop] = val
		end
	end
	obj.Parent = props.Parent
	return obj
end

-- Initialize the Hub
function ZayHub:Init(hubName)
	local hub = {
		hubName = hubName or "ZayHub",
		tabs = {},
		currentTab = nil
	}
	
	-- ScreenGui
	local screenGui = create("ScreenGui", {
		Name = "ZayHub",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game.CoreGui
	})
	
	-- Main Frame
	local mainFrame = create("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, -250, 0.5, -175),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Parent = screenGui
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = mainFrame
	})
	
	-- Title Bar
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = titleBar
	})
	
	-- Fix bottom corners
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = titleBar
	})
	
	-- Title Text
	create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = hub.hubName,
		TextColor3 = Config.TextColor,
		TextSize = 15,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})
	
	-- Minimize Button
	local minimizeBtn = create("TextButton", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -60, 0, 5),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Text = "−",
		TextColor3 = Config.TextColor,
		TextSize = 18,
		Font = Config.Font,
		Parent = titleBar
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = minimizeBtn
	})
	
	-- Close Button
	local closeBtn = create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -30, 0, 5),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Config.TextColor,
		TextSize = 20,
		Font = Config.Font,
		Parent = titleBar
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeBtn
	})
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(mainFrame, {Size = UDim2.new(0, 500, 0, 35)}, 0.2)
		else
			tween(mainFrame, {Size = UDim2.new(0, 500, 0, 350)}, 0.2)
		end
	end)
	
	-- Tab Container (Left Side)
	local tabContainer = create("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 180, 1, -45),
		Position = UDim2.new(0, 10, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = mainFrame
	})
	
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = tabContainer
	})
	
	-- Content Container (Right Side)
	local contentContainer = create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -200, 1, -45),
		Position = UDim2.new(0, 195, 0, 40),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = contentContainer
	})
	
	-- Make draggable
	local dragging, dragInput, dragStart, startPos
	
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	hub.screenGui = screenGui
	hub.mainFrame = mainFrame
	hub.tabContainer = tabContainer
	hub.contentContainer = contentContainer
	
	return setmetatable(hub, {__index = ZayHub})
end

-- Create Tab
function ZayHub:CreateTab(name)
	local tab = {}
	
	local tabBtn = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = self.tabContainer
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = tabBtn
	})
	
	-- Tab Icon
	local icon = create("Frame", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 8, 0.5, -15),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Parent = tabBtn
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = icon
	})
	
	-- Icon Circle (decorative)
	create("Frame", {
		Size = UDim2.new(0, 15, 0, 15),
		Position = UDim2.new(0.5, -7.5, 0.5, -7.5),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Parent = icon
	})
	
	-- Tab Text
	local tabText = create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 45, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tabBtn
	})
	
	-- Info Icon (circle with i)
	local infoBtn = create("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -25, 0.5, -10),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Text = "i",
		TextColor3 = Config.TextColor,
		TextSize = 12,
		Font = Config.Font,
		Parent = tabBtn
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = infoBtn
	})
	
	-- Tab Content
	local tabContent = create("ScrollingFrame", {
		Name = name.."Content",
		Size = UDim2.new(1, -15, 1, -15),
		Position = UDim2.new(0, 7, 0, 7),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Config.AccentColor,
		Visible = false,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self.contentContainer
	})
	
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = tabContent
	})
	
	-- Hover effects
	tabBtn.MouseEnter:Connect(function()
		if tab ~= self.currentTab then
			tween(tabBtn, {BackgroundColor3 = Config.HoverColor})
		end
	end)
	
	tabBtn.MouseLeave:Connect(function()
		if tab ~= self.currentTab then
			tween(tabBtn, {BackgroundColor3 = Config.AccentColor})
		end
	end)
	
	-- Tab switching
	tabBtn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.tabs) do
			tween(t.button, {BackgroundColor3 = Config.AccentColor})
			t.content.Visible = false
		end
		
		tween(tabBtn, {BackgroundColor3 = Config.HoverColor})
		tabContent.Visible = true
		self.currentTab = tab
	end)
	
	tab.button = tabBtn
	tab.content = tabContent
	tab.elements = {}
	
	table.insert(self.tabs, tab)
	
	-- Auto-select first tab
	if #self.tabs == 1 then
		tabBtn.BackgroundColor3 = Config.HoverColor
		tabContent.Visible = true
		self.currentTab = tab
	end
	
	return setmetatable(tab, {__index = ZayHub})
end

-- Create Button
function ZayHub:CreateButton(name, callback)
	local btn = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 13,
		Font = Config.Font,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = btn
	})
	
	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = Config.HoverColor})
	end)
	
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = Config.AccentColor})
	end)
	
	btn.MouseButton1Click:Connect(function()
		tween(btn, {BackgroundColor3 = Config.MainColor}, 0.1)
		wait(0.1)
		tween(btn, {BackgroundColor3 = Config.AccentColor}, 0.1)
		callback()
	end)
	
	return btn
end

-- Create Toggle
function ZayHub:CreateToggle(name, default, callback)
	local toggled = default or false
	
	local toggleFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = toggleFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 13,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toggleFrame
	})
	
	local toggleBtn = create("TextButton", {
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -45, 0.5, -10),
		BackgroundColor3 = toggled and Color3.fromRGB(100, 200, 100) or Config.MainColor,
		BorderSizePixel = 0,
		Text = "",
		Parent = toggleFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = toggleBtn
	})
	
	local indicator = create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Config.TextColor,
		BorderSizePixel = 0,
		Parent = toggleBtn
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = indicator
	})
	
	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		
		tween(toggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(100, 200, 100) or Config.MainColor})
		tween(indicator, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
		
		callback(toggled)
	end)
	
	return toggleFrame
end

-- Create Slider
function ZayHub:CreateSlider(name, min, max, default, callback)
	local value = default or min
	
	local sliderFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Config.AccentColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = sliderFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = name..": "..value,
		TextColor3 = Config.TextColor,
		TextSize = 13,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sliderFrame
	})
	
	local sliderBar = create("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 1, -15),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Parent = sliderFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = sliderBar
	})
	
	local sliderFill = create("Frame", {
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Config.TextColor,
		BorderSizePixel = 0,
		Parent = sliderBar
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = sliderFill
	})
	
	local dragging = false
	
	sliderBar.InputBegan:Connect(function(input)
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
			local mouse = UserInputService:GetMouseLocation()
			local percent = math.clamp((mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
			value = math.floor(min + (max - min) * percent)
			
			label.Text = name..": "..value
			sliderFill.Size = UDim2.new(percent, 0, 1, 0)
			
			callback(value)
		end
	end)
	
	return sliderFrame
end

-- Create Label
function ZayHub:CreateLabel(text)
	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Config.TextColor,
		TextSize = 13,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.content
	})
	
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		Parent = label
	})
	
	return label
end

return ZayHub
