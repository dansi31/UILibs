-- Nova UI Library | Luau
local TweenService = game:GetService('TweenService')
local UIS = game:GetService('UserInputService')
local Players = game:GetService('Players')

local Library = {}
local C = {
    bg = Color3.fromRGB(18,18,24), side = Color3.fromRGB(24,24,33),
    element = Color3.fromRGB(33,33,45), accent = Color3.fromRGB(125,95,255),
    text = Color3.fromRGB(240,240,250), muted = Color3.fromRGB(150,150,170)
}
local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o,r) make('UICorner',{CornerRadius=UDim.new(0,r or 8)},o) end
local function animate(o,props)
    TweenService:Create(o,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end
local function parentGui()
    if type(gethui)=='function' then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local ok, core = pcall(function() return game:GetService('CoreGui') end)
    if ok and core then return core end
    return Players.LocalPlayer:WaitForChild('PlayerGui')
end
function Library.new(config)
    config = config or {}
    local old = parentGui():FindFirstChild(config.Name or 'NovaUI')
    if old then old:Destroy() end
    local gui = make('ScreenGui',{Name=config.Name or 'NovaUI',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parentGui())
    local window = make('Frame',{Size=UDim2.fromOffset(540,355),Position=UDim2.new(.5,-270,.5,-177),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true},gui)
    corner(window,11)
    local header = make('Frame',{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.side,BorderSizePixel=0},window)
    make('TextLabel',{Size=UDim2.new(1,-95,1,0),Position=UDim2.fromOffset(14,0),BackgroundTransparency=1,Text=config.Title or 'Nova UI',TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},header)
    local minimize = make('TextButton',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-68,0,9),Text='−',TextSize=20,Font=Enum.Font.GothamBold,TextColor3=C.text,BackgroundColor3=C.element,BorderSizePixel=0},header)
    corner(minimize,7)
    local close = make('TextButton',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-35,0,9),Text='×',TextSize=20,Font=Enum.Font.GothamBold,TextColor3=C.text,BackgroundColor3=C.element,BorderSizePixel=0},header)
    corner(close,7)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        minimize.Text = minimized and '+' or '−'
        animate(window,{Size=minimized and UDim2.fromOffset(540,46) or UDim2.fromOffset(540,355)})
    end)
    local dragging, dragInput, dragStart, startPos = false,nil,nil,nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging=true; dragInput=input; dragStart=input.Position; startPos=window.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging=false end end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput=input end
    end)
    local dragConnection = UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta=input.Position-dragStart
            window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    gui.Destroying:Connect(function() dragConnection:Disconnect() end)
    local sidebar = make('Frame',{Position=UDim2.fromOffset(0,46),Size=UDim2.new(0,140,1,-46),BackgroundColor3=C.side,BorderSizePixel=0},window)
    local tabs = make('Frame',{Position=UDim2.fromOffset(8,10),Size=UDim2.new(1,-16,1,-20),BackgroundTransparency=1},sidebar)
    make('UIListLayout',{Padding=UDim.new(0,6)},tabs)
    local content = make('Frame',{Position=UDim2.fromOffset(151,56),Size=UDim2.new(1,-162,1,-66),BackgroundTransparency=1},window)
    local api={Gui=gui,Window=window,Tabs={}}
    function api:SetMinimized(value)
        if minimized == value then return end
        minimized=value
        minimize.Text=minimized and '+' or '−'
        animate(window,{Size=minimized and UDim2.fromOffset(540,46) or UDim2.fromOffset(540,355)})
    end
    api.Minimize = function(self,value) self:SetMinimized(value == nil and not minimized or value) end
    function api:CreateTab(name)
        local button=make('TextButton',{Size=UDim2.new(1,0,0,34),Text='  '..name,TextXAlignment=Enum.TextXAlignment.Left,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.muted,BackgroundColor3=C.side,BorderSizePixel=0,AutoButtonColor=false},tabs)
        corner(button,7)
        local page=make('ScrollingFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},content)
        make('UIListLayout',{Padding=UDim.new(0,9)},page)
        make('UIPadding',{PaddingRight=UDim.new(0,5),PaddingBottom=UDim.new(0,5)},page)
        local tab={Button=button,Page=page}
        local function selectTab()
            for _,item in ipairs(api.Tabs) do
                item.Page.Visible=false
                animate(item.Button,{BackgroundColor3=C.side,TextColor3=C.muted})
            end
            page.Visible=true
            animate(button,{BackgroundColor3=C.element,TextColor3=C.text})
        end
        button.MouseButton1Click:Connect(selectTab)
        function tab:CreateSection(title)
            local section=make('Frame',{Size=UDim2.new(1,-2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.side,BorderSizePixel=0},page)
            corner(section,8)
            make('UIPadding',{PaddingTop=UDim.new(0,9),PaddingBottom=UDim.new(0,9),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},section)
            make('UIListLayout',{Padding=UDim.new(0,7)},section)
            make('TextLabel',{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=title,TextColor3=C.accent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},section)
            local s={}
            function s:CreateToggle(opts)
                opts=opts or {}
                local enabled=opts.CurrentValue == true
                local row=make('TextButton',{Size=UDim2.new(1,0,0,37),Text='',BackgroundColor3=C.element,BorderSizePixel=0,AutoButtonColor=false},section)
                corner(row,7)
                make('TextLabel',{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-62,1,0),BackgroundTransparency=1,Text=opts.Name or 'Toggle',TextColor3=C.text,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},row)
                local track=make('Frame',{Size=UDim2.fromOffset(34,18),Position=UDim2.new(1,-43,.5,-9),BackgroundColor3=enabled and C.accent or C.muted,BorderSizePixel=0},row)
                corner(track,9)
                local knob=make('Frame',{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(enabled and 18 or 2,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track)
                corner(knob,7)
                local toggle={}
                function toggle:Set(value)
                    enabled=value == true
                    animate(track,{BackgroundColor3=enabled and C.accent or C.muted})
                    animate(knob,{Position=UDim2.fromOffset(enabled and 18 or 2,2)})
                    if opts.Callback then task.spawn(opts.Callback,enabled) end
                end
                function toggle:Get() return enabled end
                row.MouseButton1Click:Connect(function() toggle:Set(not enabled) end)
                return toggle
            end
            function s:CreateButton(opts)
                opts=opts or {}
                local b=make('TextButton',{Size=UDim2.new(1,0,0,36),Text=opts.Name or 'Button',TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamMedium,BackgroundColor3=C.element,BorderSizePixel=0,AutoButtonColor=false},section)
                corner(b,7)
                b.MouseEnter:Connect(function() animate(b,{BackgroundColor3=C.accent}) end)
                b.MouseLeave:Connect(function() animate(b,{BackgroundColor3=C.element}) end)
                b.MouseButton1Click:Connect(function() if opts.Callback then task.spawn(opts.Callback) end end)
                return b
            end
            return s
        end
        table.insert(api.Tabs,tab)
        if #api.Tabs == 1 then selectTab() end
        return tab
    end
    return api
end
return Library
