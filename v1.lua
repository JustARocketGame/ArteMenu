local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CenterX = 0
local CenterY = 0
local ScreenGuis = {}

local Assets = {
	[1] = "rbxassetid://106889675931893",
	[2] = "rbxassetid://89784276394909",
}

local CoreGui = game:GetService("CoreGui")
local GuiParent = PlayerGui

if not RunService:IsStudio() then
	GuiParent = CoreGui
end

local ArteMenu = {}

ArteMenu.DefaultWindowData = {
	["Title"] = "ArteMenu - Default Window",
	["Description"] = "You can change this description",
	["Authors"] = {"ArteGames"},
	["Version"] = "1.0.0",
}

local function GenerateRandomName(length)

	local name = ""
	for i = 1, length do
		name = name .. string.char(math.random(1, 255))
	end
	return name

end

local function CreateInstance(className, parent)

	local instance = Instance.new(className)
	instance.Parent = parent
	instance.Name = GenerateRandomName(10)
	return instance

end

local function CreateScreenGui(orderOffset)

	local screenGui = CreateInstance("ScreenGui", GuiParent)
	ScreenGuis[#ScreenGuis + 1] = screenGui
	screenGui.DisplayOrder = 99999 + orderOffset
	screenGui.IgnoreGuiInset = true
	
	return screenGui

end

local function MergeData(customData, defaultData)

	local mergedData = {}
	local sourceData = customData or {}
	for key, value in pairs(defaultData) do
		if not sourceData[key] then
			mergedData[key] = value
		else
			mergedData[key] = customData[key]
		end
	end
	return mergedData

end

function ArteMenu:CreateWindow(Data: {})

	local BackgroundColor = Color3.new(0, 0, 0)
	local MainColor = Color3.new(1, 0, 0)

	local WindowData = MergeData(Data, ArteMenu.DefaultWindowData)
	local Camera = workspace.CurrentCamera
	local ViewportSize = Camera.ViewportSize
	local ViewportCenterX = ViewportSize.X / 2
	local ViewportCenterY = ViewportSize.Y / 2
	CenterX = ViewportCenterX
	CenterY = ViewportCenterY

	local ScreenGui = CreateScreenGui(1)
	local MainFrame = CreateInstance("Frame", ScreenGui)

	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.new(0, ViewportCenterX, 0, ViewportCenterY)
	MainFrame.Size = UDim2.new(0.5, 0, 0.925, 0)
	MainFrame.BackgroundColor3 = BackgroundColor

	local MainCorner = CreateInstance("UICorner", MainFrame)
	local MainStroke = CreateInstance("UIStroke", MainFrame)

	MainStroke.Color = MainColor
	MainStroke.Thickness = 3
	MainCorner.CornerRadius = UDim.new(0, 15)

	local WindowClosed = false

	task.spawn(function()
		while task.wait() do
			if WindowClosed then
				break
			end
			local CurrentViewportSize = Camera.ViewportSize
			local CurrentCenterX = CurrentViewportSize.X / 2
			local CurrentCenterY = CurrentViewportSize.Y / 2
			if CurrentCenterX ~= CenterX or CurrentCenterY ~= CenterY then
				CenterX = CurrentCenterX
				CenterY = CurrentCenterY
				MainFrame.Position = UDim2.new(0, CurrentCenterX, 0, CurrentCenterY)
			end
		end
	end)

	local VerticalLine = CreateInstance("Frame", MainFrame)
	VerticalLine.BackgroundColor3 = MainColor
	VerticalLine.BorderSizePixel = 0
	VerticalLine.Position = UDim2.new(0.151, 0, 0, 0)
	VerticalLine.Size = UDim2.new(0, 3, 1, 0)

	local HorizontalLine = CreateInstance("Frame", MainFrame)
	HorizontalLine.BackgroundColor3 = MainColor
	HorizontalLine.BorderSizePixel = 0
	HorizontalLine.Position = UDim2.new(0.151, 0, 0.084, 0)
	HorizontalLine.Size = UDim2.new(0.849, 0, 0, 3)

	local DragArea = CreateInstance("TextLabel", MainFrame)
	local IsDragging = false
	local DragStart
	local StartPosition

	DragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			IsDragging = true
			DragStart = input.Position
			StartPosition = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					IsDragging = false
				end
			end)
		end
	end)

	DragArea.BackgroundTransparency = 1
	DragArea.Text = WindowData.Title or "Error! Try closing this menu and running this script again"
	DragArea.Text = ""

	UserInputService.InputChanged:Connect(function(input)
		if not IsDragging then
			return
		end
		if WindowClosed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - DragStart
			MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		end
	end)

	DragArea.TextColor3 = MainColor
	DragArea.TextScaled = true
	DragArea.Size = UDim2.new(0.843, 0, 0.082, 0)
	DragArea.Position = UDim2.new(0.155, 0, 0, 0)

	local TitleLabel = CreateInstance("TextLabel", DragArea)
	TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TitleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	TitleLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
	TitleLabel.Text = WindowData.Title or "Error! Try closing this menu and running this script again"
	TitleLabel.TextColor3 = MainColor
	TitleLabel.TextScaled = true
	TitleLabel.BackgroundTransparency = 1

	local CloseButton = CreateInstance("ImageButton", DragArea)
	CloseButton.AnchorPoint = Vector2.new(1, 0)
	CloseButton.Position = UDim2.new(1, -10, 0, 0)
	CloseButton.Size = UDim2.new(0.083, 0, 1, 0)
	CloseButton.Image = Assets[1]
	CloseButton.BackgroundTransparency = 1

	local CloseButtonAspectRatio = CreateInstance("UIAspectRatioConstraint", CloseButton)

	local CurrentTab = "Main"
	CloseButton.MouseButton1Click:Connect(function()
		WindowClosed = true
		ScreenGui:Destroy()
	end)

	local ContentFrame = CreateInstance("Frame", MainFrame)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Position = UDim2.new(0.166, 0, 0.107, 0)
	ContentFrame.Size = UDim2.new(0.824, 0, 0.873, 0)

	local TabContainer = CreateInstance("Frame", MainFrame)
	TabContainer.Size = UDim2.new(0.129, 0, 0.952, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Position = UDim2.new(0.012, 0, 0.02, 0)

	local TabLayout = CreateInstance("UIListLayout", TabContainer)
	TabLayout.Padding = UDim.new(0, 8)
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local TabCount = 0
	local Tabs = {}

	local function UpdateSelectedTab()

		local SelectedTab = TabContainer:FindFirstChild(CurrentTab)
		if not SelectedTab then
			if CurrentTab == "Main" then
				return
			end
			CurrentTab = "Main"
			return
		end

		for _, Tab in TabContainer:GetChildren() do
			if Tab ~= SelectedTab and Tab:IsA("TextButton") and Tab:FindFirstChildOfClass("TextLabel") then

				Tab:FindFirstChildOfClass("TextLabel").TextColor3 = MainColor
				Tab:FindFirstChildOfClass("TextLabel").Size = UDim2.new(0.85, 0, 0.85, 0)

				local TabFrame = ContentFrame:WaitForChild(Tab.Name)
				TabFrame.Visible = false

			end
		end

		if not SelectedTab:FindFirstChildOfClass("TextLabel") then
			return
		end

		SelectedTab:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.new(1, 1, 1)
		SelectedTab:FindFirstChildOfClass("TextLabel").Size = UDim2.new(0.95, 0, 0.95, 0)

		local TabFrame = ContentFrame:WaitForChild(CurrentTab)
		TabFrame.Visible = true

	end

	function Tabs:AddTab(Name: string)

		TabCount += 1

		local TabButton = CreateInstance("TextButton", TabContainer)
		TabButton.Name = Name
		TabButton.LayoutOrder = TabCount
		TabButton.BackgroundTransparency = 1
		TabButton.Size = UDim2.new(1, 0, 0.072, 0)
		TabButton.Text = ""
		TabButton.TextScaled = true
		TabButton.TextColor3 = MainColor

		local TabLabel = CreateInstance("TextLabel", TabButton)
		TabLabel.Text = Name
		TabLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TabLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
		TabLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.TextScaled = true
		TabLabel.TextColor3 = MainColor

		local TabCorner = CreateInstance("UICorner", TabButton)
		TabButton.MouseButton1Click:Connect(function()
			CurrentTab = Name
			UpdateSelectedTab()
		end)

		TabCorner.CornerRadius = UDim.new(0, 5)

		local TabStroke = CreateInstance("UIStroke", TabButton)
		TabStroke.Thickness = 1.5
		TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		TabStroke.Color = MainColor

		local TabFrame = CreateInstance("ScrollingFrame", ContentFrame)
		TabFrame.Name = Name
		TabFrame.Size = UDim2.new(1, 0, 1, 0)
		TabFrame.BackgroundTransparency = 1
		TabFrame.Visible = false

		local TabFrameList = CreateInstance("UIListLayout", TabFrame)
		TabFrameList.SortOrder = Enum.SortOrder.LayoutOrder
		TabFrameList.Padding = UDim.new(0, 0)

		local Yooos = 0

		Tabs["AddTabText_".. Name] = function(self, Text, Color, Size)

			Yooos += 1

			local TextFrame: Frame = CreateInstance("Frame", TabFrame)
			TextFrame.LayoutOrder = Yooos
			TextFrame.Size = UDim2.new(1, 0, 0, 40 * Size)
			TextFrame.BackgroundTransparency = 1

			local TextLabel: TextLabel = CreateInstance("TextLabel", TextFrame)
			TextLabel.Text = Text
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextColor3 = Color
			TextLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
			TextLabel.TextScaled = true
			TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)

			local ID = Yooos

			Tabs["GetLastID"] = function()
				return ID
			end

			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)

			return Tabs

		end

		Tabs["AddTabEmpty_".. Name] = function(self, Size)

			Yooos += 1

			local frame: Frame = CreateInstance("Frame", TabFrame)
			frame.LayoutOrder = Yooos
			frame.Size = UDim2.new(1, 0, 0, 40 * Size)
			frame.BackgroundTransparency = 1

			local ID = Yooos

			Tabs["GetLastID"] = function()
				return ID
			end

			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)

			return Tabs

		end

		Tabs["AddTabColor_" .. Name] = function(self, Text, DefaultColor, Size)

			Yooos += 1

			local TextFrame: Frame = CreateInstance("Frame", TabFrame)
			TextFrame.LayoutOrder = Yooos
			TextFrame.Size = UDim2.new(1, 0, 0, 40 * Size)
			TextFrame.BackgroundTransparency = 1

			local textColor = DefaultColor
			
			local CurrentColorValue = DefaultColor

			local Inverted = Color3.new(
				1 - textColor.R,
				1 - textColor.G,
				1 - textColor.B
			)

			local isInverted = false

			if textColor == BackgroundColor then
				isInverted = true
				textColor = Inverted
			end

			local TextLabel: TextLabel = CreateInstance("TextLabel", TextFrame)
			TextLabel.Text = Text
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextColor3 = textColor
			TextLabel.Size = UDim2.new(0.7, 0, 0.9, 0)
			TextLabel.TextScaled = true
			TextLabel.Position = UDim2.new(0.01, 0, 0.5, 0)
			TextLabel.AnchorPoint = Vector2.new(0, 0.5)

			local TextButton: TextButton = CreateInstance("TextButton", TextFrame)
			TextButton.Text = ""
			TextButton.Position = UDim2.new(0.9, 0, 0.5, 0)
			TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
			TextButton.Size = UDim2.new(0.8, 0, 0.8, 0)
			TextButton.BackgroundColor3 = DefaultColor
			TextButton.BackgroundTransparency = 0
			TextButton.AutoButtonColor = false

			local Corner = CreateInstance("UICorner", TextButton)
			Corner.CornerRadius = UDim.new(0, 8)

			local Stroke = CreateInstance("UIStroke", TextButton)
			Stroke.Color = Inverted
			Stroke.Thickness = 3
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local Aspect = CreateInstance("UIAspectRatioConstraint", TextButton)
			Aspect.AspectRatio = 1

			local PickerOpen = false
			local PickerFrame = nil

			local function ClosePicker()
				if not PickerFrame then
					return
				end

				local frame = PickerFrame
				PickerFrame = nil
				PickerOpen = false

				local tween = TweenService:Create(
					frame,
					TweenInfo.new(
						0.18,
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.In
					),
					{
						Size = UDim2.fromOffset(0, 0),
						BackgroundTransparency = 1
					}
				)

				tween:Play()

				tween.Completed:Connect(function()
					if frame then
						frame:Destroy()
					end
				end)
			end

			local function OpenPicker()

				if PickerOpen then
					ClosePicker()
					return
				end

				PickerOpen = true

				local ScreenGui2 = TextButton:FindFirstAncestorOfClass("ScreenGui")

				if not ScreenGui2 then
					warn("ColorPicker: ScreenGui2 not found")
					return
				end

				local MousePosition = UserInputService:GetMouseLocation()

				local Popup = CreateInstance("Frame", ScreenGui2)
				PickerFrame = Popup

				Popup.Name = "ColorPicker"
				Popup.AnchorPoint = Vector2.new(0, 0)
				Popup.Position = UDim2.fromOffset(
					MousePosition.X + 12,
					MousePosition.Y + 12
				)

				Popup.Size = UDim2.fromOffset(0, 0)
				Popup.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				Popup.BackgroundTransparency = 1
				Popup.ZIndex = 100

				local PopupCorner = CreateInstance("UICorner", Popup)
				PopupCorner.CornerRadius = UDim.new(0, 12)

				local PopupStroke = CreateInstance("UIStroke", Popup)
				PopupStroke.Color = Color3.fromRGB(70, 70, 80)
				PopupStroke.Thickness = 1
				PopupStroke.Transparency = 1

				local Shadow = CreateInstance("Frame", Popup)
				Shadow.Size = UDim2.new(1, 10, 1, 10)
				Shadow.Position = UDim2.fromOffset(-5, -5)
				Shadow.BackgroundColor3 = Color3.new(0, 0, 0)
				Shadow.BackgroundTransparency = 0.8
				Shadow.ZIndex = 99

				local ShadowCorner = CreateInstance("UICorner", Shadow)
				ShadowCorner.CornerRadius = UDim.new(0, 14)

				local ColorCircle = CreateInstance("ImageButton", Popup)

				ColorCircle.Name = "ColorCircle"
				ColorCircle.Size = UDim2.fromOffset(130, 130)
				ColorCircle.Position = UDim2.fromOffset(12, 12)
				ColorCircle.BackgroundTransparency = 1
				ColorCircle.Image = "rbxassetid://6020299385"
				ColorCircle.ZIndex = 101
				ColorCircle.AutoButtonColor = false

				local CircleAspect = CreateInstance("UIAspectRatioConstraint", ColorCircle)
				CircleAspect.AspectRatio = 1

				local ColorMarker = CreateInstance("Frame", ColorCircle)
				ColorMarker.Name = "Marker"
				ColorMarker.Size = UDim2.fromOffset(10, 10)
				ColorMarker.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorMarker.BackgroundColor3 = Color3.new(1, 1, 1)
				ColorMarker.ZIndex = 103

				local MarkerCorner = CreateInstance("UICorner", ColorMarker)
				MarkerCorner.CornerRadius = UDim.new(1, 0)

				local MarkerStroke = CreateInstance("UIStroke", ColorMarker)
				MarkerStroke.Color = Color3.new(0, 0, 0)
				MarkerStroke.Thickness = 2

				local BrightnessSlider = CreateInstance("Frame", Popup)

				BrightnessSlider.Name = "Brightness"
				BrightnessSlider.Size = UDim2.fromOffset(18, 130)
				BrightnessSlider.Position = UDim2.fromOffset(154, 12)
				BrightnessSlider.BackgroundColor3 = Color3.new(1, 1, 1)
				BrightnessSlider.ZIndex = 101

				local BrightnessCorner = CreateInstance("UICorner", BrightnessSlider)
				BrightnessCorner.CornerRadius = UDim.new(1, 0)

				local BrightnessGradient = CreateInstance("UIGradient", BrightnessSlider)
				BrightnessGradient.Rotation = 90

				BrightnessGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
				})

				local BrightnessButton = CreateInstance("TextButton", BrightnessSlider)
				BrightnessButton.Name = "Handle"
				BrightnessButton.Text = ""
				BrightnessButton.Size = UDim2.fromOffset(24, 8)
				BrightnessButton.AnchorPoint = Vector2.new(0.5, 0.5)
				BrightnessButton.Position = UDim2.new(0.5, 0, 0, 0)
				BrightnessButton.BackgroundColor3 = Color3.new(1, 1, 1)
				BrightnessButton.ZIndex = 103

				local BrightnessHandleCorner = CreateInstance("UICorner", BrightnessButton)
				BrightnessHandleCorner.CornerRadius = UDim.new(1, 0)

				local BrightnessHandleStroke = CreateInstance("UIStroke", BrightnessButton)
				BrightnessHandleStroke.Color = Color3.new(0, 0, 0)
				BrightnessHandleStroke.Thickness = 1

				local CurrentColor = CreateInstance("Frame", Popup)

				CurrentColor.Name = "CurrentColor"
				CurrentColor.Size = UDim2.fromOffset(35, 35)
				CurrentColor.Position = UDim2.fromOffset(195, 60)
				CurrentColor.BackgroundColor3 = CurrentColorValue
				CurrentColor.ZIndex = 102

				local CurrentCorner = CreateInstance("UICorner", CurrentColor)
				CurrentCorner.CornerRadius = UDim.new(0, 8)

				local CurrentStroke = CreateInstance("UIStroke", CurrentColor)
				CurrentStroke.Color = Color3.new(1, 1, 1)
				CurrentStroke.Thickness = 2

				local Hue, Saturation, Value = CurrentColorValue:ToHSV()

				local function UpdateColor()
					
					local NewColor = Color3.fromHSV(
						1 - Hue,
						Saturation,
						Value
					)

					CurrentColorValue = NewColor

					TextButton.BackgroundColor3 = NewColor
					CurrentColor.BackgroundColor3 = NewColor

					local NewInverted = Color3.new(
						1 - NewColor.R,
						1 - NewColor.G,
						1 - NewColor.B
					)

					Stroke.Color = NewInverted

					BrightnessGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(
							0,
							Color3.fromHSV(1 - Hue, Saturation, 1)
						),

						ColorSequenceKeypoint.new(
							1,
							Color3.new(0, 0, 0)
						)
					})

					BrightnessButton.Position = UDim2.new(
						0.5,
						0,
						1 - Value,
						0
					)

					-- Восстанавливаем позицию маркера
					local CircleSize = ColorCircle.AbsoluteSize
					local Radius = math.min(CircleSize.X, CircleSize.Y) / 2

					local Angle = (Hue - 0.5) * math.pi * 2

					local X = CircleSize.X / 2 + math.cos(Angle) * Radius * Saturation
					local Y = CircleSize.Y / 2 + math.sin(Angle) * Radius * Saturation

					ColorMarker.Position = UDim2.fromOffset(X, Y)
				end

				local ColorDragging = false

				local function UpdateCircle(InputPosition)

					local AbsolutePosition = ColorCircle.AbsolutePosition
					local AbsoluteSize = ColorCircle.AbsoluteSize

					local X = InputPosition.X - AbsolutePosition.X
					local Y = InputPosition.Y - AbsolutePosition.Y

					X = math.clamp(X, 0, AbsoluteSize.X)
					Y = math.clamp(Y, 0, AbsoluteSize.Y)

					local CenterX = AbsoluteSize.X / 2
					local CenterY = AbsoluteSize.Y / 2

					local DX = X - CenterX
					local DY = Y - CenterY

					local Distance = math.sqrt(DX * DX + DY * DY)
					local Radius = math.min(CenterX, CenterY)

					if Distance > Radius then
						DX = DX / Distance * Radius
						DY = DY / Distance * Radius

						X = CenterX + DX
						Y = CenterY + DY
					end

					local Angle = math.atan2(DY, DX)

					Hue = (Angle / (math.pi * 2)) + 0.5

					Saturation = math.clamp(Distance / Radius, 0, 1)

					ColorMarker.Position = UDim2.fromOffset(X, Y)

					UpdateColor()
				end

				ColorCircle.InputBegan:Connect(function(Input)

					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch then

						ColorDragging = true
						UpdateCircle(Input.Position)
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)

					if ColorDragging then

						if Input.UserInputType == Enum.UserInputType.MouseMovement
							or Input.UserInputType == Enum.UserInputType.Touch then

							UpdateCircle(Input.Position)
						end
					end
				end)

				UserInputService.InputEnded:Connect(function(Input)

					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch then

						ColorDragging = false
					end
				end)

				local BrightnessDragging = false

				local function UpdateBrightness(InputPosition)

					local AbsolutePosition = BrightnessSlider.AbsolutePosition
					local Height = BrightnessSlider.AbsoluteSize.Y

					local Y = InputPosition.Y - AbsolutePosition.Y

					Y = math.clamp(Y, 0, Height)

					Value = 1 - (Y / Height)

					BrightnessButton.Position = UDim2.new(
						0.5,
						0,
						Y / Height,
						0
					)

					UpdateColor()
				end

				BrightnessSlider.InputBegan:Connect(function(Input)

					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch then

						BrightnessDragging = true
						UpdateBrightness(Input.Position)
					end
				end)

				BrightnessButton.InputBegan:Connect(function(Input)

					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch then

						BrightnessDragging = true
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)

					if BrightnessDragging then

						if Input.UserInputType == Enum.UserInputType.MouseMovement
							or Input.UserInputType == Enum.UserInputType.Touch then

							UpdateBrightness(Input.Position)
						end
					end
				end)

				UserInputService.InputEnded:Connect(function(Input)

					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch then

						BrightnessDragging = false
					end
				end)

				TweenService:Create(
					Popup,
					TweenInfo.new(
						0.22,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.Out
					),
					{
						Size = UDim2.fromOffset(245, 155),
						BackgroundTransparency = 0
					}
				):Play()

				TweenService:Create(
					PopupStroke,
					TweenInfo.new(0.2),
					{
						Transparency = 0
					}
				):Play()

				--UpdateColor()
				
				local CircleSize = ColorCircle.AbsoluteSize
				local Radius = math.min(CircleSize.X, CircleSize.Y) / 2

				local Angle = (1 - Hue - 0.5) * math.pi * 2

				local X = CircleSize.X / 2 + math.cos(Angle) * Radius * Saturation
				local Y = CircleSize.Y / 2 + math.sin(Angle) * Radius * Saturation

				ColorMarker.Position = UDim2.fromOffset(X, Y)
				
			end
			
			UserInputService.InputBegan:Connect(function(Input, GameProcessed)

				if not PickerOpen or not PickerFrame then
					return
				end

				if Input.UserInputType ~= Enum.UserInputType.MouseButton1
					and Input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				local MousePosition = Input.Position
				local Position = PickerFrame.AbsolutePosition
				local Size = PickerFrame.AbsoluteSize

				local IsInside =
					MousePosition.X >= Position.X
					and MousePosition.X <= Position.X + Size.X
					and MousePosition.Y >= Position.Y
					and MousePosition.Y <= Position.Y + Size.Y

				if not IsInside then
					ClosePicker()
				end
			end)

			TextButton.MouseButton1Click:Connect(function()
				OpenPicker()
			end)

			local ID = Yooos

			Tabs["GetLastID"] = function()
				return ID
			end

			Tabs["GetColor_Tab_" .. Name .. "_Id_" .. tostring(ID)] = function()
				return CurrentColorValue
			end
			
			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)

			return Tabs

		end
		
		Tabs["AddTabCheckmark_".. Name] = function(self, Text, Value, TextColor, Size)
			
			Yooos += 1
			
			local MyValue = Value
			
			local TextFrame: Frame = CreateInstance("Frame", TabFrame)
			TextFrame.LayoutOrder = Yooos
			TextFrame.Size = UDim2.new(1, 0, 0, 40 * Size)
			TextFrame.BackgroundTransparency = 1

			local TextLabel: TextLabel = CreateInstance("TextLabel", TextFrame)
			TextLabel.Text = Text
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextColor3 = TextColor
			TextLabel.Size = UDim2.new(0.7, 0, 0.9, 0)
			TextLabel.TextScaled = true
			TextLabel.Position = UDim2.new(0.01, 0, 0.5, 0)
			TextLabel.AnchorPoint = Vector2.new(0, 0.5)

			local TextButton: ImageButton = CreateInstance("ImageButton", TextFrame)
			TextButton.Position = UDim2.new(0.9, 0, 0.5, 0)
			TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
			TextButton.Size = UDim2.new(0.8, 3, 0.8, 3)
			TextButton.BorderSizePixel = 0
			TextButton.BackgroundTransparency = 1
			TextButton.AutoButtonColor = false
			
			local imgEnabled = Assets[2]
			local imgDisabled = Assets[1]

			if MyValue then
				TextButton.Image = imgEnabled
			else
				TextButton.Image = imgDisabled
			end
			
			TextButton.MouseButton1Up:Connect(function()
				
				MyValue = not MyValue
				
				if MyValue then
					TextButton.Image = imgEnabled
				else
					TextButton.Image = imgDisabled
				end
				
			end)

			local Aspect = CreateInstance("UIAspectRatioConstraint", TextButton)
			Aspect.AspectRatio = 1
			
			local ID = Yooos
			Tabs["GetLastID"] = function()
				return ID
			end
			
			Tabs["GetValue_Tab_" .. Name .. "_Id_" .. tostring(ID)] = function()
				return MyValue
			end

			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)
			
			return Tabs
			
		end
		
		Tabs["AddTabSlider_".. Name] = function(self, Text, Value, TextColor, Size)

			Yooos += 1

			local MyValue = Value

			local TextFrame: Frame = CreateInstance("Frame", TabFrame)
			TextFrame.LayoutOrder = Yooos
			TextFrame.Size = UDim2.new(1, 0, 0, 40 * Size)
			TextFrame.BackgroundTransparency = 1

			local TextLabel: TextLabel = CreateInstance("TextLabel", TextFrame)
			TextLabel.Text = Text
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextColor3 = TextColor
			TextLabel.Size = UDim2.new(0.4, 0, 0.9, 0)
			TextLabel.TextScaled = true
			TextLabel.Position = UDim2.new(0.01, 0, 0.5, 0)
			TextLabel.AnchorPoint = Vector2.new(0, 0.5)
			
			local Slider: CanvasGroup = CreateInstance("CanvasGroup", TextFrame)
			Slider.BackgroundColor3 = BackgroundColor
			Slider.Size = UDim2.new(0.55, 0, 0.8, 0)
			Slider.Position = UDim2.new(0.99, 0, 0.5, 0)
			Slider.AnchorPoint = Vector2.new(1, 0.5)
			Slider.ClipsDescendants = true
			
			local Corner = CreateInstance("UICorner", Slider)
			Corner.CornerRadius = UDim.new(0, 8)
			
			local Stroke = CreateInstance("UIStroke", Slider)
			Stroke.Color = MainColor
			Stroke.Thickness = 3
			
			local BG: Frame = CreateInstance("Frame", Slider)
			BG.Size = UDim2.new(1 - MyValue, 0, 1, 0)
			BG.AnchorPoint = Vector2.new(1, 0)
			BG.Position = UDim2.new(1, 0, 0, 0)
			BG.BackgroundColor3 = Color3.new(MainColor.R * 0.5, MainColor.G * 0.5, MainColor.B * 0.5)
			BG.BackgroundTransparency = 0
			BG.BorderSizePixel = 0
			
			local BarFrame: Frame = CreateInstance("Frame", Slider)
			BarFrame.Size = UDim2.new(MyValue, 0, 1, 0)
			BarFrame.AnchorPoint = Vector2.new(0, 0)
			BarFrame.Position = UDim2.new(0, 0, 0, 0)
			BarFrame.BackgroundColor3 = MainColor
			BarFrame.BackgroundTransparency = 0
			BarFrame.BorderSizePixel = 0
			
			local Dragging = false
			
			local function Pressed(what: Frame, input: InputObject)

				local parent = what.Parent

				local MP = input.Position
				local mousePosition = Vector2.new(MP.X, MP.Y)

				local parentPosition = parent.AbsolutePosition
				local parentSize = parent.AbsoluteSize

				local relativePosition = mousePosition - parentPosition

				local SizeX = math.clamp(relativePosition.X / parentSize.X, 0, 1)

				BarFrame.Size = UDim2.new(SizeX, 0, 1, 0)
				BG.Size = UDim2.new(1 - SizeX, 0, 1, 0)
				
				MyValue = SizeX

			end
			
			BG.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
					Pressed(BG, input)
				end
			end)

			BarFrame.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
					Pressed(BarFrame, input)
				end
			end)

			BG.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
					Pressed(BarFrame, input)
				end
			end)

			BarFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
					Pressed(BarFrame, input)
				end
			end)

			BG.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)

			BarFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)

			local ID = Yooos
			Tabs["GetLastID"] = function()
				return ID
			end

			Tabs["GetValue_Tab_" .. Name .. "_Id_" .. tostring(ID)] = function()
				return MyValue
			end
			
			task.spawn(function()
				while not WindowClosed do
					
					task.wait(0.1)
					
					Stroke.Color = MainColor
					BarFrame.BackgroundColor3 = MainColor
					BG.BackgroundColor3 = Color3.new(MainColor.R * 0.5, MainColor.G * 0.5, MainColor.B * 0.5)
					
				end
			end)

			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)

			return Tabs

		end
		
		Tabs["AddTabKeybind_".. Name] = function(self, Text, Keybind, TextColor, Size)

			Yooos += 1

			local MyValue: Enum.KeyCode = Keybind

			local TextFrame: Frame = CreateInstance("Frame", TabFrame)
			TextFrame.LayoutOrder = Yooos
			TextFrame.Size = UDim2.new(1, 0, 0, 40 * Size)
			TextFrame.BackgroundTransparency = 1

			local TextLabel: TextLabel = CreateInstance("TextLabel", TextFrame)
			TextLabel.Text = Text
			TextLabel.BackgroundTransparency = 1
			TextLabel.TextColor3 = TextColor
			TextLabel.Size = UDim2.new(0.4, 0, 0.9, 0)
			TextLabel.TextScaled = true
			TextLabel.Position = UDim2.new(0.01, 0, 0.5, 0)
			TextLabel.AnchorPoint = Vector2.new(0, 0.5)

			local frame: TextButton = CreateInstance("TextButton", TextFrame)
			frame.BackgroundColor3 = BackgroundColor
			frame.Size = UDim2.new(0.4, 0, 0.8, 0)
			frame.Position = UDim2.new(0.92, 0, 0.5, 0)
			frame.AnchorPoint = Vector2.new(1, 0.5)
			frame.ClipsDescendants = true
			frame.Text = MyValue.Name
			frame.TextColor3 = MainColor
			frame.TextScaled = true

			local Corner = CreateInstance("UICorner", frame)
			Corner.CornerRadius = UDim.new(0, 8)

			local Stroke = CreateInstance("UIStroke", frame)
			Stroke.Color = MainColor
			Stroke.Thickness = 3
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			local ChangingValue = false

			local ID = Yooos
			Tabs["GetLastID"] = function()
				return ID
			end

			Tabs["GetKeybind_Tab_" .. Name .. "_Id_" .. tostring(ID)] = function()
				return MyValue
			end
			
			frame.MouseButton1Up:Connect(function()
				ChangingValue = true
			end)
			
			UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode ~= Enum.KeyCode.None and ChangingValue then
					MyValue = input.KeyCode
					ChangingValue = false
				end
			end)

			task.spawn(function()
				while not WindowClosed do

					task.wait(0.1)

					Stroke.Color = MainColor
					frame.BackgroundColor3 = BackgroundColor
					frame.TextColor3 = MainColor
					
					if not ChangingValue then
						frame.Text = MyValue.Name
					else
						frame.Text = "PRESS KEY"
					end

				end
			end)

			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)

			return Tabs

		end

		return Tabs

	end

	Tabs = Tabs:AddTab("Main")
		:AddTabText_Main("Welcome to this menu!", Color3.new(1, 1, 1), 1)
		:AddTabText_Main("You can use other tabs", Color3.new(1, 1, 1), 0.5)
		:AddTabEmpty_Main(1)
		:AddTabText_Main("Module for making menus like that was made by: ArteGames", Color3.new(0.5, 0.5, 0.5), 1.5)
		:AddTabEmpty_Main(1)
		:AddTabText_Main("Description", Color3.new(1, 1, 1), 1)
		:AddTabText_Main(WindowData.Description, Color3.new(1, 1, 1), 0.5)
		:AddTabEmpty_Main(1)
		:AddTabText_Main("Authors", Color3.new(1, 1, 1), 1)
	
	for _, v in WindowData.Authors do
		Tabs = Tabs:AddTabText_Main(v, Color3.new(1, 1, 1), 0.5)
	end
	
	Tabs = Tabs:AddTabEmpty_Main(1)
		:AddTabText_Main("Version: ".. WindowData.Version, Color3.new(1, 1, 1), 0.5)
	
	local KeybindToCloseWindow = Enum.KeyCode.RightControl
	local InitClosing = false

	function Tabs:AddConfigTab()

		Tabs = Tabs:AddTab("Config")

		Tabs = Tabs:AddTabColor_Config("Main color", MainColor, 1)
		local ID1 = Tabs.GetLastID()

		Tabs = Tabs:AddTabColor_Config("Background color", BackgroundColor, 1)
		local ID2 = Tabs.GetLastID()

		Tabs = Tabs:AddTabKeybind_Config("Hide and Show", KeybindToCloseWindow, Color3.new(1, 1, 1), 1)
		local ID3 = Tabs.GetLastID()

		task.spawn(function()
			while not WindowClosed do

				task.wait(0.1)

				local MC = Tabs["GetColor_Tab_Config_Id_".. tostring(ID1)]()
				local BC = Tabs["GetColor_Tab_Config_Id_".. tostring(ID2)]()
				local Keybind = Tabs["GetKeybind_Tab_Config_Id_".. tostring(ID3)]()

				if MC then

					MainColor = MC

					MainStroke.Color = MainColor
					VerticalLine.BackgroundColor3 = MainColor
					HorizontalLine.BackgroundColor3 = MainColor
					DragArea.TextColor3 = MainColor
					TitleLabel.TextColor3 = MainColor

				end

				if BC then
					BackgroundColor = BC
					MainFrame.BackgroundColor3 = BackgroundColor
				end

				if Keybind and KeybindToCloseWindow ~= Keybind then
					KeybindToCloseWindow = Keybind
				end

			end
		end)

		return Tabs

	end

	if InitClosing == false then

		InitClosing = true

		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == KeybindToCloseWindow and not WindowClosed then
				ScreenGui.Enabled = not ScreenGui.Enabled
			end
		end)

	end

	task.spawn(function()
		while not WindowClosed do
			UpdateSelectedTab()
			task.wait(0.1)
		end
	end)

	return Tabs

end

return ArteMenu
