local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI Library Configuration
local Config = {
	MainColor = Color3.fromRGB(25, 25, 35),
	SecondaryColor = Color3.fromRGB(35, 35, 45),
	AccentColor = Color3.fromRGB(100, 120, 255),
	TextColor = Color3.fromRGB(255, 255, 255),
	BorderColor = Color3.fromRGB(50, 50, 60),
	Font = Enum.Font.Gotham,
	TweenSpeed = 0.2
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

-- Create Main Window
function Library:CreateWindow(title)
	local window = {}
	
	-- ScreenGui
	local screenGui = create("ScreenGui", {
		Name = "UILibrary",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game.CoreGui
	})
	
	-- Main Frame
	local mainFrame = create("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 550, 0, 400),
		Position = UDim2.new(0.5, -275, 0.5, -200),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Parent = screenGui
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = mainFrame
	})
	
	-- Drop shadow
	create("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 30, 1, 30),
		Position = UDim2.new(0, -15, 0, -15),
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 0,
		Parent = mainFrame
	})
	
	-- Title Bar
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = titleBar
	})
	
	-- Title Text
	create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Config.TextColor,
		TextSize = 16,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})
	
	-- Close Button
	local closeBtn = create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Config.TextColor,
		TextSize = 20,
		Font = Config.Font,
		Parent = titleBar
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = closeBtn
	})
	
	closeBtn.MouseButton1Click:Connect(function()
		tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		wait(0.3)
		screenGui:Destroy()
	end)
	
	-- Tab Container
	local tabContainer = create("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 120, 1, -50),
		Position = UDim2.new(0, 10, 0, 45),
		BackgroundTransparency = 1,
		Parent = mainFrame
	})
	
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = tabContainer
	})
	
	-- Content Container
	local contentContainer = create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -140, 1, -50),
		Position = UDim2.new(0, 130, 0, 45),
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
	
	window.screenGui = screenGui
	window.mainFrame = mainFrame
	window.tabContainer = tabContainer
	window.contentContainer = contentContainer
	window.tabs = {}
	window.currentTab = nil
	
	return setmetatable(window, {__index = Library})
end

-- Create Tab
function Library:CreateTab(name)
	local tab = {}
	
	local tabBtn = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		Parent = self.tabContainer
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = tabBtn
	})
	
	local tabContent = create("ScrollingFrame", {
		Name = name.."Content",
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Config.AccentColor,
		Visible = false,
		Parent = self.contentContainer
	})
	
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = tabContent
	})
	
	tabBtn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.tabs) do
			t.button.BackgroundColor3 = Config.SecondaryColor
			t.content.Visible = false
		end
		
		tabBtn.BackgroundColor3 = Config.AccentColor
		tabContent.Visible = true
		self.currentTab = tab
	end)
	
	tab.button = tabBtn
	tab.content = tabContent
	tab.elements = {}
	
	table.insert(self.tabs, tab)
	
	if #self.tabs == 1 then
		tabBtn.BackgroundColor3 = Config.AccentColor
		tabContent.Visible = true
		self.currentTab = tab
	end
	
	return setmetatable(tab, {__index = Library})
end

