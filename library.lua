-- UI Library (Scaled Down)
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Theme
local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(28, 28, 33),
	Accent = Color3.fromRGB(88, 101, 242),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(180, 180, 190),
	Border = Color3.fromRGB(45, 45, 50)
}

-- Utility
local function Tween(obj, props, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then obj[k] = v end
	end
	obj.Parent = props.Parent
	return obj
end

function Library:Init(config)
	config = config or {}
	config.Name = config.Name or "UI Library"

	local Window = { Tabs = {}, CurrentTab = nil }

	-- ScreenGui
	local ScreenGui = Create("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game:GetService("CoreGui")
	})

	-- Main (SMALLER)
	local Main = Create("Frame", {
		Size = UDim2.new(0, 480, 0, 320),
		Position = UDim2.new(0.5, -240, 0.5, -160),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = ScreenGui
	})

	Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })

	-- Topbar (SMALLER)
	local Topbar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})

	Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Topbar })

	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Topbar
	})

	-- Title
	Create("TextLabel", {
		Text = config.Name,
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Topbar
	})

	-- Close
	local CloseBtn = Create("TextButton", {
		Text = "×",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -34, 0, 4),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		TextColor3 = Theme.Text,
		TextSize = 22,
		Font = Enum.Font.GothamBold,
		Parent = Topbar
	})

	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })
	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- Tabs (NARROWER)
	local TabContainer = Create("ScrollingFrame", {
		Size = UDim2.new(0, 120, 1, -48),
		Position = UDim2.new(0, 8, 0, 45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		Parent = Main
	})

	local TabLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		Parent = TabContainer
	})

	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
	end)

	-- Content (ADJUSTED)
	local ContentContainer = Create("Frame", {
		Size = UDim2.new(1, -140, 1, -48),
		Position = UDim2.new(0, 135, 0, 45),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})

	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ContentContainer })

	-- Dragging (Mouse + Touch)
	local dragging = false
	local dragStart
	local startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			updateDrag(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Tabs
	function Window:CreateTab(name)
		local Tab = {}

		local TabBtn = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0,
			Text = "",
			Parent = TabContainer
		})

		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })

		local Label = Create("TextLabel", {
			Text = name,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme.TextDark,
			TextSize = 13,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TabBtn
		})

		local Content = Create("ScrollingFrame", {
			Size = UDim2.new(1, -16, 1, -16),
			Position = UDim2.new(0, 8, 0, 8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			Visible = false,
			Parent = ContentContainer
		})

		local Layout = Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			Parent = Content
		})

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 6)
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Window.Tabs) do
				t.Button.BackgroundColor3 = Theme.Border
				t.Label.TextColor3 = Theme.TextDark
				t.Content.Visible = false
			end
			TabBtn.BackgroundColor3 = Theme.Accent
			Label.TextColor3 = Theme.Text
			Content.Visible = true
		end)

		Tab.Button = TabBtn
		Tab.Label = Label
		Tab.Content = Content

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			TabBtn.BackgroundColor3 = Theme.Accent
			Label.TextColor3 = Theme.Text
			Content.Visible = true
		end

		-- Elements
		function Tab:AddLabel(text)
			local Label = Create("TextLabel", {
				Text = text,
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				TextColor3 = Theme.TextDark,
				TextSize = 13,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Content
			})

			Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = Label })

			-- Controller
			local LabelObj = {}

			function LabelObj:SetText(newText)
				Label.Text = tostring(newText)
			end

			function LabelObj:GetText()
				return Label.Text
			end

			function LabelObj:Destroy()
				Label:Destroy()
			end

			return LabelObj
		end

		return Tab
	end

	return Window
end

return Library
