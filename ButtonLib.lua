local v = {}

type params = 
	{
		Header: string, 
		TextFont: Enum.Font, 
		BackgroundColor:Color3, 
		ButtonColor: Color3, 
		ButtonText: string,
		Draggable: boolean
	}

function v:CreateList(params: params, callback)
	local CanDrag = params.Draggable
	local ScreenGui = Instance.new("ScreenGui", gethui())
	local Frame = Instance.new("Frame", ScreenGui)
	local UICorner = Instance.new("UICorner", Frame)
	local UIStroke = Instance.new("UIStroke", Frame)
	local TextLabel = Instance.new("TextLabel", Frame)
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint", TextLabel)
	local TextButton = Instance.new("TextButton", Frame)
	local UICorner_1 = Instance.new("UICorner", TextButton)
	local UIStroke_1 = Instance.new("UIStroke", TextButton)
	local UITextSizeConstraint_1 = Instance.new("UITextSizeConstraint", TextButton)
	local Font1 = tostring(params.TextFont):match("Enum.Font%.(.+)")
	Frame.BackgroundColor3 = params.BackgroundColor or Color3.new(0.098, 0.098, 0.098)
	Frame.Position = UDim2.new(0.3, 0, 0.4, 0)
	Frame.Size = UDim2.new(0, 212, 0, 78)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.new(1,1,1)
	UIStroke.Thickness = 2
	TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	TextLabel.Text = params.Header or ''
	TextLabel.TextColor3 = Color3.new(1.000, 1.000, 1.000)
	TextLabel.TextSize = 15
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(0, 212, 0, 17)
	UITextSizeConstraint.MaxTextSize = 20
	TextButton.FontFace = Font.new("rbxasset://fonts/families/" .. `{Font1 or "Michroma"}`..".json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	TextButton.Text = params.ButtonText or 'TextButton'
	TextButton.TextColor3 = Color3.new(0,0,0)
	TextButton.TextSize = 20
	TextButton.TextWrapped = true
	TextButton.BackgroundColor3 = params.ButtonColor3 or Color3.new(0.455, 0.455, 0.455)
	TextButton.Position = UDim2.new(0, 0, 0.321, 0)
	TextButton.Size = UDim2.new(0, 212, 0, 53)
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.Color = Color3.new(1.000, 1.000, 1.000)
	UIStroke_1.Thickness = 2
	UITextSizeConstraint_1.MaxTextSize = 30
	TextButton.MouseButton1Click:Connect(function()
		task.spawn(callback)
	end)
	task.spawn(function()
		local UserInputService = game:GetService("UserInputService")
		local gui = Frame
		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and CanDrag or input.UserInputType == Enum.UserInputType.Touch and CanDrag then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End and CanDrag then
						dragging = false
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and CanDrag or input.UserInputType == Enum.UserInputType.Touch and CanDrag then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging and CanDrag then
				update(input)
			end
		end)
	end)
	return ScreenGui
end

function v:SetLabel(List, text)
	List.Frame.TextButton.Text = text
end
	
return v
