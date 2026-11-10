--[[
    NOVA UI LIBRARY v 1.0
    Compatible: Roblox Luau
    Executors: Real, Xeno
    Features:
    - Window / Tabs / Sections
    - Buttons
    - Toggles
    - Sliders
    - Dropdowns
    - Text Inputs
    - Set / Get methods
    - Refresh dropdown
]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}

local C = {
	bg = Color3.fromRGB(18,18,24),
	side = Color3.fromRGB(24,24,33),
	element = Color3.fromRGB(33,33,45),
	accent = Color3.fromRGB(125,95,255),
	text = Color3.fromRGB(240,240,250),
	muted = Color3.fromRGB(150,150,170)
}

local function make(class, props, parent)
	local obj = Instance.new(class)

	for k,v in pairs(props or {}) do
		obj[k] = v
	end

	obj.Parent = parent
	return obj
end

local function corner(obj, radius)
	make("UICorner", {
		CornerRadius = UDim.new(0, radius or 8)
	}, obj)
end

local function animate(obj, props)
	TweenService:Create(
		obj,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad),
		props
	):Play()
end

local function parentGui()
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end

	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and core then
		return core
	end

	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function call(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

-- WINDOW

function Library.new(config)
	config = config or {}

	local guiParent = parentGui()
	local guiName = config.Name or "NovaUI"

	local old = guiParent:FindFirstChild(guiName)

	if old then
		old:Destroy()
	end

	local gui = make("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, guiParent)

	local window = make("Frame", {
		Size = UDim2.fromOffset(540,355),
		Position = UDim2.new(0.5,-270,0.5,-177),
		BackgroundColor3 = C.bg,
		BorderSizePixel = 0,
		ClipsDescendants = true
	},gui)

	corner(window,11)

	local header = make("Frame", {
		Size = UDim2.new(1,0,0,46),
		BackgroundColor3 = C.side,
		BorderSizePixel = 0
	},window)

	make("TextLabel", {
		Size = UDim2.new(1,-95,1,0),
		Position = UDim2.fromOffset(14,0),
		BackgroundTransparency = 1,
		Text = config.Title or "Nova UI",
		TextColor3 = C.text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	},header)

	local minimize = make("TextButton", {
		Size = UDim2.fromOffset(28,28),
		Position = UDim2.new(1,-68,0,9),
		Text = "−",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextColor3 = C.text,
		BackgroundColor3 = C.element,
		BorderSizePixel = 0
	},header)

	corner(minimize,7)

	local close = make("TextButton", {
		Size = UDim2.fromOffset(28,28),
		Position = UDim2.new(1,-35,0,9),
		Text = "×",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextColor3 = C.text,
		BackgroundColor3 = C.element,
		BorderSizePixel = 0
	},header)

	corner(close,7)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local minimized = false

	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized

		minimize.Text = minimized and "+" or "−"

		animate(window,{
			Size = minimized
				and UDim2.fromOffset(540,46)
				or UDim2.fromOffset(540,355)
		})
	end)

	-- WINDOW DRAG

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = window.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	local dragConnection = UIS.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart

			window.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	gui.Destroying:Connect(function()
		dragConnection:Disconnect()
	end)

	-- SIDEBAR

	local sidebar = make("Frame", {
		Position = UDim2.fromOffset(0,46),
		Size = UDim2.new(0,140,1,-46),
		BackgroundColor3 = C.side,
		BorderSizePixel = 0
	},window)

	local tabs = make("Frame", {
		Position = UDim2.fromOffset(8,10),
		Size = UDim2.new(1,-16,1,-20),
		BackgroundTransparency = 1
	},sidebar)

	make("UIListLayout", {
		Padding = UDim.new(0,6)
	},tabs)

	local content = make("Frame", {
		Position = UDim2.fromOffset(151,56),
		Size = UDim2.new(1,-162,1,-66),
		BackgroundTransparency = 1
	},window)

	local api = {
		Gui = gui,
		Window = window,
		Tabs = {}
	}

	function api:SetMinimized(value)
		minimized = value == true

		minimize.Text = minimized and "+" or "−"

		animate(window,{
			Size = minimized
				and UDim2.fromOffset(540,46)
				or UDim2.fromOffset(540,355)
		})
	end

	function api:CreateTab(name)
		local button = make("TextButton", {
			Size = UDim2.new(1,0,0,34),
			Text = "  "..name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextColor3 = C.muted,
			BackgroundColor3 = C.side,
			BorderSizePixel = 0,
			AutoButtonColor = false
		},tabs)

		corner(button,7)

		local page = make("ScrollingFrame", {
			Size = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.accent,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		},content)

		make("UIListLayout", {
			Padding = UDim.new(0,9)
		},page)

		make("UIPadding", {
			PaddingRight = UDim.new(0,5),
			PaddingBottom = UDim.new(0,5)
		},page)

		local tab = {
			Button = button,
			Page = page
		}

		local function selectTab()
			for _,item in ipairs(api.Tabs) do
				item.Page.Visible = false

				animate(item.Button,{
					BackgroundColor3 = C.side,
					TextColor3 = C.muted
				})
			end

			page.Visible = true

			animate(button,{
				BackgroundColor3 = C.element,
				TextColor3 = C.text
			})
		end

		button.MouseButton1Click:Connect(selectTab)

		-- SECTION

		function tab:CreateSection(title)
			local section = make("Frame", {
				Size = UDim2.new(1,-2,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = C.side,
				BorderSizePixel = 0
			},page)

			corner(section,8)

			make("UIPadding", {
				PaddingTop = UDim.new(0,9),
				PaddingBottom = UDim.new(0,9),
				PaddingLeft = UDim.new(0,8),
				PaddingRight = UDim.new(0,8)
			},section)

			make("UIListLayout", {
				Padding = UDim.new(0,7)
			},section)

			make("TextLabel", {
				Size = UDim2.new(1,0,0,18),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = C.accent,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left
			},section)

			local s = {}

			-- BUTTON

			function s:CreateButton(opts)
				opts = opts or {}

				local b = make("TextButton", {
					Size = UDim2.new(1,0,0,36),
					Text = opts.Name or "Button",
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.GothamMedium,
					BackgroundColor3 = C.element,
					BorderSizePixel = 0,
					AutoButtonColor = false
				},section)

				corner(b,7)

				b.MouseEnter:Connect(function()
					animate(b,{BackgroundColor3 = C.accent})
				end)

				b.MouseLeave:Connect(function()
					animate(b,{BackgroundColor3 = C.element})
				end)

				b.MouseButton1Click:Connect(function()
					call(opts.Callback)
				end)

				return b
			end

			-- TOGGLE

			function s:CreateToggle(opts)
				opts = opts or {}

				local enabled = opts.CurrentValue == true

				local row = make("TextButton", {
					Size = UDim2.new(1,0,0,37),
					Text = "",
					BackgroundColor3 = C.element,
					BorderSizePixel = 0,
					AutoButtonColor = false
				},section)

				corner(row,7)

				make("TextLabel", {
					Position = UDim2.fromOffset(10,0),
					Size = UDim2.new(1,-62,1,0),
					BackgroundTransparency = 1,
					Text = opts.Name or "Toggle",
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left
				},row)

				local track = make("Frame", {
					Size = UDim2.fromOffset(34,18),
					Position = UDim2.new(1,-43,0.5,-9),
					BackgroundColor3 = enabled and C.accent or C.muted,
					BorderSizePixel = 0
				},row)

				corner(track,9)

				local knob = make("Frame", {
					Size = UDim2.fromOffset(14,14),
					Position = UDim2.fromOffset(enabled and 18 or 2,2),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0
				},track)

				corner(knob,7)

				local toggle = {}

				function toggle:Set(value)
					enabled = value == true

					animate(track,{
						BackgroundColor3 = enabled and C.accent or C.muted
					})

					animate(knob,{
						Position = UDim2.fromOffset(enabled and 18 or 2,2)
					})

					call(opts.Callback,enabled)
				end

				function toggle:Get()
					return enabled
				end

				row.MouseButton1Click:Connect(function()
					toggle:Set(not enabled)
				end)

				return toggle
			end

			-- SLIDER

			function s:CreateSlider(opts)
				opts = opts or {}

				local range = opts.Range or {0,100}
				local min = range[1]
				local max = range[2]

				assert(type(min) == "number" and type(max) == "number" and max > min,
					"Slider Range must contain valid minimum and maximum numbers")

				local decimals = math.max(0,math.floor(opts.Decimals or 0))
				local value = math.clamp(opts.CurrentValue or min,min,max)

				local row = make("Frame", {
					Size = UDim2.new(1,0,0,60),
					BackgroundColor3 = C.element,
					BorderSizePixel = 0
				},section)

				corner(row,7)

				make("TextLabel", {
					Position = UDim2.fromOffset(10,5),
					Size = UDim2.new(1,-75,0,20),
					BackgroundTransparency = 1,
					Text = opts.Name or "Slider",
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left
				},row)

				local valueLabel = make("TextLabel", {
					Position = UDim2.new(1,-65,0,5),
					Size = UDim2.fromOffset(55,20),
					BackgroundTransparency = 1,
					Text = tostring(value),
					TextColor3 = C.accent,
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Right
				},row)

				local track = make("TextButton", {
					Position = UDim2.fromOffset(10,36),
					Size = UDim2.new(1,-20,0,7),
					Text = "",
					BackgroundColor3 = C.muted,
					BorderSizePixel = 0,
					AutoButtonColor = false
				},row)

				corner(track,5)

				local fill = make("Frame", {
					BackgroundColor3 = C.accent,
					BorderSizePixel = 0
				},track)

				corner(fill,5)

				local knob = make("Frame", {
					Size = UDim2.fromOffset(13,13),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0
				},track)

				corner(knob,7)

				local slider = {}

				local function setValue(v,fire)
					v = math.clamp(tonumber(v) or min,min,max)

					local mult = 10 ^ decimals
					value = math.floor(v * mult + 0.5) / mult

					local percent = (value-min)/(max-min)

					fill.Size = UDim2.new(percent,0,1,0)
					knob.Position = UDim2.new(percent,-6.5,0.5,-6.5)
					valueLabel.Text = tostring(value)

					if fire then
						call(opts.Callback,value)
					end
				end

				local function update(input)
					local percent = math.clamp(
						(input.Position.X-track.AbsolutePosition.X)
							/ track.AbsoluteSize.X,
						0,1
					)

					setValue(min+(max-min)*percent,true)
				end

				local sliding = false

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then

						sliding = true
						update(input)
					end
				end)

				local moveConnection = UIS.InputChanged:Connect(function(input)
					if sliding and (
						input.UserInputType == Enum.UserInputType.MouseMovement
							or input.UserInputType == Enum.UserInputType.Touch
						) then
						update(input)
					end
				end)

				local endConnection = UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						sliding = false
					end
				end)

				gui.Destroying:Connect(function()
					moveConnection:Disconnect()
					endConnection:Disconnect()
				end)

				function slider:Set(v)
					setValue(v,true)
				end

				function slider:Get()
					return value
				end

				setValue(value,false)

				return slider
			end

			-- DROPDOWN

			function s:CreateDropdown(opts)
				opts = opts or {}

				local options = opts.Options or {}
				local selected = opts.CurrentOption

				if selected == nil then
					selected = options[1]
				end

				local opened = false

				local row = make("Frame", {
					Size = UDim2.new(1,0,0,38),
					BackgroundTransparency = 1,
					ClipsDescendants = false
				},section)

				local dropdown = make("TextButton", {
					Size = UDim2.new(1,0,0,38),
					Text = "",
					BackgroundColor3 = C.element,
					BorderSizePixel = 0,
					AutoButtonColor = false
				},row)

				corner(dropdown,7)

				make("TextLabel", {
					Position = UDim2.fromOffset(10,0),
					Size = UDim2.new(0.5,0,1,0),
					BackgroundTransparency = 1,
					Text = opts.Name or "Dropdown",
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left
				},dropdown)

				local selectedLabel = make("TextLabel", {
					Position = UDim2.new(0.5,0,0,0),
					Size = UDim2.new(0.5,-28,1,0),
					BackgroundTransparency = 1,
					Text = tostring(selected or "Select"),
					TextColor3 = C.accent,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Right
				},dropdown)

				make("TextLabel", {
					Position = UDim2.new(1,-25,0,0),
					Size = UDim2.fromOffset(20,38),
					BackgroundTransparency = 1,
					Text = "⌄",
					TextColor3 = C.text,
					TextSize = 16,
					Font = Enum.Font.GothamBold
				},dropdown)

				local menu = make("Frame", {
					Position = UDim2.fromOffset(0,42),
					Size = UDim2.new(1,0,0,0),
					BackgroundColor3 = C.side,
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					ZIndex = 10
				},row)

				corner(menu,7)

				make("UIListLayout", {
					Padding = UDim.new(0,3)
				},menu)

				local drop = {}

				local function updateMenu()
					local height = math.min(#options*33,165)

					menu.Size = UDim2.new(1,0,0,height)
					row.Size = UDim2.new(1,0,0,opened and (height+45) or 38)
					menu.Visible = opened
				end

				local function setOption(option,fire)
					if not table.find(options,option) then
						return
					end

					selected = option
					selectedLabel.Text = tostring(option)

					opened = false
					updateMenu()

					if fire then
						call(opts.Callback,option)
					end
				end

				local function buildOptions()
					for _,child in ipairs(menu:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _,option in ipairs(options) do
						local item = make("TextButton", {
							Size = UDim2.new(1,0,0,30),
							Text = tostring(option),
							TextColor3 = C.text,
							TextSize = 12,
							Font = Enum.Font.Gotham,
							BackgroundColor3 = C.element,
							BorderSizePixel = 0,
							ZIndex = 11
						},menu)

						item.MouseButton1Click:Connect(function()
							setOption(option,true)
						end)
					end
				end

				buildOptions()

				dropdown.MouseButton1Click:Connect(function()
					opened = not opened
					updateMenu()
				end)

				function drop:Set(option)
					setOption(option,true)
				end

				function drop:Get()
					return selected
				end

				function drop:Refresh(newOptions)
					options = newOptions or {}

					if not table.find(options,selected) then
						selected = options[1]
						selectedLabel.Text = tostring(selected or "Select")
					end

					buildOptions()
					updateMenu()
				end

				return drop
			end

			-- INPUT

			function s:CreateInput(opts)
				opts = opts or {}

				local row = make("Frame", {
					Size = UDim2.new(1,0,0,38),
					BackgroundColor3 = C.element,
					BorderSizePixel = 0
				},section)

				corner(row,7)

				make("TextLabel", {
					Position = UDim2.fromOffset(10,0),
					Size = UDim2.new(0.45,0,1,0),
					BackgroundTransparency = 1,
					Text = opts.Name or "Input",
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left
				},row)

				local input = make("TextBox", {
					Position = UDim2.new(0.45,0,0,4),
					Size = UDim2.new(0.55,-8,1,-8),
					BackgroundColor3 = C.side,
					BorderSizePixel = 0,
					Text = tostring(opts.CurrentValue or ""),
					PlaceholderText = opts.Placeholder or "Enter value...",
					PlaceholderColor3 = C.muted,
					TextColor3 = C.text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					ClearTextOnFocus = false
				},row)

				corner(input,5)

				local field = {}

				input.FocusLost:Connect(function(enterPressed)
					call(opts.Callback,input.Text,enterPressed)
				end)

				function field:Set(value)
					input.Text = tostring(value)
				end

				function field:Get()
					return input.Text
				end

				function field:Submit()
					call(opts.Callback,input.Text,true)
				end

				return field
			end

			return s
		end

		table.insert(api.Tabs,tab)

		if #api.Tabs == 1 then
			selectTab()
		end

		return tab
	end

	return api
end

return Library