-- Create Button
function Library:CreateButton(name, callback)
	local btn = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = btn
	})
	
	create("UIStroke", {
		Color = Config.BorderColor,
		Thickness = 1,
		Parent = btn
	})
	
	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = Config.AccentColor})
	end)
	
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = Config.SecondaryColor})
	end)
	
	btn.MouseButton1Click:Connect(function()
		tween(btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.1)
		wait(0.1)
		tween(btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
		callback()
	end)
	
	return btn
end

-- Create Toggle
function Library:CreateToggle(name, default, callback)
	local toggled = default or false
	
	local toggleFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = toggleFrame
	})
	
	create("UIStroke", {
		Color = Config.BorderColor,
		Thickness = 1,
		Parent = toggleFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toggleFrame
	})
	
	local toggleBtn = create("TextButton", {
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -45, 0.5, -10),
		BackgroundColor3 = toggled and Config.AccentColor or Config.BorderColor,
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
		
		tween(toggleBtn, {BackgroundColor3 = toggled and Config.AccentColor or Config.BorderColor})
		tween(indicator, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
		
		callback(toggled)
	end)
	
	return toggleFrame
end

-- Create Slider
function Library:CreateSlider(name, min, max, default, callback)
	local value = default or min
	
	local sliderFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = sliderFrame
	})
	
	create("UIStroke", {
		Color = Config.BorderColor,
		Thickness = 1,
		Parent = sliderFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = name..": "..value,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sliderFrame
	})
	
	local sliderBar = create("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 1, -15),
		BackgroundColor3 = Config.BorderColor,
		BorderSizePixel = 0,
		Parent = sliderFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = sliderBar
	})
	
	local sliderFill = create("Frame", {
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Config.AccentColor,
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

-- Create Textbox
function Library:CreateTextbox(name, placeholder, callback)
	local textboxFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = textboxFrame
	})
	
	create("UIStroke", {
		Color = Config.BorderColor,
		Thickness = 1,
		Parent = textboxFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = textboxFrame
	})
	
	local textbox = create("TextBox", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 1, -25),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = placeholder,
		TextColor3 = Config.TextColor,
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 13,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = textboxFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = textbox
	})
	
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		Parent = textbox
	})
	
	textbox.FocusLost:Connect(function(enter)
		if enter then
			callback(textbox.Text)
		end
	end)
	
	return textboxFrame
end

-- Create Dropdown
function Library:CreateDropdown(name, options, callback)
	local selected = options[1] or "None"
	local open = false
	
	local dropdownFrame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Config.SecondaryColor,
		BorderSizePixel = 0,
		Parent = self.content
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = dropdownFrame
	})
	
	create("UIStroke", {
		Color = Config.BorderColor,
		Thickness = 1,
		Parent = dropdownFrame
	})
	
	local label = create("TextLabel", {
		Size = UDim2.new(0.5, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Config.TextColor,
		TextSize = 14,
		Font = Config.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = dropdownFrame
	})
	
	local dropdownBtn = create("TextButton", {
		Size = UDim2.new(0.5, -20, 0, 25),
		Position = UDim2.new(0.5, 10, 0, 5),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Text = selected.." ▼",
		TextColor3 = Config.TextColor,
		TextSize = 13,
		Font = Config.Font,
		Parent = dropdownFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = dropdownBtn
	})
	
	local optionsFrame = create("Frame", {
		Name = "Options",
		Size = UDim2.new(0.5, -20, 0, #options * 30),
		Position = UDim2.new(0.5, 10, 0, 35),
		BackgroundColor3 = Config.MainColor,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10,
		Parent = dropdownFrame
	})
	
	create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = optionsFrame
	})
	
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = optionsFrame
	})
	
	for _, option in ipairs(options) do
		local optionBtn = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Config.MainColor,
			BorderSizePixel = 0,
			Text = option,
			TextColor3 = Config.TextColor,
			TextSize = 13,
			Font = Config.Font,
			ZIndex = 11,
			Parent = optionsFrame
		})
		
		optionBtn.MouseEnter:Connect(function()
			tween(optionBtn, {BackgroundColor3 = Config.AccentColor})
		end)
		
		optionBtn.MouseLeave:Connect(function()
			tween(optionBtn, {BackgroundColor3 = Config.MainColor})
		end)
		
		optionBtn.MouseButton1Click:Connect(function()
			selected = option
			dropdownBtn.Text = selected.." ▼"
			optionsFrame.Visible = false
			open = false
			tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 35)})
			callback(selected)
		end)
	end
	
	dropdownBtn.MouseButton1Click:Connect(function()
		open = not open
		optionsFrame.Visible = open
		
		if open then
			tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + #options * 30 + 5)})
		else
			tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 35)})
		end
	end)
	
	return dropdownFrame
end

-- Create Label
function Library:CreateLabel(text)
	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Config.TextColor,
		TextSize = 14,
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

return Library
