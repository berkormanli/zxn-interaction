
--///////////////////////////////////////--
MenuPool = setmetatable({}, MenuPool)
MenuPool.__index = MenuPool

---New
function MenuPool.New()
    local _MenuPool = {
        Menus = {},
        PauseMenus = {}
    }
    return setmetatable(_MenuPool, MenuPool)
end

---AddSubMenu
---@param Menu table
---@param Text string
---@param Description string
---@param KeepPosition boolean
---@param KeepBanner boolean
function MenuPool:AddSubMenu(Menu, Text, Description, KeepPosition, KeepBanner)
    if Menu() == "UIMenu" then
        local Item = UIMenuItem.New(tostring(Text), Description or "")
        Menu:AddItem(Item)
        local SubMenu
        if KeepPosition then
            SubMenu = UIMenu.New(Menu.Title, Text, Menu.Position.X, Menu.Position.Y, Menu.Glare, Menu.TextureDict, Menu.TextureName, Menu.AlternativeTitle)
        else
            SubMenu = UIMenu.New(Menu.Title, Text)
        end
        if KeepBanner then
            if Menu.Logo ~= nil then
                SubMenu.Logo = Menu.Logo
            else
                SubMenu.Logo = nil
                SubMenu.Banner = Menu.Banner
            end
        end

        SubMenu.Glare = Menu.Glare
        SubMenu.Settings.MouseControlsEnabled = Menu.Settings.MouseControlsEnabled
        SubMenu.Settings.MouseEdgeEnabled = Menu.Settings.MouseEdgeEnabled
        SubMenu:MaxItemsOnScreen(Menu:MaxItemsOnScreen())
        self:Add(SubMenu)
        Menu:BindMenuToItem(SubMenu, Item)
        return SubMenu
    end
end

---Add
---@param Menu table
function MenuPool:Add(Menu)
    if Menu() == "UIMenu" then
        Menu.pool = self
        table.insert(self.Menus, Menu)
    end
end

function MenuPool:AddPauseMenu(Menu)
    if Menu() == "PauseMenu" then
        table.insert(self.PauseMenus, Menu)
    end
end

---MouseEdgeEnabled
---@param bool boolean
function MenuPool:MouseEdgeEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MouseEdgeEnabled = tobool(bool)
        end
    end
end

---ControlDisablingEnabled
---@param bool boolean
function MenuPool:ControlDisablingEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.ControlDisablingEnabled = tobool(bool)
        end
    end
end

---ResetCursorOnOpen
---@param bool boolean
function MenuPool:ResetCursorOnOpen(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.ResetCursorOnOpen = tobool(bool)
        end
    end
end

---MultilineFormats
---@param bool boolean
function MenuPool:MultilineFormats(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MultilineFormats = tobool(bool)
        end
    end
end

---Audio
---@param Attribute number
---@param Setting table
function MenuPool:Audio(Attribute, Setting)
    if Attribute ~= nil and Setting ~= nil then
        for _, Menu in pairs(self.Menus) do
            if Menu.Settings.Audio[Attribute] then
                Menu.Settings.Audio[Attribute] = Setting
            end
        end
    end
end

---WidthOffset
---@param offset number
function MenuPool:WidthOffset(offset)
    if tonumber(offset) then
        for _, Menu in pairs(self.Menus) do
            Menu:SetMenuWidthOffset(tonumber(offset))
        end
    end
end

---CounterPreText
---@param str string
function MenuPool:CounterPreText(str)
    if str ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.PageCounter.PreText = tostring(str)
        end
    end
end

---DisableInstructionalButtons
---@param bool boolean
function MenuPool:DisableInstructionalButtons(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.InstructionalButtons = tobool(bool)
        end
    end
end

---MouseControlsEnabled
---@param bool boolean
function MenuPool:MouseControlsEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.Menus) do
            Menu.Settings.MouseControlsEnabled = tobool(bool)
        end
    end
end

---RefreshIndex
function MenuPool:RefreshIndex()
    for _, Menu in pairs(self.Menus) do
        Menu:RefreshIndex()
    end
end

---ProcessControl
function MenuPool:ProcessControl()
    for _, Menu in pairs(self.Menus) do
        if Menu:Visible() then
            Menu:ProcessControl()
            Menu:ProcessMouse()
        end
    end

    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            Menu:ProcessControl()
        end
    end
end

---Draw
function MenuPool:Draw()
    for _, Menu in pairs(self.Menus) do
        if Menu:Visible() then
            Menu:Draw()
        end
    end
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            Menu:Draw()
        end
    end
end

---IsAnyMenuOpen
function MenuPool:IsAnyMenuOpen()
    for _, Menu in pairs(self.Menus) do
        if #Menu.Children > 0 then
            for k,v in pairs(Menu.Children) do
                if v:Visible() then
                    return true
                end
            end
        end
        if Menu:Visible() then
            return true
        end
    end
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            return true
        end
    end
    return false
end

function MenuPool:IsAnyPauseMenuOpen()
    for _, Menu in pairs(self.PauseMenus) do
        if Menu:Visible() then
            return true
        end
    end
    return false
end

---CloseAllMenus
function MenuPool:CloseAllMenus()
    if self.currentMenu ~= nil and self.currentMenu() == "UIMenu" then
        for _,subMenu in pairs(self.currentMenu.Children) do
            if subMenu:Visible() then
                subMenu:Visible(false)
            end
        end
        if self.currentMenu:Visible() then
            self.currentMenu:Visible(false)
        else
            self.currentMenu.OnMenuChanged(self.currentMenu, nil, "closed")
        end
    end
    ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
    if ScaleformUI.Scaleforms.InstructionalButtons:Enabled() then
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
    end
end

---SetBannerSprite
---@param Sprite table
function MenuPool:SetBannerSprite(Sprite)
    if Sprite() == "Sprite" then
        for _, Menu in pairs(self.Menus) do
            Menu:SetBannerSprite(Sprite)
        end
    end
end

---SetBannerRectangle
---@param Rectangle table
function MenuPool:SetBannerRectangle(Rectangle)
    if Rectangle() == "Rectangle" then
        for _, Menu in pairs(self.Menus) do
            Menu:SetBannerRectangle(Rectangle)
        end
    end
end



--///////////////////////////////////////--
UIMenu = setmetatable({}, UIMenu)
UIMenu.__index = UIMenu
UIMenu.__call = function()
    return "UIMenu"
end

---New
---@param Title string
---@param Subtitle string
---@param X number
---@param Y number
---@param TxtDictionary string
---@param TxtName string
---@param AlternativeTitle boolean
function UIMenu.New(Title, Subtitle, X, Y, glare, txtDictionary, txtName, alternativeTitle)
    local X, Y = tonumber(X) or 0, tonumber(Y) or 0
    if Title ~= nil then
        Title = tostring(Title) or ""
    else
        Title = ""
    end
    if Subtitle ~= nil then
        Subtitle = tostring(Subtitle) or ""
    else
        Subtitle = ""
    end
    if txtDictionary ~= nil then
        txtDictionary = tostring(txtDictionary) or "commonmenu"
    else
        txtDictionary = "commonmenu"
    end
    if txtName ~= nil then
        txtName = tostring(txtName) or "interaction_bgd"
    else
        txtName = "interaction_bgd"
    end
    if alternativeTitle == nil then
        alternativeTitle = false
    else
        alternativeTitle = alternativeTitle
    end
    local _UIMenu = {
        Title = Title,
        Subtitle = Subtitle,
        AlternativeTitle = alternativeTitle,
        Position = { X = X, Y = Y },
        Pagination = { Min = 0, Max = 7, Total = 7 },
        enableAnimation = true,
        animationType = 0,
        Extra = {},
        Description = {},
        Items = {},
        Windows = {},
        Children = {},
        TxtDictionary = txtDictionary,
        TxtName = txtName,
        Glare = glare or false,
        pool = nil,
        _keyboard = false,
        _changed = false,
        _maxItem = 7,
        _menuGlare = 0,
        _time = 0,
        _times = 0,
        _delay = 150,
        _scaledWidth = (720 * GetScreenAspectRatio(false)),
        Controls = {
            Back = {
                Enabled = true,
            },
            Select = {
                Enabled = true,
            },
            Left = {
                Enabled = true,
            },
            Right = {
                Enabled = true,
            },
            Up = {
                Enabled = true,
            },
            Down = {
                Enabled = true,
            },
        },
        ParentMenu = nil,
        ParentItem = nil,
        _Visible = false,
        ActiveItem = 0,
        Dirty = false,
        ReDraw = true,
        InstructionalButtons = {
            InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 176, 176, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1)
        },
        OnIndexChange = function(menu, newindex)
        end,
        OnListChange = function(menu, list, newindex)
        end,
        OnSliderChange = function(menu, slider, newindex)
        end,
        OnProgressChange = function(menu, progress, newindex)
        end,
        OnCheckboxChange = function(menu, item, checked)
        end,
        OnListSelect = function(menu, list, index)
        end,
        OnSliderSelect = function(menu, slider, index)
        end,
        OnProgressSelect = function(menu, progress, index)
        end,
        OnItemSelect = function(menu, item, index)
        end,
        OnMenuChanged = function(oldmenu, newmenu, change)
        end,
        OnColorPanelChanged = function(oldmenu, newmenu, change)
        end,
        OnPercentagePanelChanged = function(oldmenu, newmenu, change)
        end,
        OnGridPanelChanged = function(oldmenu, newmenu, change)
        end,
        Settings = {
            InstructionalButtons = true,
            MultilineFormats = true,
            ScaleWithSafezone = true,
            ResetCursorOnOpen = true,
            MouseControlsEnabled = true,
            MouseEdgeEnabled = true,
            ControlDisablingEnabled = true,
            Audio = {
                Library = "HUD_FRONTEND_DEFAULT_SOUNDSET",
                UpDown = "NAV_UP_DOWN",
                LeftRight = "NAV_LEFT_RIGHT",
                Select = "SELECT",
                Back = "BACK",
                Error = "ERROR",
            },
            EnabledControls = {
                Controller = {
                    { 0, 2 }, -- Look Up and Down
                    { 0, 1 }, -- Look Left and Right
                    { 0, 25 }, -- Aim
                    { 0, 24 }, -- Attack
                },
                Keyboard = {
                    { 0, 201 }, -- Select
                    { 0, 195 }, -- X axis
                    { 0, 196 }, -- Y axis
                    { 0, 187 }, -- Down
                    { 0, 188 }, -- Up
                    { 0, 189 }, -- Left
                    { 0, 190 }, -- Right
                    { 0, 202 }, -- Back
                    { 0, 217 }, -- Select
                    { 0, 242 }, -- Scroll down
                    { 0, 241 }, -- Scroll up
                    { 0, 239 }, -- Cursor X
                    { 0, 240 }, -- Cursor Y
                    { 0, 31 }, -- Move Up and Down
                    { 0, 30 }, -- Move Left and Right
                    { 0, 21 }, -- Sprint
                    { 0, 22 }, -- Jump
                    { 0, 23 }, -- Enter
                    { 0, 75 }, -- Exit Vehicle
                    { 0, 71 }, -- Accelerate Vehicle
                    { 0, 72 }, -- Vehicle Brake
                    { 0, 59 }, -- Move Vehicle Left and Right
                    { 0, 89 }, -- Fly Yaw Left
                    { 0, 9 }, -- Fly Left and Right
                    { 0, 8 }, -- Fly Up and Down
                    { 0, 90 }, -- Fly Yaw Right
                    { 0, 76 }, -- Vehicle Handbrake
                },
            },
        }
    }

    if Subtitle ~= "" and Subtitle ~= nil then
        _UIMenu.Subtitle = Subtitle
    end
    if(_UIMenu._menuGlare == 0)then
        _UIMenu._menuGlare = Scaleform.Request("mp_menu_glare")
    end
    return setmetatable(_UIMenu, UIMenu)
end

---DisEnableControls
---@param bool boolean
function UIMenu:DisEnableControls(bool)
    if bool then
        EnableAllControlActions(2)
    else
        DisableAllControlActions(2)
    end

    if bool then
        return
    else
        if not IsInputDisabled(2) then
            for Index = 1, #self.Settings.EnabledControls.Controller do
                EnableControlAction(self.Settings.EnabledControls.Controller[Index][1], self.Settings.EnabledControls.Controller[Index][2], true)
            end
        else
            for Index = 1, #self.Settings.EnabledControls.Keyboard do
                EnableControlAction(self.Settings.EnabledControls.Keyboard[Index][1], self.Settings.EnabledControls.Keyboard[Index][2], true)
            end
        end
    end
end

---InstructionalButtons
---@param bool boolean
function UIMenu:InstructionalButtons(bool)
    if bool ~= nil then
        self.Settings.InstructionalButtons = tobool(bool)
    end
end

---SetBannerSprite
---@param Sprite string
---@param IncludeChildren boolean
function UIMenu:SetBannerSprite(Sprite, IncludeChildren)
    if Sprite() == "Sprite" then
        self.Logo = Sprite
        self.Logo:Size(431 + self.WidthOffset, 107)
        self.Logo:Position(self.Position.X, self.Position.Y)
        self.Banner = nil
        if IncludeChildren then
            for Item, Menu in pairs(self.Children) do
                Menu.Logo = Sprite
                Menu.Logo:Size(431 + self.WidthOffset, 107)
                Menu.Logo:Position(self.Position.X, self.Position.Y)
                Menu.Banner = nil
            end
        end
    end
end

function UIMenu:AnimationEnabled(enable)
    if enable ~= nil then
        self.enableAnimation = enable
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_SCROLLING_ANIMATION", false, enable)
        end
    else
        return self.enableAnimation
    end
end

function UIMenu:AnimationType(animType)
    if animType ~= nil then
        self.animationType = animType
        if self:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("CHANGE_SCROLLING_ANIMATION_TYPE", false, animType)
        end
    else
        return self.animationType
    end
end

---CurrentSelection
---@param value number
function UIMenu:CurrentSelection(value)
    if tonumber(value) then
        if #self.Items == 0 then
            self.ActiveItem = 0
        end
        self.Items[self:CurrentSelection()]:Selected(false)
        self.ActiveItem = 1000000 - (1000000 % #self.Items) + tonumber(value)
        self.Items[self:CurrentSelection()]:Selected(true)
        ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self:CurrentSelection())
    else
        if #self.Items == 0 then
            return 1
        else
            if self.ActiveItem % #self.Items == 0 then
                return 1
            else
                return (self.ActiveItem % #self.Items) + 1
            end
        end
    end
end

---AddWindow
---@param Window table
function UIMenu:AddWindow(Window)
    if Window() == "UIMenuWindow" then
        Window:SetParentMenu(self)
        table.insert(self.Windows, Window)
    end
end

---RemoveWindowAt
---@param Index table
function UIMenu:RemoveWindowAt(Index)
    if tonumber(Index) then
        if self.Windows[Index] then
            table.remove(self.Windows, Index)
        end
    end
end

---AddItem
---@param Item table
function UIMenu:AddItem(Item)
    if Item() == "UIMenuItem" then
        Item:SetParentMenu(self)
        table.insert(self.Items, Item)
    end
end

---RemoveItemAt
---@param Index table
function UIMenu:RemoveItemAt(Index)
    if tonumber(Index) then
        if self.Items[Index] then
            local SelectedItem = self:CurrentSelection()
            table.remove(self.Items, tonumber(Index))
            if self:Visible() then
                ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_ITEM", false, Index - 1) -- scaleform index starts at 0, better remove 1 to the index
            end
            self:CurrentSelection(SelectedItem)
        end
    end
end

function UIMenu:RemoveItem(item)
    local idx = 0
    for k,v in pairs(self.Items)do
        if v:Label() == item:Label() then
            idx = k
        end
    end
    if idx > 0 then
        self:RemoveItemAt(idx)
    end
end

---RefreshIndex
function UIMenu:RefreshIndex()
    if #self.Items == 0 then
        self.ActiveItem = 0
        self.Pagination.Max = self.Pagination.Total + 1
        self.Pagination.Min = 0
        return
    end
    self.Items[self:CurrentSelection()]:Selected(false)
    self.ActiveItem = 1000 - (1000 % #self.Items)
    self.Pagination.Max = self.Pagination.Total + 1
    self.Pagination.Min = 0
end

---Clear
function UIMenu:Clear()
    self.Items = {}
end

function UIMenu:MaxItemsOnScreen(max)
    if max ~= nil then
        self._maxItem = max
        self:RefreshIndex()
    else
        return self._maxItem
    end
end

function UIMenu:AddSubMenu(Menu, text, description, offset, KeepBanner)
    if Menu() == "UIMenu" then
        local Item = UIMenuItem.New(tostring(text), description or "")
        self:AddItem(Item)
        if offset == nil then
            Menu.Position = self.Position
        else
            Menu.Position = offset
        end
        if KeepBanner then
            if self.Logo ~= nil then
                Menu.Logo = self.Logo
            else
                Menu.Logo = nil
                Menu.Banner = self.Banner
            end
        end
        Menu.Glare = self.Glare
        Menu.Settings.MouseControlsEnabled = self.Settings.MouseControlsEnabled
        Menu.Settings.MouseEdgeEnabled = self.Settings.MouseEdgeEnabled
        Menu:MaxItemsOnScreen(self:MaxItemsOnScreen())
        self.pool:Add(Menu)
        self:BindMenuToItem(Menu, Item)
        return Menu
    end
end

---Visible
---@param bool boolean
function UIMenu:Visible(bool)
    if bool ~= nil then
        self._Visible = tobool(bool)
        self.JustOpened = tobool(bool)
        self.Dirty = tobool(bool)

        if self.ParentMenu ~= nil then return end

        if #self.Children > 0 and self.Children[self.Items[self:CurrentSelection()]] ~= nil and self.Children[self.Items[self:CurrentSelection()]]:Visible() then return end
        if bool then
            ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.InstructionalButtons)
            self.OnMenuChanged(nil, self, "opened")
            self:BuildUpMenu()
            self.pool.currentMenu = self
        else
            self.OnMenuChanged(self, nil, "closed")
            ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
            self.pool.currentMenu = nil
        end
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(bool)
        if self.Settings.ResetCursorOnOpen then
            local W, H = GetScreenResolution()
            SetCursorLocation(W / 2, H / 2)
        end
    else
        return self._Visible
    end
end

---BuildUpMenu
function UIMenu:BuildUpMenu()
    while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
    ScaleformUI.Scaleforms._ui:CallFunction("CREATE_MENU", false, self.Title, self.Subtitle, 0, 0, self.AlternativeTitle, self.TxtDictionary, self.TxtName,self:MaxItemsOnScreen(), true, 1)
    if #self.Windows > 0 then
        for w_id, window in pairs (self.Windows) do
            local Type, SubType = window()
            if SubType == "UIMenuHeritageWindow" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.Mom, window.Dad)
            elseif SubType == "UIMenuDetailsWindow" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_WINDOW", false, window.id, window.DetailBottom, window.DetailMid, window.DetailTop, window.DetailLeft.Txd, window.DetailLeft.Txn, window.DetailLeft.Pos.x, window.DetailLeft.Pos.y, window.DetailLeft.Size.x, window.DetailLeft.Size.y)
                if window.StatWheelEnabled then
                    for key, value in pairs(window.DetailStats) do
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false, window.id, value.Percentage, value.HudColor)
                    end
                end
            end
        end
    end
    local timer = GetGameTimer()
    if #self.Items == 0 then
        while #self.Items == 0 do
            Citizen.Wait(0)
            if GetGameTimer() - timer > 150 then
                self.ActiveItem = 0
                ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self.ActiveItem)
                return
            end
        end
    end
    for it, item in pairs (self.Items) do
        local Type, SubType = item()
        AddTextEntry("desc_{" .. it .."}", item:Description())

        if SubType == "UIMenuListItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), table.concat(item.Items, ","), item:Index()-1, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
        elseif SubType == "UIMenuDynamicListItem" then -- dynamic list item are handled like list items in the scaleform.. so the type remains 1
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 1, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item:CurrentListItem(), 0, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
        elseif SubType == "UIMenuCheckboxItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 2, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item.CheckBoxStyle, item._Checked, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
        elseif SubType == "UIMenuSliderItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 3, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(), item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor, item._heritage)
        elseif SubType == "UIMenuProgressItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 4, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item._Max, item._Multiplier, item:Index(), item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor, item.SliderColor)
        elseif SubType == "UIMenuStatsItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 5, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item:Index(), item._Type, item._Color, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
        elseif SubType == "UIMenuSeperatorItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 6, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item.Jumpable, item.Base._mainColor, item.Base._highlightColor, item.Base._textColor, item.Base._highlightedTextColor)
        else
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", false, 0, item:Label(), "desc_{" .. it .."}", item:Enabled(), item:BlinkDescription(), item._mainColor, item._highlightColor, item._textColor, item._highlightedTextColor)
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", false, it - 1, item:RightLabel())
            if item._rightBadge ~= BadgeStyle.NONE then
                ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", false, it - 1, item._rightBadge)
            end
        end
        
        if (SubType == "UIMenuItem" and item._leftBadge ~= BadgeStyle.NONE) or (SubType ~= "UIMenuItem" and item.Base._leftBadge ~= BadgeStyle.NONE) then
            if SubType ~= "UIMenuItem" then
                ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item.Base._leftBadge)
            else
                ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, it - 1, item._leftBadge)
            end
        end
        if #item.Panels > 0 then
            for pan, panel in pairs (item.Panels) do
                local pType, pSubType = panel()
                if pSubType == "UIMenuColorPanel" then
                    if panel.CustomColors ~= nil then
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title, panel.ColorPanelColorType, panel.value, table.concat(panel.CustomColors, ","))
                    else
                        ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 0, panel.Title, panel.ColorPanelColorType, panel.value)
                    end
                elseif pSubType == "UIMenuPercentagePanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 1, panel.Title, panel.Min, panel.Max, panel.Percentage)
                elseif pSubType == "UIMenuGridPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 2, panel.TopLabel, panel.RightLabel, panel.LeftLabel, panel.BottomLabel, panel.CirclePosition.x, panel.CirclePosition.y, true, panel.GridType)
                elseif pSubType == "UIMenuStatisticsPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", false, it - 1, 3)
                    if #panel.Items then
                        for key, stat in pairs (panel.Items) do
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", false, it - 1, pan - 1, stat['name'], stat['value'])
                        end
                    end
                end
            end
        end
        if item.SidePanel ~= nil then
            if item.SidePanel() == "UIMissionDetailsPanel" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 0, item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title, item.SidePanel.TitleColor, item.SidePanel.TextureDict, item.SidePanel.TextureName)
                for key, value in pairs(item.SidePanel.Items) do
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_MISSION_DETAILS_DESC_ITEM", false, it - 1, value.Type, value.TextLeft, value.TextRight, value.Icon, value.IconColor, value.Tick)
                end
            elseif item.SidePanel() == "UIVehicleColorPickerPanel" then
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, it - 1, 1, item.SidePanel.PanelSide, item.SidePanel.TitleType, item.SidePanel.Title, item.SidePanel.TitleColor)
            end
        end
    end
    ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", false, self.ActiveItem)
    local Type, SubType = self.Items[self.ActiveItem]
    if SubType == "UIMenuSeparatorItem" then
        if(self.Items[self.ActiveItem].Jumpable) then
            self:GoDown()
        end
    end
end

---ProcessControl
function UIMenu:ProcessControl()
    if not self._Visible then
        return
    end

    if self.JustOpened then
        self.JustOpened = false
        return
    end

    if UpdateOnscreenKeyboard() == 0 or IsWarningMessageActive() then return end

    if self.Controls.Back.Enabled and (IsDisabledControlJustReleased(0, 177) or IsDisabledControlJustReleased(1, 177) or IsDisabledControlJustReleased(2, 177) or IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(1, 199) or IsDisabledControlJustReleased(2, 199)) then
        self:GoBack()
    end

    if #self.Items == 0 then
        return
    end

    if self.Controls.Up.Enabled and (IsDisabledControlPressed(0, 172) or IsDisabledControlPressed(1, 172) or IsDisabledControlPressed(2, 172) or IsDisabledControlPressed(0, 241) or IsDisabledControlPressed(1, 241) or IsDisabledControlPressed(2, 241) or IsDisabledControlPressed(2, 241)) then
        if GetGameTimer() - self._time > self._delay then
            self:ButtonDelay(0)
            self:GoUp()
        end
    end

    if self.Controls.Down.Enabled and (IsDisabledControlPressed(0, 173) or IsDisabledControlPressed(1, 173) or IsDisabledControlPressed(2, 173) or IsDisabledControlPressed(0, 242) or IsDisabledControlPressed(1, 242) or IsDisabledControlPressed(2, 242)) then
        if GetGameTimer() - self._time > self._delay then
            self:ButtonDelay(0)
            self:GoDown()
        end
    end

    if self.Controls.Left.Enabled and (IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174)) then
        if GetGameTimer() - self._time > self._delay then
            self:ButtonDelay(0)
            self:GoLeft()
        end
    end

    if self.Controls.Right.Enabled and (IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175)) then
        if GetGameTimer() - self._time > self._delay then
            self:ButtonDelay(0)
            self:GoRight()
        end
    end

    if self.Controls.Select.Enabled and (IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(1, 201) or IsDisabledControlJustPressed(2, 201)) then
        self:SelectItem()
    end

    if (IsDisabledControlJustReleased(0, 172) or IsDisabledControlJustReleased(1, 172) or IsDisabledControlJustReleased(2, 172) or IsDisabledControlJustReleased(0, 241) or IsDisabledControlJustReleased(1, 241) or IsDisabledControlJustReleased(2, 241) or IsDisabledControlJustReleased(2, 241)) or
    (IsDisabledControlJustReleased(0, 173) or IsDisabledControlJustReleased(1, 173) or IsDisabledControlJustReleased(2, 173) or IsDisabledControlJustReleased(0, 242) or IsDisabledControlJustReleased(1, 242) or IsDisabledControlJustReleased(2, 242)) or
    (IsDisabledControlJustReleased(0, 174) or IsDisabledControlJustReleased(1, 174) or IsDisabledControlJustReleased(2, 174)) or
    (IsDisabledControlJustReleased(0, 175) or IsDisabledControlJustReleased(1, 175) or IsDisabledControlJustReleased(2, 175)) 
    then
        self._times = 0
        self._delay = 150
    end
end

function UIMenu:ButtonDelay()
    self._times = self._times + 1
    if self._times % 5 == 0 then
        self._delay = self._delay - 10
        if self._delay < 50 then
            self._delay = 50
        end
    end
    self._time = GetGameTimer()
end
---GoUp
function UIMenu:GoUp()
    self.Items[self:CurrentSelection()]:Selected(false)
    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 8, self._delay)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    self.ActiveItem = GetScaleformMovieFunctionReturnInt(return_value)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

---GoDown
function UIMenu:GoDown()
    self.Items[self:CurrentSelection()]:Selected(false)
    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 9, self._delay)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    self.ActiveItem = GetScaleformMovieFunctionReturnInt(return_value)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

---GoLeft
function UIMenu:GoLeft()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuDynamicListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end

    if not Item:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 10)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local res = GetScaleformMovieFunctionReturnInt(return_value)

    if subtype == "UIMenuListItem" then
        Item:Index(res)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif(subtype == "UIMenuDynamicListItem") then
        local result = tostring(Item.Callback(Item, "left"))
        Item:CurrentListItem(result)
    elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        self.OnStatsChanged(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---GoRight
function UIMenu:GoRight()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuDynamicListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end
    if not Item:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", true, 11)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    local res = GetScaleformMovieFunctionReturnInt(return_value)

    if subtype == "UIMenuListItem" then
        Item:Index(res)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif(subtype == "UIMenuDynamicListItem") then
        local result = tostring(Item.Callback(Item, "right"))
        Item:CurrentListItem(result)
   elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        self.OnStatsChanged(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---SelectItem
---@param play boolean
function UIMenu:SelectItem(play)
    if not self.Items[self:CurrentSelection()]:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end
    if play then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
    end

    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype == "UIMenuCheckboxItem" then
        Item:Checked(not Item:Checked())
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnCheckboxChange(self, Item, Item:Checked())
        Item.OnCheckboxChanged(self, Item, Item:Checked())
    elseif subtype == "UIMenuListItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnListSelect(self, Item, Item._Index)
        Item.OnListSelected(self, Item, Item._Index)
    else
        self.OnItemSelect(self, Item, self:CurrentSelection())
        Item:Activated(self, Item)
        if not self.Children[Item] then
            return
        end
        self._Visible = false
        self.OnMenuChanged(self, self.Children[self.Items[self:CurrentSelection()]], true)
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.Children[self.Items[self:CurrentSelection()]].InstructionalButtons)
        self.OnMenuChanged(self, self.Children[Item], "forwards")
        self.Children[Item].OnMenuChanged(self, self.Children[Item], "forwards")
        self.Children[Item]:Visible(true)
        self.Children[Item]:BuildUpMenu()
    end
end

---GoBack
function UIMenu:GoBack()
    PlaySoundFrontend(-1, self.Settings.Audio.Back, self.Settings.Audio.Library, true)
    if self.ParentMenu ~= nil then
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.ParentMenu.InstructionalButtons)
        self.ParentMenu._Visible = true
        self.ParentMenu:BuildUpMenu()
        self.OnMenuChanged(self, self.ParentMenu, "backwards")
        self.ParentMenu.OnMenuChanged(self, self.ParentMenu, "backwards")
    end
    self:Visible(false)
end

---BindMenuToItem
---@param Menu table
---@param Item table
function UIMenu:BindMenuToItem(Menu, Item)
    if Menu() == "UIMenu" and Item() == "UIMenuItem" then
        Menu.ParentMenu = self
        Menu.ParentItem = Item
        self.Children[Item] = Menu
    end
end

---ReleaseMenuFromItem
---@param Item table
function UIMenu:ReleaseMenuFromItem(Item)
    if Item() == "UIMenuItem" then
        if not self.Children[Item] then
            return false
        end
        self.Children[Item].ParentMenu = nil
        self.Children[Item].ParentItem = nil
        self.Children[Item] = nil
        return true
    end
end

function UIMenu:UpdateDescription()
    ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_ITEM_DESCRIPTION", false, self:CurrentSelection()-1, "desc_{" .. self:CurrentSelection() .."}")
end

---Draw
function UIMenu:Draw()
    if not self._Visible or ScaleformUI.Scaleforms.Warning:IsShowing() then return end
    if not ScaleformUI.Scaleforms._ui:IsLoaded() then
        while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
    end

    HideHudComponentThisFrame(19)

    if self.Settings.ControlDisablingEnabled then
        self:DisEnableControls(false)
    end
    
    local x = self.Position.X / 1280
    local y = self.Position.Y / 720
    local width = 1280 / self._scaledWidth
    local height = 720 / 720
    ScaleformUI.Scaleforms._ui:Render2DNormal(x + (width / 2.0), y + (height / 2.0), width, height)

    if self.Glare then
        self._menuGlare:CallFunction("SET_DATA_SLOT", false, GetGameplayCamRelativeHeading())

        local gx = self.Position.X / 1280 + 0.4499
        local gy = self.Position.Y / 720 + 0.449

        self._menuGlare:Render2DNormal(gx, gy, 1.0, 1.0)
    end

    if not IsInputDisabled(2) then
        if self._keyboard then
            self._keyboard = false
            self._changed = true
        end
    else
        if not self._keyboard then
            self._keyboard = true
            self._changed = true
        end
    end
    if self._changed then
        self:UpdateDescription()
        self._changed = false
    end
end

function UIMenu:ProcessMouse()
    if not self._Visible or self.JustOpened or #self.Items == 0 or not IsInputDisabled(2) or not self.Settings.MouseControlsEnabled then
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 25, true)
        EnableControlAction(0, 24, true)
        if self.Dirty then
            for _, Item in pairs(self.Items) do
                if Item:Hovered() then
                    Item:Hovered(false)
                end
            end
        end
        return
    end

    ShowCursorThisFrame()

    
    self:ProcessMouseJustPressed()
    self:ProcessMousePressed()
end

---ProcessMouseJustPressed
function UIMenu:ProcessMouseJustPressed()
    local menuSound = -1

    if IsDisabledControlJustPressed(0, 24) then
        local mouse = { 
            X = GetDisabledControlNormal(0, 239) * (720 * GetScreenAspectRatio(false)) - self.Position.X,
            Y = GetDisabledControlNormal(0, 240) * 720 - self.Position.Y
        }

        local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_MOUSE_EVENT_SINGLE", true, mouse.X, mouse.Y)
        while not IsScaleformMovieMethodReturnValueReady(return_value) do
            Citizen.Wait(0)
            if not self:Visible() then return end
        end
        local res = GetScaleformMovieFunctionReturnString(return_value)
        if(res == "none") then return end
        local split = split(res, ",")
        local type = split[1]
        local selection = tonumber(split[2])
        if type == "it" then
            if self:CurrentSelection() ~= selection + 1 then
                self:CurrentSelection(selection + 1)
            else
                local it = self.Items[self:CurrentSelection()]
                local t, subt = it()
                if tonumber(split[3]) == 0 or tonumber(split[3]) == 2 then
                    self:SelectItem(false)
                elseif tonumber(split[3]) == 1 then
                    if subt == "UIMenuListItem" then
                        it:Index(tonumber(split[4]))
                        self:OnListChange(self, it, it._Index)
                        it.OnListChanged(self, it, it._Index)
                    end
                elseif tonumber(split[3]) == 3 then
                    if subt == "UIMenuSliderItem" then
                    it:Index(tonumber(split[4]))
                    it.OnSliderChanged(self, it, it._Index)
                    self:OnSliderChange(self, it, it._Index)
                    end
                elseif tonumber(split[3]) == 4 then
                    if subt == "UIMenuProgressItem" then
                        local it = self.Items[self:CurrentSelection()]
                        it:Index(tonumber(split[4]))
                        it.OnProgressChanged(self, it, it._Index)
                        self:OnProgressChange(self, it, it._Index)
                    end
                end
            end
        elseif type == "pan" then
            if tonumber(split[3]) == 0 then
                local panels = self.Items[self:CurrentSelection()]
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel.value = tonumber(split[4])
                self:OnColorPanelChanged(panel.ParentItem, panel, panel:CurrentSelection())
                panel.OnColorPanelChanged(panel.ParentItem, panel, panel:CurrentSelection())
            end
        elseif type == "sidepan" then
            if tonumber(split[2]) == 1 then
                local panel = self.Items[self:CurrentSelection()].SidePanel
                if tonumber(split[3]) ~= -1 then
                    panel.Value = tonumber(split[3])
                    panel.PickerSelect(panel.ParentItem, panel, panel.Value)
                end
            end
        end
    end

    if not HasSoundFinished(menuSound) then
        Citizen.Wait(1)
        StopSound(menuSound)
        ReleaseSoundId(menuSound)
    end
end

---ProcessMousePressed
function UIMenu:ProcessMousePressed()
    local menuSound = -1

    if IsDisabledControlPressed(1, 24) then
        local mouse = { 
            X = GetDisabledControlNormal(0, 239) * (720 * GetScreenAspectRatio(false)) - self.Position.X,
            Y = GetDisabledControlNormal(0, 240) * 720 - self.Position.Y
        }

        local return_value = ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_MOUSE_EVENT_CONTINUE", true, mouse.X, mouse.Y)
        while not IsScaleformMovieMethodReturnValueReady(return_value) do
            Citizen.Wait(0)
            if not self:Visible() then return end
        end
        local res = GetScaleformMovieFunctionReturnString(return_value)
        if(res == "none") then return end

        local split = split(res, ",")
        local itemType = split[1]
        local selection = tonumber(split[2])
        local _type = tonumber(split[3])
        local value = split[4]
        if itemType == "pan" then
            if _type == 1 then
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel.Percentage = tonumber(value)
                self:OnPercentagePanelChanged(panel.ParentItem, panel, panel.Percentage)
                panel.OnPercentagePanelChange(panel.ParentItem, panel, panel.Percentage)
                if HasSoundFinished(menuSound) then
                    menuSound = GetSoundId()
                    PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            elseif _type == 2 then 
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel.CirclePosition = vector2(tonumber(split[4]), tonumber(split[5]))
                self.OnGridPanelChanged(panel.ParentItem, panel, panel.CirclePosition)
                panel.OnGridPanelChanged(panel.ParentItem, panel, panel.CirclePosition)
                if HasSoundFinished(menuSound) then
                    menuSound = GetSoundId()
                    PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
        end
    end

    if not HasSoundFinished(menuSound) then
        Citizen.Wait(1)
        StopSound(menuSound)
        ReleaseSoundId(menuSound)
    end
end

---AddInstructionButton
---@param button table
function UIMenu:AddInstructionButton(button)
    if type(button) == "table" and #button == 2 then
        table.insert(self.InstructionalButtons, button)
    end
end

---RemoveInstructionButton
---@param button table
function UIMenu:RemoveInstructionButton(button)
    if type(button) == "table" then
        for i = 1, #self.InstructionalButtons do
            if button == self.InstructionalButtons[i] then
                table.remove(self.InstructionalButtons, i)
                break
            end
        end
    else
        if tonumber(button) then
            if self.InstructionalButtons[tonumber(button)] then
                table.remove(self.InstructionalButtons, tonumber(button))
            end
        end
    end
end

---AddEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:AddEnabledControl(Inputgroup, Control, Controller)
    if tonumber(Inputgroup) and tonumber(Control) then
        table.insert(self.Settings.EnabledControls[(Controller and "Controller" or "Keyboard")], { Inputgroup, Control })
    end
end

---RemoveEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:RemoveEnabledControl(Inputgroup, Control, Controller)
    local Type = (Controller and "Controller" or "Keyboard")
    for Index = 1, #self.Settings.EnabledControls[Type] do
        if Inputgroup == self.Settings.EnabledControls[Type][Index][1] and Control == self.Settings.EnabledControls[Type][Index][2] then
            table.remove(self.Settings.EnabledControls[Type], Index)
            break
        end
    end
end


--///////////////////////////////////////--
MenuAnimationType = {
    LINEAR = 0,
    QUADRATIC_IN = 1,
    QUADRATIC_OUT = 2,
    QUADRATIC_INOUT = 3,
    CUBIC_IN = 4,
    CUBIC_OUT = 5,
    CUBIC_INOUT = 6,
    QUARTIC_IN = 7,
    QUARTIC_OUT = 8,
    QUARTIC_INOUT = 9,
    SINE_IN = 10,
    SINE_OUT = 11,
    SINE_INOUT = 12,
    BACK_IN = 13,
    BACK_OUT = 14,
    BACK_INOUT = 15,
    CIRCULAR_IN = 16,
    CIRCULAR_OUT = 17,
    CIRCULAR_INOUT = 18
}


--///////////////////////////////////////--
BadgeStyle = {
    NONE = 0,
    LOCK = 1,
    STAR = 2,
    WARNING = 3,
    CROWN = 4,
    MEDAL_BRONZE = 5,
    MEDAL_GOLD = 6,
    MEDAL_SILVER = 7,
    CASH = 8,
    COKE = 9,
    HEROIN = 10,
    METH = 11,
    WEED = 12,
    AMMO = 13,
    ARMOR = 14,
    BARBER = 15,
    CLOTHING = 16,
    FRANKLIN = 17,
    BIKE = 18,
    CAR = 19,
    GUN = 20,
    HEALTH_HEART = 21,
    MAKEUP_BRUSH = 22,
    MASK = 23,
    MICHAEL = 24,
    TATTOO = 25,
    TICK = 26,
    TREVOR = 27,
    FEMALE = 28,
    MALE = 29,
    LOCK_ARENA = 30,
    ADVERSARY = 31,
    BASE_JUMPING = 32,
    BRIEFCASE = 33,
    MISSION_STAR = 34,
    DEATHMATCH = 35,
    CASTLE = 36,
    TROPHY = 37,
    RACE_FLAG = 38,
    RACE_FLAG_PLANE = 39,
    RACE_FLAG_BICYCLE = 40,
    RACE_FLAG_PERSON = 41,
    RACE_FLAG_CAR = 42,
    RACE_FLAG_BOAT_ANCHOR = 43,
    ROCKSTAR = 44,
    STUNT = 45,
    STUNT_PREMIUM = 46,
    RACE_FLAG_STUNT_JUMP = 47,
    SHIELD = 48,
    TEAM_DEATHMATCH = 49,
    VEHICLE_DEATHMATCH = 50,
    MP_AMMO_PICKUP = 51,
    MP_AMMO = 52,
    MP_CASH = 53,
    MP_RP = 54,
    MP_SPECTATING = 55,
    SALE = 56,
    GLOBE_WHITE = 57,
    GLOBE_RED = 58,
    GLOBE_BLUE = 59,
    GLOBE_YELLOW = 60,
    GLOBE_GREEN = 61,
    GLOBE_ORANGE = 62,
    INV_ARM_WRESTLING = 63,
    INV_BASEJUMP = 64,
    INV_MISSION = 65,
    INV_DARTS = 66,
    INV_DEATHMATCH = 67,
    INV_DRUG = 68,
    INV_CASTLE = 69,
    INV_GOLF = 70,
    INV_BIKE = 71,
    INV_BOAT = 72,
    INV_ANCHOR = 73,
    INV_CAR = 74,
    INV_DOLLAR = 75,
    INV_COKE = 76,
    INV_KEY = 77,
    INV_DATA = 78,
    INV_HELI = 79,
    INV_HEORIN = 80,
    INV_KEYCARD = 81,
    INV_METH = 82,
    INV_BRIEFCASE = 83,
    INV_LINK = 84,
    INV_PERSON = 85,
    INV_PLANE = 86,
    INV_PLANE2 = 87,
    INV_QUESTIONMARK = 88,
    INV_REMOTE = 89,
    INV_SAFE = 90,
    INV_STEER_WHEEL = 91,
    INV_WEAPON = 92,
    INV_WEED = 93,
    INV_RACE_FLAG_PLANE = 94,
    INV_RACE_FLAG_BICYCLE = 95,
    INV_RACE_FLAG_BOAT_ANCHOR = 96,
    INV_RACE_FLAG_PERSON = 97,
    INV_RACE_FLAG_CAR = 98,
    INV_RACE_FLAG_HELMET = 99,
    INV_SHOOTING_RANGE = 100,
    INV_SURVIVAL = 101,
    INV_TEAM_DEATHMATCH = 102,
    INV_TENNIS = 103,
    INV_VEHICLE_DEATHMATCH = 104,
    AUDIO_MUTE = 105,
    AUDIO_INACTIVE = 106,
    AUDIO_VOL1 = 107,
    AUDIO_VOL2 = 108,
    AUDIO_VOL3 = 109,
    COUNTRY_USA = 110,
    COUNTRY_UK = 111,
    COUNTRY_SWEDEN = 112,
    COUNTRY_KOREA = 113,
    COUNTRY_JAPAN = 114,
    COUNTRY_ITALY = 115,
    COUNTRY_GERMANY = 116,
    COUNTRY_FRANCE = 117,
    BRAND_ALBANY = 118,
    BRAND_ANNIS = 119,
    BRAND_BANSHEE = 120,
    BRAND_BENEFACTOR = 121,
    BRAND_BF = 122,
    BRAND_BOLLOKAN = 123,
    BRAND_BRAVADO = 124,
    BRAND_BRUTE = 125,
    BRAND_BUCKINGHAM = 126,
    BRAND_CANIS = 127,
    BRAND_CHARIOT = 128,
    BRAND_CHEVAL = 129,
    BRAND_CLASSIQUE = 130,
    BRAND_COIL = 131,
    BRAND_DECLASSE = 132,
    BRAND_DEWBAUCHEE = 133,
    BRAND_DILETTANTE = 134,
    BRAND_DINKA = 135,
    BRAND_DUNDREARY = 136,
    BRAND_EMPORER = 137,
    BRAND_ENUS = 138,
    BRAND_FATHOM = 139,
    BRAND_GALIVANTER = 140,
    BRAND_GROTTI = 141,
    BRAND_GROTTI2 = 142,
    BRAND_HIJAK = 143,
    BRAND_HVY = 144,
    BRAND_IMPONTE = 145,
    BRAND_INVETERO = 146,
    BRAND_JACKSHEEPE = 147,
    BRAND_LCC = 148,
    BRAND_JOBUILT = 149,
    BRAND_KARIN = 150,
    BRAND_LAMPADATI = 151,
    BRAND_MAIBATSU = 152,
    BRAND_MAMMOTH = 153,
    BRAND_MTL = 154,
    BRAND_NAGASAKI = 155,
    BRAND_OBEY = 156,
    BRAND_OCELOT = 157,
    BRAND_OVERFLOD = 158,
    BRAND_PED = 159,
    BRAND_PEGASSI = 160,
    BRAND_PFISTER = 161,
    BRAND_PRINCIPE = 162,
    BRAND_PROGEN = 163,
    BRAND_PROGEN2 = 164,
    BRAND_RUNE = 165,
    BRAND_SCHYSTER = 166,
    BRAND_SHITZU = 167,
    BRAND_SPEEDOPHILE = 168,
    BRAND_STANLEY = 169,
    BRAND_TRUFFADE = 170,
    BRAND_UBERMACHT = 171,
    BRAND_VAPID = 172,
    BRAND_VULCAR = 173,
    BRAND_WEENY = 174,
    BRAND_WESTERN = 175,
    BRAND_WESTERNMOTORCYCLE = 176,
    BRAND_WILLARD = 177,
    BRAND_ZIRCONIUM = 178,
    INFO = 179
}

function GetSpriteDictionary(icon)
    if icon == BadgeStyle.MALE or icon == BadgeStyle.FEMALE or icon == BadgeStyle.AUDIO_MUTE or icon == BadgeStyle.AUDIO_INACTIVE or icon == BadgeStyle.AUDIO_VOL1 or icon == BadgeStyle.AUDIO_VOL2 or icon == BadgeStyle.AUDIO_VOL3 then
        return "mpleaderboard"
    elseif icon == BadgeStyle.INV_ARM_WRESTLING or icon == BadgeStyle.INV_BASEJUMP or icon == BadgeStyle.INV_MISSION or icon == BadgeStyle.INV_DARTS or icon == BadgeStyle.INV_DEATHMATCH or icon == BadgeStyle.INV_DRUG or icon == BadgeStyle.INV_CASTLE or icon == BadgeStyle.INV_GOLF or icon == BadgeStyle.INV_BIKE or icon == BadgeStyle.INV_BOAT or icon == BadgeStyle.INV_ANCHOR or icon == BadgeStyle.INV_CAR or icon == BadgeStyle.INV_DOLLAR or icon == BadgeStyle.INV_COKE or icon == BadgeStyle.INV_KEY or icon == BadgeStyle.INV_DATA or icon == BadgeStyle.INV_HELI or icon == BadgeStyle.INV_HEORIN or icon == BadgeStyle.INV_KEYCARD or icon == BadgeStyle.INV_METH or icon == BadgeStyle.INV_BRIEFCASE or icon == BadgeStyle.INV_LINK or icon == BadgeStyle.INV_PERSON or icon == BadgeStyle.INV_PLANE or icon == BadgeStyle.INV_PLANE2 or icon == BadgeStyle.INV_QUESTIONMARK or icon == BadgeStyle.INV_REMOTE or icon == BadgeStyle.INV_SAFE or icon == BadgeStyle.INV_STEER_WHEEL or icon == BadgeStyle.INV_WEAPON or icon == BadgeStyle.INV_WEED or icon == BadgeStyle.INV_RACE_FLAG_PLANE or icon == BadgeStyle.INV_RACE_FLAG_BICYCLE or icon == BadgeStyle.INV_RACE_FLAG_BOAT_ANCHOR or icon == BadgeStyle.INV_RACE_FLAG_PERSON or icon == BadgeStyle.INV_RACE_FLAG_CAR or icon == BadgeStyle.INV_RACE_FLAG_HELMET or icon == BadgeStyle.INV_SHOOTING_RANGE or icon == BadgeStyle.INV_SURVIVAL or icon == BadgeStyle.INV_TEAM_DEATHMATCH or icon == BadgeStyle.INV_TENNIS or icon == BadgeStyle.INV_VEHICLE_DEATHMATCH then
        return "mpinventory"
    elseif icon == BadgeStyle.ADVERSARY or icon == BadgeStyle.BASE_JUMPING or icon == BadgeStyle.BRIEFCASE or icon == BadgeStyle.MISSION_STAR or icon == BadgeStyle.DEATHMATCH or icon == BadgeStyle.CASTLE or icon == BadgeStyle.TROPHY or icon == BadgeStyle.RACE_FLAG or icon == BadgeStyle.RACE_FLAG_PLANE or icon == BadgeStyle.RACE_FLAG_BICYCLE or icon == BadgeStyle.RACE_FLAG_PERSON or icon == BadgeStyle.RACE_FLAG_CAR or icon == BadgeStyle.RACE_FLAG_BOAT_ANCHOR or icon == BadgeStyle.ROCKSTAR or icon == BadgeStyle.STUNT or icon == BadgeStyle.STUNT_PREMIUM or icon == BadgeStyle.RACE_FLAG_STUNT_JUMP or icon == BadgeStyle.SHIELD or icon == BadgeStyle.TEAM_DEATHMATCH or icon == BadgeStyle.VEHICLE_DEATHMATCH then
        return "commonmenutu"
    elseif icon == BadgeStyle.MP_AMMO_PICKUP or icon == BadgeStyle.MP_AMMO or icon == BadgeStyle.MP_CASH or icon == BadgeStyle.MP_RP or icon == BadgeStyle.MP_SPECTATING then
        return "mphud"
    elseif icon == BadgeStyle.SALE then
        return "mpshopsale"
    elseif icon == BadgeStyle.GLOBE_WHITE or icon == BadgeStyle.GLOBE_RED or icon == BadgeStyle.GLOBE_BLUE or icon == BadgeStyle.GLOBE_YELLOW or icon == BadgeStyle.GLOBE_GREEN or icon == BadgeStyle.GLOBE_ORANGE then
        return "mprankbadge"
    elseif icon == BadgeStyle.COUNTRY_USA or icon == BadgeStyle.COUNTRY_UK or icon == BadgeStyle.COUNTRY_SWEDEN or icon == BadgeStyle.COUNTRY_KOREA or icon == BadgeStyle.COUNTRY_JAPAN or icon == BadgeStyle.COUNTRY_ITALY or icon == BadgeStyle.COUNTRY_GERMANY or icon == BadgeStyle.COUNTRY_FRANCE or icon == BadgeStyle.BRAND_ALBANY or icon == BadgeStyle.BRAND_ANNIS or icon == BadgeStyle.BRAND_BANSHEE or icon == BadgeStyle.BRAND_BENEFACTOR or icon == BadgeStyle.BRAND_BF or icon == BadgeStyle.BRAND_BOLLOKAN or icon == BadgeStyle.BRAND_BRAVADO or icon == BadgeStyle.BRAND_BRUTE or icon == BadgeStyle.BRAND_BUCKINGHAM or icon == BadgeStyle.BRAND_CANIS or icon == BadgeStyle.BRAND_CHARIOT or icon == BadgeStyle.BRAND_CHEVAL or icon == BadgeStyle.BRAND_CLASSIQUE or icon == BadgeStyle.BRAND_COIL or icon == BadgeStyle.BRAND_DECLASSE or icon == BadgeStyle.BRAND_DEWBAUCHEE or icon == BadgeStyle.BRAND_DILETTANTE or icon == BadgeStyle.BRAND_DINKA or icon == BadgeStyle.BRAND_DUNDREARY or icon == BadgeStyle.BRAND_EMPORER or icon == BadgeStyle.BRAND_ENUS or icon == BadgeStyle.BRAND_FATHOM or icon == BadgeStyle.BRAND_GALIVANTER or icon == BadgeStyle.BRAND_GROTTI or icon == BadgeStyle.BRAND_HIJAK or icon == BadgeStyle.BRAND_HVY or icon == BadgeStyle.BRAND_IMPONTE or icon == BadgeStyle.BRAND_INVETERO or icon == BadgeStyle.BRAND_JACKSHEEPE or icon == BadgeStyle.BRAND_JOBUILT or icon == BadgeStyle.BRAND_KARIN or icon == BadgeStyle.BRAND_LAMPADATI or icon == BadgeStyle.BRAND_MAIBATSU or icon == BadgeStyle.BRAND_MAMMOTH or icon == BadgeStyle.BRAND_MTL or icon == BadgeStyle.BRAND_NAGASAKI or icon == BadgeStyle.BRAND_OBEY or icon == BadgeStyle.BRAND_OCELOT or icon == BadgeStyle.BRAND_OVERFLOD or icon == BadgeStyle.BRAND_PED or icon == BadgeStyle.BRAND_PEGASSI or icon == BadgeStyle.BRAND_PFISTER or icon == BadgeStyle.BRAND_PRINCIPE or icon == BadgeStyle.BRAND_PROGEN or icon == BadgeStyle.BRAND_SCHYSTER or icon == BadgeStyle.BRAND_SHITZU or icon == BadgeStyle.BRAND_SPEEDOPHILE or icon == BadgeStyle.BRAND_STANLEY or icon == BadgeStyle.BRAND_TRUFFADE or icon == BadgeStyle.BRAND_UBERMACHT or icon == BadgeStyle.BRAND_VAPID or icon == BadgeStyle.BRAND_VULCAR or icon == BadgeStyle.BRAND_WEENY or icon == BadgeStyle.BRAND_WESTERN or icon == BadgeStyle.BRAND_WESTERNMOTORCYCLE or icon == BadgeStyle.BRAND_WILLARD or icon == BadgeStyle.BRAND_ZIRCONIUM then
        return "mpcarhud"
    elseif icon == BadgeStyle.BRAND_GROTTI2 or icon == BadgeStyle.BRAND_LCC or icon == BadgeStyle.BRAND_PROGEN2 or icon == BadgeStyle.BRAND_RUNE then
        return "mpcarhud2"
    elseif icon == BadgeStyle.INFO then
        return "shared"
    else
        return "commonmenu"
    end
end

function GetSpriteName(icon, selected)
    if icon == BadgeStyle.AMMO then if selected then return "shop_ammo_icon_b" else return "shop_ammo_icon_a" end
    elseif icon == BadgeStyle.ARMOR then if selected then return "shop_armour_icon_b" else return "shop_armour_icon_a" end
    elseif icon == BadgeStyle.BARBER then if selected then return "shop_barber_icon_b" else return "shop_barber_icon_a" end
    elseif icon == BadgeStyle.BIKE then if selected then return "shop_garage_bike_icon_b" else return "shop_garage_bike_icon_a" end
    elseif icon == BadgeStyle.CAR then if selected then return "shop_garage_icon_b" else return "shop_garage_icon_a" end
    elseif icon == BadgeStyle.CASH then return "mp_specitem_cash" 
    elseif icon == BadgeStyle.CLOTHING then if selected then return "shop_clothing_icon_b" else return "shop_clothing_icon_a" end
    elseif icon == BadgeStyle.COKE then return "mp_specitem_coke" 
    elseif icon == BadgeStyle.CROWN then return "mp_hostcrown" 
    elseif icon == BadgeStyle.FRANKLIN then if selected then return "shop_franklin_icon_b" else return "shop_franklin_icon_a" end
    elseif icon == BadgeStyle.GUN then if selected then return "shop_gunclub_icon_b" else return "shop_gunclub_icon_a" end
    elseif icon == BadgeStyle.HEALTH_HEART then if selected then return "shop_health_icon_b" else return "shop_health_icon_a" end
    elseif icon == BadgeStyle.HEROIN then return "mp_specitem_heroin" 
    elseif icon == BadgeStyle.LOCK then return "shop_lock" 
    elseif icon == BadgeStyle.MAKEUP_BRUSH then if selected then return "shop_makeup_icon_b" else return "shop_makeup_icon_a" end
    elseif icon == BadgeStyle.MASK then if selected then return "shop_mask_icon_b" else return "shop_mask_icon_a" end
    elseif icon == BadgeStyle.MEDAL_BRONZE then return "mp_medal_bronze" 
    elseif icon == BadgeStyle.MEDAL_GOLD then return "mp_medal_gold" 
    elseif icon == BadgeStyle.MEDAL_SILVER then return "mp_medal_silver" 
    elseif icon == BadgeStyle.METH then return "mp_specitem_meth" 
    elseif icon == BadgeStyle.MICHAEL then if selected then return "shop_michael_icon_b" else return "shop_michael_icon_a" end
    elseif icon == BadgeStyle.STAR then return "shop_new_star" 
    elseif icon == BadgeStyle.TATTOO then if selected then return "shop_tattoos_icon_b" else return "shop_tattoos_icon_a" end
    elseif icon == BadgeStyle.TICK then return "shop_tick_icon" 
    elseif icon == BadgeStyle.TREVOR then if selected then return "shop_trevor_icon_b" else return "shop_trevor_icon_a" end
    elseif icon == BadgeStyle.WARNING then return "mp_alerttriangle" 
    elseif icon == BadgeStyle.WEED then return "mp_specitem_weed" 
    elseif icon == BadgeStyle.MALE then return "leaderboard_male_icon" 
    elseif icon == BadgeStyle.FEMALE then return "leaderboard_female_icon" 
    elseif icon == BadgeStyle.LOCK_ARENA then return "shop_lock_arena" 
    elseif icon == BadgeStyle.ADVERSARY then return "adversary" 
    elseif icon == BadgeStyle.BASE_JUMPING then return "base_jumping" 
    elseif icon == BadgeStyle.BRIEFCASE then return "capture_the_flag" 
    elseif icon == BadgeStyle.MISSION_STAR then return "custom_mission" 
    elseif icon == BadgeStyle.DEATHMATCH then return "deathmatch" 
    elseif icon == BadgeStyle.CASTLE then return "gang_attack" 
    elseif icon == BadgeStyle.TROPHY then return "last_team_standing" 
    elseif icon == BadgeStyle.RACE_FLAG then return "race" 
    elseif icon == BadgeStyle.RACE_FLAG_PLANE then return "race_air" 
    elseif icon == BadgeStyle.RACE_FLAG_BICYCLE then return "race_bicycle" 
    elseif icon == BadgeStyle.RACE_FLAG_PERSON then return "race_foot" 
    elseif icon == BadgeStyle.RACE_FLAG_CAR then return "race_land" 
    elseif icon == BadgeStyle.RACE_FLAG_BOAT_ANCHOR then return "race_water" 
    elseif icon == BadgeStyle.ROCKSTAR then return "rockstar" 
    elseif icon == BadgeStyle.STUNT then return "stunt" 
    elseif icon == BadgeStyle.STUNT_PREMIUM then return "stunt_premium" 
    elseif icon == BadgeStyle.RACE_FLAG_STUNT_JUMP then return "stunt_race" 
    elseif icon == BadgeStyle.SHIELD then return "survival" 
    elseif icon == BadgeStyle.TEAM_DEATHMATCH then return "team_deathmatch" 
    elseif icon == BadgeStyle.VEHICLE_DEATHMATCH then return "vehicle_deathmatch" 
    elseif icon == BadgeStyle.MP_AMMO_PICKUP then return "ammo_pickup" 
    elseif icon == BadgeStyle.MP_AMMO then return "mp_anim_ammo" 
    elseif icon == BadgeStyle.MP_CASH then return "mp_anim_cash" 
    elseif icon == BadgeStyle.MP_RP then return "mp_anim_rp" 
    elseif icon == BadgeStyle.MP_SPECTATING then return "spectating" 
    elseif icon == BadgeStyle.SALE then return "saleicon" 
    elseif icon == BadgeStyle.GLOBE_WHITE or icon == BadgeStyle.GLOBE_RED or icon == BadgeStyle.GLOBE_BLUE or icon == BadgeStyle.GLOBE_YELLOW or icon == BadgeStyle.GLOBE_GREEN or icon == BadgeStyle.GLOBE_ORANGE then
        return "globe"
    
    elseif icon == BadgeStyle.INV_ARM_WRESTLING then return "arm_wrestling" 
    elseif icon == BadgeStyle.INV_BASEJUMP then return "basejump" 
    elseif icon == BadgeStyle.INV_MISSION then return "custom_mission" 
    elseif icon == BadgeStyle.INV_DARTS then return "darts" 
    elseif icon == BadgeStyle.INV_DEATHMATCH then return "deathmatch" 
    elseif icon == BadgeStyle.INV_DRUG then return "drug_trafficking" 
    elseif icon == BadgeStyle.INV_CASTLE then return "gang_attack" 
    elseif icon == BadgeStyle.INV_GOLF then return "golf" 
    elseif icon == BadgeStyle.INV_BIKE then return "mp_specitem_bike" 
    elseif icon == BadgeStyle.INV_BOAT then return "mp_specitem_boat" 
    elseif icon == BadgeStyle.INV_ANCHOR then return "mp_specitem_boatpickup" 
    elseif icon == BadgeStyle.INV_CAR then return "mp_specitem_car" 
    elseif icon == BadgeStyle.INV_DOLLAR then return "mp_specitem_cash" 
    elseif icon == BadgeStyle.INV_COKE then return "mp_specitem_coke" 
    elseif icon == BadgeStyle.INV_KEY then return "mp_specitem_cuffkeys" 
    elseif icon == BadgeStyle.INV_DATA then return "mp_specitem_data" 
    elseif icon == BadgeStyle.INV_HELI then return "mp_specitem_heli" 
    elseif icon == BadgeStyle.INV_HEORIN then return "mp_specitem_heroin" 
    elseif icon == BadgeStyle.INV_KEYCARD then return "mp_specitem_keycard" 
    elseif icon == BadgeStyle.INV_METH then return "mp_specitem_meth" 
    elseif icon == BadgeStyle.INV_BRIEFCASE then return "mp_specitem_package" 
    elseif icon == BadgeStyle.INV_LINK then return "mp_specitem_partnericon" 
    elseif icon == BadgeStyle.INV_PERSON then return "mp_specitem_ped" 
    elseif icon == BadgeStyle.INV_PLANE then return "mp_specitem_plane" 
    elseif icon == BadgeStyle.INV_PLANE2 then return "mp_specitem_plane2" 
    elseif icon == BadgeStyle.INV_QUESTIONMARK then return "mp_specitem_randomobject" 
    elseif icon == BadgeStyle.INV_REMOTE then return "mp_specitem_remote" 
    elseif icon == BadgeStyle.INV_SAFE then return "mp_specitem_safe" 
    elseif icon == BadgeStyle.INV_STEER_WHEEL then return "mp_specitem_steer_wheel" 
    elseif icon == BadgeStyle.INV_WEAPON then return "mp_specitem_weapons" 
    elseif icon == BadgeStyle.INV_WEED then return "mp_specitem_weed" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_PLANE then return "race_air" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_BICYCLE then return "race_bike" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_BOAT_ANCHOR then return "race_boat" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_PERSON then return "race_foot" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_CAR then return "race_land" 
    elseif icon == BadgeStyle.INV_RACE_FLAG_HELMET then return "race_offroad" 
    elseif icon == BadgeStyle.INV_SHOOTING_RANGE then return "shooting_range" 
    elseif icon == BadgeStyle.INV_SURVIVAL then return "survival" 
    elseif icon == BadgeStyle.INV_TEAM_DEATHMATCH then return "team_deathmatch" 
    elseif icon == BadgeStyle.INV_TENNIS then return "tennis" 
    elseif icon == BadgeStyle.INV_VEHICLE_DEATHMATCH then return "vehicle_deathmatch" 
    elseif icon == BadgeStyle.AUDIO_MUTE then return "leaderboard_audio_mute" 
    elseif icon == BadgeStyle.AUDIO_INACTIVE then return "leaderboard_audio_inactive" 
    elseif icon == BadgeStyle.AUDIO_VOL1 then return "leaderboard_audio_1" 
    elseif icon == BadgeStyle.AUDIO_VOL2 then return "leaderboard_audio_2" 
    elseif icon == BadgeStyle.AUDIO_VOL3 then return "leaderboard_audio_3" 
    elseif icon == BadgeStyle.COUNTRY_USA then return "vehicle_card_icons_flag_usa" 
    elseif icon == BadgeStyle.COUNTRY_UK then return "vehicle_card_icons_flag_uk" 
    elseif icon == BadgeStyle.COUNTRY_SWEDEN then return "vehicle_card_icons_flag_sweden" 
    elseif icon == BadgeStyle.COUNTRY_KOREA then return "vehicle_card_icons_flag_korea" 
    elseif icon == BadgeStyle.COUNTRY_JAPAN then return "vehicle_card_icons_flag_japan" 
    elseif icon == BadgeStyle.COUNTRY_ITALY then return "vehicle_card_icons_flag_italy" 
    elseif icon == BadgeStyle.COUNTRY_GERMANY then return "vehicle_card_icons_flag_germany" 
    elseif icon == BadgeStyle.COUNTRY_FRANCE then return "vehicle_card_icons_flag_france" 
    elseif icon == BadgeStyle.BRAND_ALBANY then return "albany" 
    elseif icon == BadgeStyle.BRAND_ANNIS then return "annis" 
    elseif icon == BadgeStyle.BRAND_BANSHEE then return "banshee" 
    elseif icon == BadgeStyle.BRAND_BENEFACTOR then return "benefactor" 
    elseif icon == BadgeStyle.BRAND_BF then return "bf" 
    elseif icon == BadgeStyle.BRAND_BOLLOKAN then return "bollokan" 
    elseif icon == BadgeStyle.BRAND_BRAVADO then return "bravado" 
    elseif icon == BadgeStyle.BRAND_BRUTE then return "brute" 
    elseif icon == BadgeStyle.BRAND_BUCKINGHAM then return "buckingham" 
    elseif icon == BadgeStyle.BRAND_CANIS then return "canis" 
    elseif icon == BadgeStyle.BRAND_CHARIOT then return "chariot" 
    elseif icon == BadgeStyle.BRAND_CHEVAL then return "cheval" 
    elseif icon == BadgeStyle.BRAND_CLASSIQUE then return "classique" 
    elseif icon == BadgeStyle.BRAND_COIL then return "coil" 
    elseif icon == BadgeStyle.BRAND_DECLASSE then return "declasse" 
    elseif icon == BadgeStyle.BRAND_DEWBAUCHEE then return "dewbauchee" 
    elseif icon == BadgeStyle.BRAND_DILETTANTE then return "dilettante" 
    elseif icon == BadgeStyle.BRAND_DINKA then return "dinka" 
    elseif icon == BadgeStyle.BRAND_DUNDREARY then return "dundreary" 
    elseif icon == BadgeStyle.BRAND_EMPORER then return "emporer" 
    elseif icon == BadgeStyle.BRAND_ENUS then return "enus" 
    elseif icon == BadgeStyle.BRAND_FATHOM then return "fathom" 
    elseif icon == BadgeStyle.BRAND_GALIVANTER then return "galivanter" 
    elseif icon == BadgeStyle.BRAND_GROTTI then return "grotti" 
    elseif icon == BadgeStyle.BRAND_HIJAK then return "hijak" 
    elseif icon == BadgeStyle.BRAND_HVY then return "hvy" 
    elseif icon == BadgeStyle.BRAND_IMPONTE then return "imponte" 
    elseif icon == BadgeStyle.BRAND_INVETERO then return "invetero" 
    elseif icon == BadgeStyle.BRAND_JACKSHEEPE then return "jacksheepe" 
    elseif icon == BadgeStyle.BRAND_JOBUILT then return "jobuilt" 
    elseif icon == BadgeStyle.BRAND_KARIN then return "karin" 
    elseif icon == BadgeStyle.BRAND_LAMPADATI then return "lampadati" 
    elseif icon == BadgeStyle.BRAND_MAIBATSU then return "maibatsu" 
    elseif icon == BadgeStyle.BRAND_MAMMOTH then return "mammoth" 
    elseif icon == BadgeStyle.BRAND_MTL then return "mtl" 
    elseif icon == BadgeStyle.BRAND_NAGASAKI then return "nagasaki" 
    elseif icon == BadgeStyle.BRAND_OBEY then return "obey" 
    elseif icon == BadgeStyle.BRAND_OCELOT then return "ocelot" 
    elseif icon == BadgeStyle.BRAND_OVERFLOD then return "overflod" 
    elseif icon == BadgeStyle.BRAND_PED then return "ped" 
    elseif icon == BadgeStyle.BRAND_PEGASSI then return "pegassi" 
    elseif icon == BadgeStyle.BRAND_PFISTER then return "pfister" 
    elseif icon == BadgeStyle.BRAND_PRINCIPE then return "principe" 
    elseif icon == BadgeStyle.BRAND_PROGEN then return "progen" 
    elseif icon == BadgeStyle.BRAND_SCHYSTER then return "schyster" 
    elseif icon == BadgeStyle.BRAND_SHITZU then return "shitzu" 
    elseif icon == BadgeStyle.BRAND_SPEEDOPHILE then return "speedophile" 
    elseif icon == BadgeStyle.BRAND_STANLEY then return "stanley" 
    elseif icon == BadgeStyle.BRAND_TRUFFADE then return "truffade" 
    elseif icon == BadgeStyle.BRAND_UBERMACHT then return "ubermacht" 
    elseif icon == BadgeStyle.BRAND_VAPID then return "vapid" 
    elseif icon == BadgeStyle.BRAND_VULCAR then return "vulcar" 
    elseif icon == BadgeStyle.BRAND_WEENY then return "weeny" 
    elseif icon == BadgeStyle.BRAND_WESTERN then return "western" 
    elseif icon == BadgeStyle.BRAND_WESTERNMOTORCYCLE then return "westernmotorcycle" 
    elseif icon == BadgeStyle.BRAND_WILLARD then return "willard" 
    elseif icon == BadgeStyle.BRAND_ZIRCONIUM then return "zirconium" 
    elseif icon == BadgeStyle.BRAND_GROTTI2 then return "grotti_2" 
    elseif icon == BadgeStyle.BRAND_LCC then return "lcc" 
    elseif icon == BadgeStyle.BRAND_PROGEN2 then return "progen" 
    elseif icon == BadgeStyle.BRAND_RUNE then return "rune" 
    elseif icon == BadgeStyle.INFO then return "info_icon_32" 
    else 
        return "" 
    end
end



--///////////////////////////////////////--
Colours = {
    NONE = -1,
    HUD_COLOUR_PURE_WHITE = 0,
    HUD_COLOUR_WHITE = 1,
    HUD_COLOUR_BLACK = 2,
    HUD_COLOUR_GREY = 3,
    HUD_COLOUR_GREYLIGHT = 4,
    HUD_COLOUR_GREYDARK = 5,
    HUD_COLOUR_RED = 6,
    HUD_COLOUR_REDLIGHT = 7,
    HUD_COLOUR_REDDARK = 8,
    HUD_COLOUR_BLUE = 9,
    HUD_COLOUR_BLUELIGHT = 10,
    HUD_COLOUR_BLUEDARK = 11,
    HUD_COLOUR_YELLOW = 12,
    HUD_COLOUR_YELLOWLIGHT = 13,
    HUD_COLOUR_YELLOWDARK = 14,
    HUD_COLOUR_ORANGE = 15,
    HUD_COLOUR_ORANGELIGHT = 16,
    HUD_COLOUR_ORANGEDARK = 17,
    HUD_COLOUR_GREEN = 18,
    HUD_COLOUR_GREENLIGHT = 19,
    HUD_COLOUR_GREENDARK = 20,
    HUD_COLOUR_PURPLE = 21,
    HUD_COLOUR_PURPLELIGHT = 22,
    HUD_COLOUR_PURPLEDARK = 23,
    HUD_COLOUR_PINK = 24,
    HUD_COLOUR_RADAR_HEALTH = 25,
    HUD_COLOUR_RADAR_ARMOUR = 26,
    HUD_COLOUR_RADAR_DAMAGE = 27,
    HUD_COLOUR_NET_PLAYER1 = 28,
    HUD_COLOUR_NET_PLAYER2 = 29,
    HUD_COLOUR_NET_PLAYER3 = 30,
    HUD_COLOUR_NET_PLAYER4 = 31,
    HUD_COLOUR_NET_PLAYER5 = 32,
    HUD_COLOUR_NET_PLAYER6 = 33,
    HUD_COLOUR_NET_PLAYER7 = 34,
    HUD_COLOUR_NET_PLAYER8 = 35,
    HUD_COLOUR_NET_PLAYER9 = 36,
    HUD_COLOUR_NET_PLAYER10 = 37,
    HUD_COLOUR_NET_PLAYER11 = 38,
    HUD_COLOUR_NET_PLAYER12 = 39,
    HUD_COLOUR_NET_PLAYER13 = 40,
    HUD_COLOUR_NET_PLAYER14 = 41,
    HUD_COLOUR_NET_PLAYER15 = 42,
    HUD_COLOUR_NET_PLAYER16 = 43,
    HUD_COLOUR_NET_PLAYER17 = 44,
    HUD_COLOUR_NET_PLAYER18 = 45,
    HUD_COLOUR_NET_PLAYER19 = 46,
    HUD_COLOUR_NET_PLAYER20 = 47,
    HUD_COLOUR_NET_PLAYER21 = 48,
    HUD_COLOUR_NET_PLAYER22 = 49,
    HUD_COLOUR_NET_PLAYER23 = 50,
    HUD_COLOUR_NET_PLAYER24 = 51,
    HUD_COLOUR_NET_PLAYER25 = 52,
    HUD_COLOUR_NET_PLAYER26 = 53,
    HUD_COLOUR_NET_PLAYER27 = 54,
    HUD_COLOUR_NET_PLAYER28 = 55,
    HUD_COLOUR_NET_PLAYER29 = 56,
    HUD_COLOUR_NET_PLAYER30 = 57,
    HUD_COLOUR_NET_PLAYER31 = 58,
    HUD_COLOUR_NET_PLAYER32 = 59,
    HUD_COLOUR_SIMPLEBLIP_DEFAULT = 60,
    HUD_COLOUR_MENU_BLUE = 61,
    HUD_COLOUR_MENU_GREY_LIGHT = 62,
    HUD_COLOUR_MENU_BLUE_EXTRA_DARK = 63,
    HUD_COLOUR_MENU_YELLOW = 64,
    HUD_COLOUR_MENU_YELLOW_DARK = 65,
    HUD_COLOUR_MENU_GREEN = 66,
    HUD_COLOUR_MENU_GREY = 67,
    HUD_COLOUR_MENU_GREY_DARK = 68,
    HUD_COLOUR_MENU_HIGHLIGHT = 69,
    HUD_COLOUR_MENU_STANDARD = 70,
    HUD_COLOUR_MENU_DIMMED = 71,
    HUD_COLOUR_MENU_EXTRA_DIMMED = 72,
    HUD_COLOUR_BRIEF_TITLE = 73,
    HUD_COLOUR_MID_GREY_MP = 74,
    HUD_COLOUR_NET_PLAYER1_DARK = 75,
    HUD_COLOUR_NET_PLAYER2_DARK = 76,
    HUD_COLOUR_NET_PLAYER3_DARK = 77,
    HUD_COLOUR_NET_PLAYER4_DARK = 78,
    HUD_COLOUR_NET_PLAYER5_DARK = 79,
    HUD_COLOUR_NET_PLAYER6_DARK = 80,
    HUD_COLOUR_NET_PLAYER7_DARK = 81,
    HUD_COLOUR_NET_PLAYER8_DARK = 82,
    HUD_COLOUR_NET_PLAYER9_DARK = 83,
    HUD_COLOUR_NET_PLAYER10_DARK = 84,
    HUD_COLOUR_NET_PLAYER11_DARK = 85,
    HUD_COLOUR_NET_PLAYER12_DARK = 86,
    HUD_COLOUR_NET_PLAYER13_DARK = 87,
    HUD_COLOUR_NET_PLAYER14_DARK = 88,
    HUD_COLOUR_NET_PLAYER15_DARK = 89,
    HUD_COLOUR_NET_PLAYER16_DARK = 90,
    HUD_COLOUR_NET_PLAYER17_DARK = 91,
    HUD_COLOUR_NET_PLAYER18_DARK = 92,
    HUD_COLOUR_NET_PLAYER19_DARK = 93,
    HUD_COLOUR_NET_PLAYER20_DARK = 94,
    HUD_COLOUR_NET_PLAYER21_DARK = 95,
    HUD_COLOUR_NET_PLAYER22_DARK = 96,
    HUD_COLOUR_NET_PLAYER23_DARK = 97,
    HUD_COLOUR_NET_PLAYER24_DARK = 98,
    HUD_COLOUR_NET_PLAYER25_DARK = 99,
    HUD_COLOUR_NET_PLAYER26_DARK = 100,
    HUD_COLOUR_NET_PLAYER27_DARK = 101,
    HUD_COLOUR_NET_PLAYER28_DARK = 102,
    HUD_COLOUR_NET_PLAYER29_DARK = 103,
    HUD_COLOUR_NET_PLAYER30_DARK = 104,
    HUD_COLOUR_NET_PLAYER31_DARK = 105,
    HUD_COLOUR_NET_PLAYER32_DARK = 106,
    HUD_COLOUR_BRONZE = 107,
    HUD_COLOUR_SILVER = 108,
    HUD_COLOUR_GOLD = 109,
    HUD_COLOUR_PLATINUM = 110,
    HUD_COLOUR_GANG1 = 111,
    HUD_COLOUR_GANG2 = 112,
    HUD_COLOUR_GANG3 = 113,
    HUD_COLOUR_GANG4 = 114,
    HUD_COLOUR_SAME_CREW = 115,
    HUD_COLOUR_FREEMODE = 116,
    HUD_COLOUR_PAUSE_BG = 117,
    HUD_COLOUR_FRIENDLY = 118,
    HUD_COLOUR_ENEMY = 119,
    HUD_COLOUR_LOCATION = 120,
    HUD_COLOUR_PICKUP = 121,
    HUD_COLOUR_PAUSE_SINGLEPLAYER = 122,
    HUD_COLOUR_FREEMODE_DARK = 123,
    HUD_COLOUR_INACTIVE_MISSION = 124,
    HUD_COLOUR_DAMAGE = 125,
    HUD_COLOUR_PINKLIGHT = 126,
    HUD_COLOUR_PM_MITEM_HIGHLIGHT = 127,
    HUD_COLOUR_SCRIPT_VARIABLE = 128,
    HUD_COLOUR_YOGA = 129,
    HUD_COLOUR_TENNIS = 130,
    HUD_COLOUR_GOLF = 131,
    HUD_COLOUR_SHOOTING_RANGE = 132,
    HUD_COLOUR_FLIGHT_SCHOOL = 133,
    HUD_COLOUR_NORTH_BLUE = 134,
    HUD_COLOUR_SOCIAL_CLUB = 135,
    HUD_COLOUR_PLATFORM_BLUE = 136,
    HUD_COLOUR_PLATFORM_GREEN = 137,
    HUD_COLOUR_PLATFORM_GREY = 138,
    HUD_COLOUR_FACEBOOK_BLUE = 139,
    HUD_COLOUR_INGAME_BG = 140,
    HUD_COLOUR_DARTS = 141,
    HUD_COLOUR_WAYPOINT = 142,
    HUD_COLOUR_MICHAEL = 143,
    HUD_COLOUR_FRANKLIN = 144,
    HUD_COLOUR_TREVOR = 145,
    HUD_COLOUR_GOLF_P1 = 146,
    HUD_COLOUR_GOLF_P2 = 147,
    HUD_COLOUR_GOLF_P3 = 148,
    HUD_COLOUR_GOLF_P4 = 149,
    HUD_COLOUR_WAYPOINTLIGHT = 150,
    HUD_COLOUR_WAYPOINTDARK = 151,
    HUD_COLOUR_PANEL_LIGHT = 152,
    HUD_COLOUR_MICHAEL_DARK = 153,
    HUD_COLOUR_FRANKLIN_DARK = 154,
    HUD_COLOUR_TREVOR_DARK = 155,
    HUD_COLOUR_OBJECTIVE_ROUTE = 156,
    HUD_COLOUR_PAUSEMAP_TINT = 157,
    HUD_COLOUR_PAUSE_DESELECT = 158,
    HUD_COLOUR_PM_WEAPONS_PURCHASABLE = 159,
    HUD_COLOUR_PM_WEAPONS_LOCKED = 160,
    HUD_COLOUR_END_SCREEN_BG = 161,
    HUD_COLOUR_CHOP = 162,
    HUD_COLOUR_PAUSEMAP_TINT_HALF = 163,
    HUD_COLOUR_NORTH_BLUE_OFFICIAL = 164,
    HUD_COLOUR_SCRIPT_VARIABLE_2 = 165,
    HUD_COLOUR_H = 166,
    HUD_COLOUR_HDARK = 167,
    HUD_COLOUR_T = 168,
    HUD_COLOUR_TDARK = 169,
    HUD_COLOUR_HSHARD = 170,
    HUD_COLOUR_CONTROLLER_MICHAEL = 171,
    HUD_COLOUR_CONTROLLER_FRANKLIN = 172,
    HUD_COLOUR_CONTROLLER_TREVOR = 173,
    HUD_COLOUR_CONTROLLER_CHOP = 174,
    HUD_COLOUR_VIDEO_EDITOR_VIDEO = 175,
    HUD_COLOUR_VIDEO_EDITOR_AUDIO = 176,
    HUD_COLOUR_VIDEO_EDITOR_TEXT = 177,
    HUD_COLOUR_HB_BLUE = 178,
    HUD_COLOUR_HB_YELLOW = 179,
    HUD_COLOUR_VIDEO_EDITOR_SCORE = 180,
    HUD_COLOUR_VIDEO_EDITOR_AUDIO_FADEOUT = 181,
    HUD_COLOUR_VIDEO_EDITOR_TEXT_FADEOUT = 182,
    HUD_COLOUR_VIDEO_EDITOR_SCORE_FADEOUT = 183,
    HUD_COLOUR_HEIST_BACKGROUND = 184,
    HUD_COLOUR_VIDEO_EDITOR_AMBIENT = 185,
    HUD_COLOUR_VIDEO_EDITOR_AMBIENT_FADEOUT = 186,
    HUD_COLOUR_GB = 187,
    HUD_COLOUR_G = 188,
    HUD_COLOUR_B = 189,
    HUD_COLOUR_LOW_FLOW = 190,
    HUD_COLOUR_LOW_FLOW_DARK = 191,
    HUD_COLOUR_G1 = 192,
    HUD_COLOUR_G2 = 193,
    HUD_COLOUR_G3 = 194,
    HUD_COLOUR_G4 = 195,
    HUD_COLOUR_G5 = 196,
    HUD_COLOUR_G6 = 197,
    HUD_COLOUR_G7 = 198,
    HUD_COLOUR_G8 = 199,
    HUD_COLOUR_G9 = 200,
    HUD_COLOUR_G10 = 201,
    HUD_COLOUR_G11 = 202,
    HUD_COLOUR_G12 = 203,
    HUD_COLOUR_G13 = 204,
    HUD_COLOUR_G14 = 205,
    HUD_COLOUR_G15 = 206,
    HUD_COLOUR_ADVERSARY = 207,
    HUD_COLOUR_DEGEN_RED = 208,
    HUD_COLOUR_DEGEN_YELLOW = 209,
    HUD_COLOUR_DEGEN_GREEN = 210,
    HUD_COLOUR_DEGEN_CYAN = 211,
    HUD_COLOUR_DEGEN_BLUE = 212,
    HUD_COLOUR_DEGEN_MAGENTA = 213,
    HUD_COLOUR_STUNT_1 = 214,
    HUD_COLOUR_STUNT_2 = 215,
    HUD_COLOUR_SPECIAL_RACE_SERIES = 216,
    HUD_COLOUR_SPECIAL_RACE_SERIES_DARK = 217,
    HUD_COLOUR_CS = 218,
    HUD_COLOUR_CS_DARK = 219,
    HUD_COLOUR_TECH_GREEN = 220,
    HUD_COLOUR_TECH_GREEN_DARK = 221,
    HUD_COLOUR_TECH_RED = 222,
    HUD_COLOUR_TECH_GREEN_VERY_DARK = 223,
}


--///////////////////////////////////////--
Marker = setmetatable({}, Marker)
Marker.__index = Marker
Marker.__call = function()
    return "Marker", "Marker"
end

function Marker.New(type, position, scale, distance, color, placeOnGround, bobUpDown, rotate, faceCamera, checkZ)
    _marker = {
        MarkerType = type or 0,
        Position = position or vector3(0,0,0),
        Scale = scale or vector3(1, 1, 1),
        Direction = vector3(0,0,0),
        Rotation = vector3(0,0,0),
        Distance = distance or 250.0,
        Color = color,
        PlaceOnGround = placeOnGround,
        BobUpDown = bobUpDown or false,
        Rotate = rotate or false,
        FaceCamera = faceCamera and not rotate or false,
        _height = 0,
        IsInMarker = false,
        CheckZ = checkZ or false,
    }
    return setmetatable(_marker, Marker)
end

function Marker:Draw()
    -- [Position.Z != _height] means that we make the check only if we change position
    -- but if we change position and the Z is still the same then we don't need to check again
    -- We draw it with _height + 0.1 to ensure marker drawing (like horizontal circles)

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped, true)
    if(self:IsInRange() and self.PlaceOnGround and self.Position.z ~= self._height +0.1) then
        local success, height = GetGroundZFor_3dCoord(self.Position.x, self.Position.y, self.Position.z, false)
        self._height = height
        if(success) then
            self.Position = vector3(self.Position.x, self.Position.y, height+0.03)
        end
    end
    DrawMarker(self.MarkerType, self.Position, self.Direction, self.Rotation, self.Scale, self.Color.R, self.Color.G, self.Color.B, self.Color.A, self.BobUpDown, self.FaceCamera, 2, self.Rotate, nil,nil, false)
    local dist = vector3(0, 0, 0)
    if(self.CheckZ) then
        self.IsInMarker = ((pedPos.x - self.Position.x)^2 + (pedPos.y - self.Position.y)^2 + (pedPos.z - self.Position.z)^2) < #self.Scale/2
    else
        self.IsInMarker = ((pedPos.x - self.Position.x)^2 + (pedPos.y - self.Position.y)^2) < #self.Scale/2
    end
end

function Marker:IsInRange()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local dist = vector3(0, 0, 0)
    if(self.CheckZ) then
        dist = #(pos - self.Position) -- Use Z
    else
        dist = #(pos.xy - self.Position.xy) -- Do not use Z
    end
    return dist <= self.Distance
end

function Marker:SetColor(r, g, b, a)
    self.Color = {R=r,G=g,B=b,A=a}
end


--///////////////////////////////////////--
Notifications = setmetatable({}, Notifications)
Notifications.__index = Notifications
Notifications.__call = function()
    return "Notifications", "Notifications"
end

function Notifications.New()
    _notif = {
        _handle = 0,
        Type = {
            Default = 0,
            Bubble = 1,
            Mail = 2,
            FriendRequest = 3,
            Default2 = 4,
            Reply = 7,
            ReputationPoints = 8,
            Money = 9
        },
        Color = {
            Red = 27,
            Yellow = 50,
            Gold = 12,
            GreenLight = 46,
            GreenDark = 47,
            Cyan = 48,
            Blue = 51,
            Purple = 49,
            Rose = 45
        },
        NotificationIcon = {
            ChatBox = 1,
            Email = 2,
            AdDFriendRequest = 3,
            RightJumpingArrow = 7,
            RPIcon = 8,
            DollarIcon = 9           
        },
        IconChars = {
            Abigail = "CHAR_ABIGAIL",
            Amanda = "CHAR_AMANDA",
            Ammunation = "CHAR_AMMUNATION",
            Andreas = "CHAR_ANDREAS",
            Antonia = "CHAR_ANTONIA",
            Ashley = "CHAR_ASHLEY",
            BankOfLiberty = "CHAR_BANK_BOL",
            BankFleeca = "CHAR_BANK_FLEECA",
            BankMaze = "CHAR_BANK_MAZE",
            Barry = "CHAR_BARRY",
            Beverly = "CHAR_BEVERLY",
            BikeSite = "CHAR_BIKESITE",
            BlankEntry = "CHAR_BLANK_ENTRY",
            Blimp = "CHAR_BLIMP",
            Blocked = "CHAR_BLOCKED",
            BoatSite = "CHAR_BOATSITE",
            BrokenDownGirl = "CHAR_BROKEN_DOWN_GIRL",
            BugStars = "CHAR_BUGSTARS",
            Call911 = "CHAR_CALL911",
            LegendaryMotorsport = "CHAR_CARSITE",
            SSASuperAutos = "CHAR_CARSITE2",
            Castro = "CHAR_CASTRO",
            ChatCall = "CHAR_CHAT_CALL",
            Chef = "CHAR_CHEF",
            Cheng = "CHAR_CHENG",
            ChengSenior = "CHAR_CHENGSR",
            Chop = "CHAR_CHOP",
            Cris = "CHAR_CRIS",
            Dave = "CHAR_DAVE",
            Default = "CHAR_DEFAULT",
            Denise = "CHAR_DENISE",
            DetonateBomb = "CHAR_DETONATEBOMB",
            DetonatePhone = "CHAR_DETONATEPHONE",
            Devin = "CHAR_DEVIN",
            SubMarine = "CHAR_DIAL_A_SUB",
            Dom = "CHAR_DOM",
            DomesticGirl = "CHAR_DOMESTIC_GIRL",
            Dreyfuss = "CHAR_DREYFUSS",
            DrFriedlander = "CHAR_DR_FRIEDLANDER",
            Epsilon = "CHAR_EPSILON",
            EstateAgent = "CHAR_ESTATE_AGENT",
            Facebook = "CHAR_FACEBOOK",
            FilmNoire = "CHAR_FILMNOIR",
            Floyd = "CHAR_FLOYD",
            Franklin = "CHAR_FRANKLIN",
            FranklinTrevor = "CHAR_FRANK_TREV_CONF",
            GayMilitary = "CHAR_GAYMILITARY",
            Hao = "CHAR_HAO",
            HitcherGirl = "CHAR_HITCHER_GIRL",
            Hunter = "CHAR_HUNTER",
            Jimmy = "CHAR_JIMMY",
            JimmyBoston = "CHAR_JIMMY_BOSTON",
            Joe = "CHAR_JOE",
            Josef = "CHAR_JOSEF",
            Josh = "CHAR_JOSH",
            LamarDog = "CHAR_LAMAR",
            Lester = "CHAR_LESTER",
            Skull = "CHAR_LESTER_DEATHWISH",
            LesterFranklin = "CHAR_LEST_FRANK_CONF",
            LesterMichael = "CHAR_LEST_MIKE_CONF",
            LifeInvader = "CHAR_LIFEINVADER",
            LsCustoms = "CHAR_LS_CUSTOMS",
            LSTI = "CHAR_LS_TOURIST_BOARD",
            Manuel = "CHAR_MANUEL",
            Marnie = "CHAR_MARNIE",
            Martin = "CHAR_MARTIN",
            MaryAnn = "CHAR_MARY_ANN",
            Maude = "CHAR_MAUDE",
            Mechanic = "CHAR_MECHANIC",
            Michael = "CHAR_MICHAEL",
            MichaelFranklin = "CHAR_MIKE_FRANK_CONF",
            MichaelTrevor = "CHAR_MIKE_TREV_CONF",
            WarStock = "CHAR_MILSITE",
            Minotaur = "CHAR_MINOTAUR",
            Molly = "CHAR_MOLLY",
            MorsMutual = "CHAR_MP_MORS_MUTUAL",
            ArmyContact = "CHAR_MP_ARMY_CONTACT",
            Brucie = "CHAR_MP_BRUCIE",
            FibContact = "CHAR_MP_FIB_CONTACT",
            RockStarLogo = "CHAR_MP_FM_CONTACT",
            Gerald = "CHAR_MP_GERALD",
            Julio = "CHAR_MP_JULIO",
            MechanicChinese = "CHAR_MP_MECHANIC",
            MerryWeather = "CHAR_MP_MERRYWEATHER",
            Unicorn = "CHAR_MP_STRIPCLUB_PR",
            Mom = "CHAR_MRS_THORNHILL",
            MrsThornhill = "CHAR_MRS_THORNHILL",
            PatriciaTrevor = "CHAR_PATRICIA",
            PegasusDelivery = "CHAR_PEGASUS_DELIVERY",
            ElitasTravel = "CHAR_PLANESITE",
            Sasquatch = "CHAR_SASQUATCH",
            Simeon = "CHAR_SIMEON",
            SocialClub = "CHAR_SOCIAL_CLUB",
            Solomon = "CHAR_SOLOMON",
            Taxi = "CHAR_TAXI",
            Trevor = "CHAR_TREVOR",
            YouTube = "CHAR_YOUTUBE",
            Wade = "CHAR_WADE",
        }
    }
    return setmetatable(_notif, Notifications)
end

function Notifications:Hide()
    ThefeedRemoveItem(self._handle)
end

function Notifications:ShowNotification(msg, blink, showBrief)
    AddTextEntry("ScaleformUINotification", msg)
    BeginTextCommandThefeedPost("ScaleformUINotification")
    _handle = EndTextCommandThefeedPostTicker(blink, showBriefing)
end

function Notifications:ShowNotificationWithColor(msg, color, blink, showBrief)
    AddTextEntry("ScaleformUINotification", msg)
    BeginTextCommandThefeedPost("ScaleformUINotification")
    ThefeedNextPostBackgroundColor(color)
   _handle = EndTextCommandThefeedPostTicker(blink, showBriefing)
end

function Notifications:ShowHelpNotification(helpText, time)
    AddTextEntry("ScaleformUIHelpText", helpText)
    if(time ~= nil) then
        if (time > 5000) then time = 5000 end
        BeginTextCommandDisplayHelp("ScaleformUIHelpText")
        EndTextCommandDisplayHelp(0, false, true, time)
    else
        DisplayHelpTextThisFrame("ScaleformUIHelpText", false)
    end
end

function Notifications:ShowFloatingHelpNotification(msg, coords, time)
   if(time == nil) then time = -1 end 
    AddTextEntry("ScaleformUIFloatingHelpText", msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("ScaleformUIFloatingHelpText")
    EndTextCommandDisplayHelp(2, false, false, time)
end

function Notifications:ShowAdvancedNotification(title, subtitle, text, iconSet, icon, bgColor, flashColor, blink, type, sound)
    if(type == nil) then type = self.Type.Default end
    if(iconSet == nil) then iconSet = self.IconChars.Default end
    if(icon == nil) then icon = self.NotificationIcon.Default end
    if(bgColor == nil) then bgColor = -1 end
    if(blink == nil ) then blink = false end
    AddTextEntry("ScaleformUIAdvancedNotification", text)
    BeginTextCommandThefeedPost("ScaleformUIAdvancedNotification")
    AddTextComponentSubstringPlayerName(text)
    if (bgColor and bgColor ~= -1) then
        SetNotificationBackgroundColor(bgColor)
    end
    if (flashColor and not blink) then
        SetNotificationFlashColor(flashColor.R, flashColor.G, flashColor.B, flashColor.A)
    end
    if (sound) then Audio.PlaySoundFrontend("DELETE", "HUD_DEATHMATCH_SOUNDSET") end
    return EndTextCommandThefeedPostMessagetext(iconSet, icon, true, type, title, subtitle)
end

function Notifications:ShowStatNotification(newProgress, oldProgress, title, blink, showBrief)
    if(blink == nil) then blink = false end
    if(showBrief == nil) then showBrief = false end
    AddTextEntry("ScaleformUIStatsNotification", title)
    local handle = RegisterPedheadshot(PlayerPedId())
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do Citizen.Wait(0) end
    local txd = GetPedheadshotTxdString(handle)
    BeginTextCommandThefeedPost("PS_UPDATE")
    AddTextComponentInteger(newProgress)
    EndTextCommandThefeedPostStats("ScaleformUIStatsNotification", 2, newProgress, oldProgress, false, txd, txd)
    EndTextCommandThefeedPostTicker(blink, showBrief)
    UnregisterPedheadshot(handle)
end

function Notifications:ShowVSNotification(ped1, ped2, color1, color2)
    local handle_1 = RegisterPedheadshot(ped1)
    while not IsPedheadshotReady(handle_1) or not IsPedheadshotValid(handle_1) do Citizen.Wait(0) end
    local txd_1 = GetPedheadshotTxdString(handle_1)

    local handle_2 = RegisterPedheadshot(ped2)
    while not IsPedheadshotReady(handle_2) or not IsPedheadshotValid(handle_2) do Citizen.Wait(0) end
    local txd_2 = GetPedheadshotTxdString(handle_2)

    BeginTextCommandThefeedPost("")
    EndTextCommandThefeedPostVersusTu(txd_1, txd_1, 12, txd_2, txd_2, 1, color1, color2)

    UnregisterPedheadshot(handle_1)
    UnregisterPedheadshot(handle_2)
end

function Notifications:DrawText3D(coords, color, text, font, size)
    local cam = GetGameplayCamCoord()
    local dist = #(coords - cam)
    local scaleInternal = (1 / dist) * size
    local fov = (1 / GetGameplayCamFov()) * 100
    local _scale = scaleInternal * fov
    SetTextScale(0.1 * _scale, 0.15 * _scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(color.R, color.G, color.B, color.A)
    SetTextDropshadow(5, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0, 0)
    ClearDrawOrigin()
end

function Notifications:DrawText(x, y, text, color, font, textAlignment, shadow, outline, wrap)
    if(color == nil) then color = {r=255, g=255, b=255, a=255} end
    if(font == nil) then font = 4 end
    if(textAlignment == nil) then textAlignment = 1 end
    if(shadow == nil) then shadow = false end
    if(outline == nil) then outline = false end
    if(wrap == nil) then wrap = 0 end

    local screenw, screenh = GetScreenActiveResolution()
    local height = 1080
    local ratio = screenw / screenh
    local width = height * ratio

    SetTextFont(font)
    SetTextScale(0.0, 0.5)
    SetTextColour(color.r, color.g, color.b, color.a)
    if (shadow) then SetTextDropShadow() end
    if (outline) then SetTextOutline() end
    if (wrap ~= 0) then
        local xsize = (x + Wrap) / width
        SetTextWrap(x, xsize)
    end
    if (TextAlignment == 0) then
            SetTextCentre(true)
    elseif(TextAlignment == 2) then
            SetTextRightJustify(true)
            SetTextWrap(0, x)
    end
    BeginTextCommandDisplayText("jamyfafi")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

function Notifications:ShowSubtitle(msg, time)
    if(time == nil) then time = 2500 end
    AddTextEntry("ScaleformUISubtitle", msg)
    BeginTextCommandPrint("ScaleformUISubtitle")
    EndTextCommandPrint(time, true)
end


--///////////////////////////////////////--
UIMenuCheckboxItem = setmetatable({}, UIMenuCheckboxItem)
UIMenuCheckboxItem.__index = UIMenuCheckboxItem
UIMenuCheckboxItem.__call = function() return "UIMenuItem", "UIMenuCheckboxItem" end

---New
---@param Text string
---@param Check boolean
---@param Description string
function UIMenuCheckboxItem.New(Text, Check, checkStyle, Description, color, highlightColor, textColor, highlightedTextColor)
	local _UIMenuCheckboxItem = {
		Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		_Checked = tobool(Check),
		Panels = {},
		SidePanel = nil,
		CheckBoxStyle = checkStyle or 0,
		OnCheckboxChanged = function(menu, item, checked) end,
	}
	return setmetatable(_UIMenuCheckboxItem, UIMenuCheckboxItem)
end

---SetParentMenu
---@param Menu table
function UIMenuCheckboxItem:SetParentMenu(Menu)
	if Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuCheckboxItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
	        ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
        self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool boolean
function UIMenuCheckboxItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuCheckboxItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuCheckboxItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

---Description
---@param str string
function UIMenuCheckboxItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

function UIMenuCheckboxItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---Text
---@param Text string
function UIMenuCheckboxItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuCheckboxItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuCheckboxItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuCheckboxItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuCheckboxItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---LeftBadge
function UIMenuCheckboxItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuCheckboxItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuCheckboxItem:RightLabel()
	error("This item does not support a right label")
end

function UIMenuCheckboxItem:Checked(bool)
	if bool ~= nil then
		self._Checked = tobool(bool)
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
			local it = IndexOf(self.Base.ParentMenu.Items, self) - 1
			ScaleformUI.Scaleforms._ui:CallFunction("SET_INPUT_EVENT", false, 16, it, self._Checked)
		end
	else
		return self._Checked
	end
end


--///////////////////////////////////////--
UIMenuDynamicListItem = setmetatable({}, UIMenuDynamicListItem)
UIMenuDynamicListItem.__index = UIMenuDynamicListItem
UIMenuDynamicListItem.__call = function() return "UIMenuItem", "UIMenuDynamicListItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
function UIMenuDynamicListItem.New(Text, Description, StartingItem, callback, color, highlightColor, textColor, highlightedTextColor)
	local _UIMenuDynamicListItem = {
		Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		Panels = {},
		SidePanel = nil,
        _currentItem = StartingItem,
        Callback = callback,
		OnListSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_UIMenuDynamicListItem, UIMenuDynamicListItem)
end

function UIMenuDynamicListItem:CurrentListItem(item)
    if item == nil then
        return tostring(self._currentItem)
    else
        self._currentItem = item
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_LISTITEM_LIST", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, tostring(self._currentItem), 0)
        end
    end
end

---SetParentMenu
---@param Menu table
function UIMenuDynamicListItem:SetParentMenu(Menu)
	if Menu ~= nil and Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuDynamicListItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
        self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool boolean
function UIMenuDynamicListItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuDynamicListItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuDynamicListItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

---Description
---@param str string
function UIMenuDynamicListItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

function UIMenuDynamicListItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---Text
---@param Text string
function UIMenuDynamicListItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuDynamicListItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuDynamicListItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuDynamicListItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuDynamicListItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---LeftBadge
function UIMenuDynamicListItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuDynamicListItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuDynamicListItem:RightLabel()
	error("This item does not support a right label")
end

---AddPanel
---@param Panel table
function UIMenuDynamicListItem:AddPanel(Panel)
	if Panel() == "UIMenuPanel" then
		table.insert(self.Panels, Panel)
		Panel:SetParentItem(self)
	end
end

---RemovePanelAt
---@param Index table
function UIMenuDynamicListItem:RemovePanelAt(Index)
	if tonumber(Index) then
		if self.Panels[Index] then
			table.remove(self.Panels, tonumber(Index))
		end
	end
end

---FindPanelIndex
---@param Panel table
function UIMenuDynamicListItem:FindPanelIndex(Panel)
	if Panel() == "UIMenuPanel" then
		for Index = 1, #self.Panels do
			if self.Panels[Index] == Panel then
				return Index
			end
		end
	end
	return nil
end

---FindPanelItem
function UIMenuDynamicListItem:FindPanelItem()
	for Index = #self.Items, 1, -1 do
		if self.Items[Index].Panel then
			return Index
		end
	end
	return nil
end


--///////////////////////////////////////--
UIMenuItem = setmetatable({}, UIMenuItem)
UIMenuItem.__index = UIMenuItem
UIMenuItem.__call = function()
    return "UIMenuItem", "UIMenuItem"
end

function UIMenuItem.New(text, description, color, highlightColor, textColor, highlightedTextColor)
    _UIMenuItem = {
        _label = tostring(text) or "",
        _Description = tostring(description) or "",
        _Selected = false,
        _Hovered = false,
        _Enabled = true,
        blinkDescription = false,
        _formatLeftLabel = tostring(text) or "",
        _rightLabel = "",
        _formatRightLabel = "",
        _rightBadge = 0,
        _leftBadge = 0,
        _mainColor = color or 117,
        _highlightColor = highlightColor or 1,
        _textColor = textColor or 1,
        _highlightedTextColor = highlightedTextColor or 2,
        ParentMenu = nil,
        Panels = {},
        SidePanel = nil,
        Activated = function(menu, item)
        end,
    }
    return setmetatable(_UIMenuItem, UIMenuItem)
end

function UIMenuItem:SetParentMenu(Menu)
    if Menu ~= nil and Menu() == "UIMenu" then
        self.ParentMenu = Menu
    else
        return self.ParentMenu
    end
end

function UIMenuItem:Selected(bool, item)
    if bool ~= nil then
        if item == nil then item = self end
       
        self._Selected = tobool(bool)
        if self._Selected then
            if(self._highlightedTextColor == 2) then
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~l~")
                end
                if self._formatLeftLabel:find("~", 1, true) then
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~w~", "~l~")
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~s~", "~l~")
                end
                if not string.IsNullOrEmpty(self._formatRightLabel) then
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~l~")
                    end
                    if self._formatRightLabel:find("~", 1, true) then
                        self._formatRightLabel = self._formatRightLabel:gsub("~w~", "~l~")
                        self._formatRightLabel = self._formatRightLabel:gsub("~s~", "~l~")
                    end
                end
            end
        else
            if(self._textColor == 1) then
                self._formatLeftLabel = self._formatLeftLabel:gsub("~l~", "~s~")
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~s~")
                end
                if not string.IsNullOrEmpty(self._formatRightLabel) then
                    self._formatRightLabel = self._formatRightLabel:gsub("~l~", "~s~")
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~s~")
                    end
                end
            end
        end
        if self.ParentMenu ~= nil and self._textColor == 1 and self._highlightedTextColor == 2 and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_LABELS", false, IndexOf(self.ParentMenu.Items, item) - 1,  self._formatLeftLabel, self._formatRightLabel)
        end
    else
        return self._Selected
    end
end

function UIMenuItem:Hovered(bool)
    if bool ~= nil then
        self._Hovered = tobool(bool)
    else
        return self._Hovered
    end
end

function UIMenuItem:Enabled(bool, item)
    if bool ~= nil then
        if item == nil then item = self end
        self._Enabled = tobool(bool)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ENABLE_ITEM", false, IndexOf(self.ParentMenu.Items, item) - 1,  self._Enabled)
        end
    else
        return self._Enabled
    end
end

function UIMenuItem:Activated(menu, item)
    self.Activated(menu, item)
end

function UIMenuItem:Description(str, item)
    if tostring(str) and str ~= nil then
        if item == nil then item = self end
        self._Description = tostring(str)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            AddTextEntry("desc_{" .. IndexOf(self.ParentMenu.Items, item) .."}", str)
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_ITEM_DESCRIPTION", false, IndexOf(self.ParentMenu.Items, item) - 1, "desc_{" .. IndexOf(self.ParentMenu.Items, self) .."}")
        end
    else
        return self._Description
    end
end

function UIMenuItem:MainColor(color, item)
    if(color)then
        if item == nil then item = self end
        self._mainColor = color
        if(self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1, self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._mainColor
    end
end

function UIMenuItem:TextColor(color, item)
    if(color)then
        if item == nil then item = self end
        self._textColor = color
        if(self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1, self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._textColor
    end
end

function UIMenuItem:HighlightColor(color, item)
    if(color)then
        if item == nil then item = self end
        self._highlightColor = color
        if(self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1, self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._highlightColor
    end
end

function UIMenuItem:HighlightedTextColor(color, item)
    if(color)then
        if item == nil then item = self end
        self._highlightedTextColor = color
        if(self.ParentMenu ~= nil and self.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.ParentMenu.Items, item) - 1, self._mainColor, self._highlightColor, self._textColor, self._highlightedTextColor)
        end
    else
        return self._highlightedTextColor
    end
end

function UIMenuItem:Label(Text, item)
    if tostring(Text) and Text ~= nil then
        if item == nil then item = self end
        self._label = (tostring(Text))
        self._formatLeftLabel = (tostring(Text))
        if self:Selected() then
            if(self._highlightedTextColor == 2) then
                if self._formatLeftLabel:find("~") then
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~w~", "~l~")
                    self._formatLeftLabel = self._formatLeftLabel:gsub("~s~", "~l~")
                    if not self._formatLeftLabel:StartsWith("~") then
                        self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~l~")
                    end
                end
            end
        else
            if(self._textColor == 1) then
                self._formatLeftLabel = self._formatLeftLabel:gsub("~l~", "~s~")
                if not self._formatLeftLabel:StartsWith("~") then
                    self._formatLeftLabel = self._formatLeftLabel:Insert(0, "~s~")
                end
            end
        end
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() and self._textColor == 1 and self._highlightedTextColor == 2 then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_LABEL", false, IndexOf(self.ParentMenu.Items, item) - 1,  self._formatLeftLabel)
        end
    else
        return self._label
    end
end

function UIMenuItem:RightLabel(Text)
    if tostring(Text) and Text ~= nil then
        self._rightLabel = tostring(Text)
        self._formatRightLabel = tostring(Text)
        if self:Selected() then
            if(self._highlightedTextColor == 2) then
                if self._formatRightLabel:find("~") then
                    self._formatRightLabel = self._formatRightLabel:gsub("~w~", "~l~")
                    self._formatRightLabel = self._formatRightLabel:gsub("~s~", "~l~")
                    if not self._formatRightLabel:StartsWith("~") then
                        self._formatRightLabel = self._formatRightLabel:Insert(0, "~l~")
                    end
                end
            end
        else
            if(self._textColor == 1) then
                self._formatRightLabel = self._formatRightLabel:gsub("~l~", "~s~")
                if not self._formatRightLabel:StartsWith("~") then
                    self._formatRightLabel = self._formatRightLabel:Insert(0, "~s~")
                end
            end
        end
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() and self._textColor == 1 and self._highlightedTextColor == 2 then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", false, IndexOf(self.ParentMenu.Items, self) - 1,  self._formatRightLabel)
        end
    else
        return self._rightLabel
    end
end

function UIMenuItem:RightBadge(Badge, item)
    if tonumber(Badge) then
        if item == nil then item = self end
        self._rightBadge = tonumber(Badge)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", false, IndexOf(self.ParentMenu.Items, item) - 1, self._rightBadge)
        end
    else
        return self._rightBadge
    end
end

function UIMenuItem:LeftBadge(Badge, item)
    if tonumber(Badge) then
        if item == nil then item = self end
        self._leftBadge = tonumber(Badge)
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_LEFT_BADGE", false, IndexOf(self.ParentMenu.Items, item) - 1, self._leftBadge)
        end
    else
        return self._leftBadge
    end
end

function UIMenuItem:AddPanel(Panel)
    if Panel() == "UIMenuPanel" then
        table.insert(self.Panels, Panel)
        Panel:SetParentItem(self)
    end
end

function UIMenuItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
        end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
        end
    end
end

function UIMenuItem:RemoveSidePanel()
    self.SidePanel = nil
    if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
        ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1)
    end
end


function UIMenuItem:RemovePanelAt(Index)
    if tonumber(Index) then
        if self.Panels[Index] then
            table.remove(self.Panels, tonumber(Index))
        end
    end
end

function UIMenuItem:FindPanelIndex(Panel)
    if Panel() == "UIMenuPanel" then
        for Index = 1, #self.Panels do
            if self.Panels[Index] == Panel then
                return Index
            end
        end
    end
    return nil
end

function UIMenuItem:FindPanelItem()
    for Index = #self.Items, 1, -1 do
        if self.Items[Index].Panel then
            return Index
        end
    end
    return nil
end

function UIMenuItem:BlinkDescription(bool, item)
    if bool ~= nil then
        if item == nil then item = self end
        self.blinkDescription = bool
        if self.ParentMenu ~= nil and self.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_BLINK_DESC", false, IndexOf(self.ParentMenu.Items, item) - 1, self.blinkDescription)
        end
    else
        return self.blinkDescription
    end
end


--///////////////////////////////////////--
UIMenuListItem = setmetatable({}, UIMenuListItem)
UIMenuListItem.__index = UIMenuListItem
UIMenuListItem.__call = function() return "UIMenuItem", "UIMenuListItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
function UIMenuListItem.New(Text, Items, Index, Description, color, highlightColor, textColor, highlightedTextColor)
	if type(Items) ~= "table" then Items = {} end
	if Index == 0 then Index = 1 end
	local _UIMenuListItem = {
		Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		Items = Items,
		_Index = tonumber(Index) or 1,
		Panels = {},
		SidePanel = nil,
		OnListChanged = function(menu, item, newindex) end,
		OnListSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_UIMenuListItem, UIMenuListItem)
end

---SetParentMenu
---@param Menu table
function UIMenuListItem:SetParentMenu(Menu)
	if Menu ~= nil and Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuListItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
		self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool boolean
function UIMenuListItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuListItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuListItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

---Description
---@param str string
function UIMenuListItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(str, self)
	else
		return self.Base._Description
	end
end

function UIMenuListItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---Text
---@param Text string
function UIMenuListItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuListItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuListItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuListItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuListItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end
---Index
---@param Index table
function UIMenuListItem:Index(Index)
	if tonumber(Index) then
		local ind = Index+1
		if ind > #self.Items then
			self._Index = 1
		elseif ind < 1 then
			self._Index = #self.Items
		else
			self._Index = ind
		end
	else
		return self._Index
	end
end

---ItemToIndex
---@param Item table
function UIMenuListItem:ItemToIndex(Item)
	for i = 1, #self.Items do
		if type(Item) == type(self.Items[i]) and Item == self.Items[i] then
			return i
		elseif type(self.Items[i]) == "table" and (type(Item) == type(self.Items[i].Name) or type(Item) == type(self.Items[i].Value)) and (Item == self.Items[i].Name or Item == self.Items[i].Value) then
			return i
		end
	end
end

---IndexToItem
---@param Index table
function UIMenuListItem:IndexToItem(Index)
	if tonumber(Index) then
		if tonumber(Index) == 0 then Index = 1 end
		if self.Items[tonumber(Index)] then
			return self.Items[tonumber(Index)]
		end
	end
end

---LeftBadge
function UIMenuListItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuListItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuListItem:RightLabel()
	error("This item does not support a right label")
end

---AddPanel
---@param Panel table
function UIMenuListItem:AddPanel(Panel)
	if Panel() == "UIMenuPanel" then
		table.insert(self.Panels, Panel)
		Panel:SetParentItem(self)
	end
end

---RemovePanelAt
---@param Index table
function UIMenuListItem:RemovePanelAt(Index)
	if tonumber(Index) then
		if self.Panels[Index] then
			table.remove(self.Panels, tonumber(Index))
		end
	end
end

---FindPanelIndex
---@param Panel table
function UIMenuListItem:FindPanelIndex(Panel)
	if Panel() == "UIMenuPanel" then
		for Index = 1, #self.Panels do
			if self.Panels[Index] == Panel then
				return Index
			end
		end
	end
	return nil
end

---FindPanelItem
function UIMenuListItem:FindPanelItem()
	for Index = #self.Items, 1, -1 do
		if self.Items[Index].Panel then
			return Index
		end
	end
	return nil
end

function UIMenuListItem:ChangeList(list)
	if type(list) ~= "table" then return end
	self.Items = {}
	self.Items = list
    if self.Base.ParentMenu:Visible() then
    	ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_LISTITEM_LIST", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, table.concat(self.Items, ","), self._Index)
    end
end


--///////////////////////////////////////--
UIMenuProgressItem = setmetatable({}, UIMenuProgressItem)
UIMenuProgressItem.__index = UIMenuProgressItem
UIMenuProgressItem.__call = function() return "UIMenuItem", "UIMenuProgressItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
---@param Counter boolean
function UIMenuProgressItem.New(Text, Max, Index, Description, sliderColor, color, highlightColor, textColor, highlightedTextColor)
	local _UIMenuProgressItem = {
		Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		_Max = Max or 100,
		_Multiplier = 5,
		_Index = Index or 0,
		Panels = {},
		SidePanel = nil,
		SliderColor = sliderColor or 116,
		BackgroundSliderColor = backgroundSliderColor or 117,
		OnProgressChanged = function(menu, item, newindex) end,
		OnProgressSelected = function(menu, item, newindex) end,
	}

	return setmetatable(_UIMenuProgressItem, UIMenuProgressItem)
end

---SetParentMenu
---@param Menu table
function UIMenuProgressItem:SetParentMenu(Menu)
	if Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuProgressItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
        self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool number
function UIMenuProgressItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuProgressItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuProgressItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

---Description
---@param str string
function UIMenuProgressItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

---Text
---@param Text string
function UIMenuProgressItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuProgressItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuProgressItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuProgressItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuProgressItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuProgressItem:SliderColor(color)
    if(color)then
        self.SliderColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor, self.SliderColor)
        end
    else
        return self.SliderColor
    end
end


function UIMenuProgressItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---Index
---@param Index table
function UIMenuProgressItem:Index(Index)
	if tonumber(Index) then
		if Index > self._Max then
			self._Index = self._Max
		elseif Index < 0 then
			self._Index = 0
		else
			self._Index = Index
		end
		self.OnProgressChanged(self._Index)
	else
		return self._Index
	end
end

---LeftBadge
function UIMenuProgressItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

---RightBadge
function UIMenuProgressItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuProgressItem:RightLabel()
	error("This item does not support a right label")
end


--///////////////////////////////////////--
UIMenuSeperatorItem = setmetatable({}, UIMenuSeperatorItem)
UIMenuSeperatorItem.__index = UIMenuSeperatorItem
UIMenuSeperatorItem.__call = function() return "UIMenuItem", "UIMenuSeperatorItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
---@param Counter boolean
function UIMenuSeperatorItem.New(Text, jumpable , mainColor, highlightColor, textColor, highlightedTextColor)
	local _UIMenuSeperatorItem = {
		Base = UIMenuItem.New(Text or "", "", mainColor or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		Panels = {},
		SidePanel = nil,
        Jumpable = jumpable
	}
	return setmetatable(_UIMenuSeperatorItem, UIMenuSeperatorItem)
end

---SetParentMenu
---@param Menu table
function UIMenuSeperatorItem:SetParentMenu(Menu)
	if Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

---Description
---@param str string
function UIMenuSeperatorItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

---Text
---@param Text string
function UIMenuSeperatorItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuSeperatorItem:MainColor(color)
    if color ~= nil then
        self.Base._mainColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuSeperatorItem:TextColor(color)
    if color ~= nil then
        self.Base._textColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuSeperatorItem:HighlightColor(color)
    if color ~= nil then
        self.Base._highlightColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuSeperatorItem:HighlightedTextColor(color)
    if color ~= nil then
        self.Base._highlightedTextColor = color
        if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

---Selected
---@param bool number
function UIMenuSeperatorItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuSeperatorItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuSeperatorItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

function UIMenuSeperatorItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---LeftBadge
function UIMenuProgressItem:LeftBadge()
	error("This item does not support badges")
end

---RightBadge
function UIMenuProgressItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuProgressItem:RightLabel()
	error("This item does not support a right label")
end


--///////////////////////////////////////--
UIMenuSliderItem = setmetatable({}, UIMenuSliderItem)
UIMenuSliderItem.__index = UIMenuSliderItem
UIMenuSliderItem.__call = function() return "UIMenuItem", "UIMenuSliderItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
---@param Divider boolean
---@param SliderColors table
---@param BackgroundSliderColors table
function UIMenuSliderItem.New(Text, Max, Multiplier, Index, Heritage, Description, sliderColor, color, highlightColor, textColor, highlightedTextColor)
	local _UIMenuSliderItem = {
		Base = UIMenuItem.New(Text or "", Description or "", color or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		_Index = tonumber(Index) or 0,
		_Max = tonumber(Max) or 100,
		_Multiplier = Multiplier or 5,
		_heritage = Heritage or false,
		Panels = {},
		SidePanel = nil,
		SliderColor = sliderColor or 116,
		OnSliderChanged = function(menu, item, newindex) end,
		OnSliderSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_UIMenuSliderItem, UIMenuSliderItem)
end

---SetParentMenu
---@param Menu table
function UIMenuSliderItem:SetParentMenu(Menu)
	if Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuSliderItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
        self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool table
function UIMenuSliderItem:Selected(bool)
	if bool ~= nil then

		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

function UIMenuSliderItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

function UIMenuSliderItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

function UIMenuSliderItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

function UIMenuSliderItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

function UIMenuSliderItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuSliderItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuSliderItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuSliderItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuSliderItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuSliderItem:SliderColor(color)
    if(color)then
        self.SliderColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor, self.SliderColor)
        end
    else
        return self.SliderColor
    end
end

function UIMenuSliderItem:Index(Index)
	if tonumber(Index) then
		if tonumber(Index) > self._Max then
			self._Index = self._Max
		elseif tonumber(Index) < 0 then
			self._Index = 0
		else
			self._Index = tonumber(Index)
		end
		self.OnSliderChanged(self.ParentMenu, self, self._Index)
	else
		return self._Index
	end
end

function UIMenuSliderItem:LeftBadge(Badge)
    if tonumber(Badge) then
        self.Base:LeftBadge(Badge, self)
    else
        return self.Base:LeftBadge()
    end
end

function UIMenuSliderItem:RightBadge()
	error("This item does not support badges")
end

function UIMenuSliderItem:RightLabel()
	error("This item does not support a right label")
end


--///////////////////////////////////////--
UIMenuStatsItem = setmetatable({}, UIMenuStatsItem)
UIMenuStatsItem.__index = UIMenuStatsItem
UIMenuStatsItem.__call = function() return "UIMenuItem", "UIMenuStatsItem" end

---New
---@param Text string
---@param Items table
---@param Index number
---@param Description string
---@param Counter boolean
function UIMenuStatsItem.New(Text, Description, Index, barColor, type, mainColor, highlightColor, textColor, highlightedTextColor)
	local _UIMenuStatsItem = {
		Base = UIMenuItem.New(Text or "", Description or "", mainColor or 117, highlightColor or 1, textColor or 1, highlightedTextColor or 2),
		_Index = Index or 0,
		Panels = {},
		SidePanel = nil,
		_Color = barColor or 116,
        _Type = type or 0,
		OnStatsChanged = function(menu, item, newindex) end,
		OnStatsSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_UIMenuStatsItem, UIMenuStatsItem)
end

---SetParentMenu
---@param Menu table
function UIMenuStatsItem:SetParentMenu(Menu)
	if Menu() == "UIMenu" then
		self.Base.ParentMenu = Menu
	else
		return self.Base.ParentMenu
	end
end

function UIMenuStatsItem:AddSidePanel(sidePanel)
    if sidePanel() == "UIMissionDetailsPanel" then
        sidePanel:SetParentItem(self)
        self.SidePanel = sidePanel
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, 0, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor, sidePanel.TextureDict, sidePanel.TextureName)
		end
    elseif sidePanel() == "UIVehicleColorPickerPanel" then	
        sidePanel:SetParentItem(self)	
        self.SidePanel = sidePanel	
		if self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible() then
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_SIDE_PANEL_TO_ITEM", false, IndexOf(self.ParentMenu.Items, self) - 1, 1, sidePanel.PanelSide, sidePanel.TitleType, sidePanel.Title, sidePanel.TitleColor)
		end
	end
end

---Selected
---@param bool number
function UIMenuStatsItem:Selected(bool)
	if bool ~= nil then
		self.Base:Selected(tobool(bool), self)
	else
		return self.Base._Selected
	end
end

---Hovered
---@param bool boolean
function UIMenuStatsItem:Hovered(bool)
	if bool ~= nil then
		self.Base._Hovered = tobool(bool)
	else
		return self.Base._Hovered
	end
end

---Enabled
---@param bool boolean
function UIMenuStatsItem:Enabled(bool)
	if bool ~= nil then
		self.Base:Enabled(bool, self)
	else
		return self.Base._Enabled
	end
end

---Description
---@param str string
function UIMenuStatsItem:Description(str)
	if tostring(str) and str ~= nil then
		self.Base:Description(tostring(str), self)
	else
		return self.Base._Description
	end
end

---Text
---@param Text string
function UIMenuStatsItem:Label(Text)
	if tostring(Text) and Text ~= nil then
		self.Base:Label(tostring(Text), self)
	else
		return self.Base:Label()
	end
end

function UIMenuStatsItem:MainColor(color)
    if(color)then
        self.Base._mainColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._mainColor
    end
end

function UIMenuStatsItem:TextColor(color)
    if(color)then
        self.Base._textColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._textColor
    end
end

function UIMenuStatsItem:HighlightColor(color)
    if(color)then
        self.Base._highlightColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightColor
    end
end

function UIMenuStatsItem:HighlightedTextColor(color)
    if(color)then
        self.Base._highlightedTextColor = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor)
        end
    else
        return self.Base._highlightedTextColor
    end
end

function UIMenuStatsItem:SliderColor(color)
    if(color)then
        self._Color = color
        if(self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_COLORS", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self.Base._mainColor, self.Base._highlightColor, self.Base._textColor, self.Base._highlightedTextColor, self._Color)
        end
    else
        return self._Color
    end
end

function UIMenuStatsItem:BlinkDescription(bool)
    if bool ~= nil then
		self.Base:BlinkDescription(bool, self)
	else
		return self.Base:BlinkDescription()
	end
end

---Index
---@param Index table
function UIMenuStatsItem:Index(Index)
	if tonumber(Index) then
		if Index > 100 then
			self._Index = 100
		elseif Index < 0 then
			self._Index = 0
		else
			self._Index = Index
		end
		self.OnStatsChanged(self._Index)
        if (self.Base.ParentMenu ~= nil and self.Base.ParentMenu:Visible()) then
            ScaleformUI.Scaleforms._ui:CallFunction("SET_ITEM_VALUE", false, IndexOf(self.Base.ParentMenu.Items, self) - 1, self._Index)
        end
	else
		return self._Index
	end
end

---LeftBadge
function UIMenuStatsItem:LeftBadge()
	error("This item does not support badges")
end

---RightBadge
function UIMenuStatsItem:RightBadge()
	error("This item does not support badges")
end

---RightLabel
function UIMenuStatsItem:RightLabel()
	error("This item does not support a right label")
end


--///////////////////////////////////////--
UIMenuColorPanel = setmetatable({}, UIMenuColorPanel)
UIMenuColorPanel.__index = UIMenuColorPanel
UIMenuColorPanel.__call = function() return "UIMenuPanel", "UIMenuColorPanel" end

---New
---@param title string
---@param colorType int
---@param startIndex number
function UIMenuColorPanel.New(title, colorType, startIndex, colors)
	if colors ~= nil then
		colorType = 2
	end
	
	_UIMenuColorPanel = {
		Title = title or "Color Panel",
		ColorPanelColorType = colorType,
		value = startIndex or 0,
		CustomColors = colors or nil,
		ParentItem = nil, -- required
		OnColorPanelChanged = function(item, panel, newindex) end
	}
	return setmetatable(_UIMenuColorPanel, UIMenuColorPanel)
end

---SetParentItem
---@param Item table
function UIMenuColorPanel:SetParentItem(Item) -- required
	if not Item() == nil then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end

function UIMenuColorPanel:CurrentSelection(new_value)
	if new_value ~= nil then
		self.value = new_value
		if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
			local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
			local van = IndexOf(self.ParentItem.Panels, self)
			ScaleformUI.Scaleforms._ui:CallFunction("SET_COLOR_PANEL_VALUE", false, it, van, new_value)
		end
	else
		return self.value
	end
end


--///////////////////////////////////////--
UIMenuGridPanel = setmetatable({}, UIMenuGridPanel)
UIMenuGridPanel.__index = UIMenuGridPanel
UIMenuGridPanel.__call = function() return "UIMenuPanel", "UIMenuGridPanel" end

---New
---@param title string
---@param colorType int
---@param startIndex number
function UIMenuGridPanel.New(topText, leftText, rightText, bottomText, circlePosition, gridType)
	_UIMenuGridPanel = {
		TopLabel = topText or "UP",
		RightLabel = leftText or "RIGHT",
		LeftLabel = rightText or "LEFT",
		BottomLabel = bottomText or "DOWN",
		CirclePosition = circlePosition or vector2(0.5, 0.5),
		GridType = gridType or 0,
		ParentItem = nil, -- required
		OnGridPanelChanged = function(item, panel, newindex) end
	}
	return setmetatable(_UIMenuGridPanel, UIMenuGridPanel)
end

---SetParentItem
---@param Item table
function UIMenuGridPanel:SetParentItem(Item) -- required
	if not Item() == nil then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end

function UIMenuGridPanel:CirclePosition(position)
	if position ~= nil then
		self.CirclePosition = position
		if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
			local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
			local van = IndexOf(self.ParentItem.Panels, self)
			ScaleformUI.Scaleforms._ui:CallFunction("SET_GRID_PANEL_VALUE_RETURN_VALUE", false, it, van, position.x, position.y)
		end
	else
		return self.CirclePosition
	end
end


--///////////////////////////////////////--
UIMenuPercentagePanel = setmetatable({}, UIMenuPercentagePanel)
UIMenuPercentagePanel.__index = UIMenuPercentagePanel
UIMenuPercentagePanel.__call = function() return "UIMenuPanel", "UIMenuPercentagePanel" end

---New
---@param title string
---@param colorType int
---@param startIndex number
function UIMenuPercentagePanel.New(title, minText, maxText, initialValue)
	_UIMenuPercentagePanel = {
		Min = minText or "0%",
		Max = maxText or "100%",
		Title = title or "Opacity",
		Percentage = initialValue or 0.0,
		ParentItem = nil, -- required
		OnPercentagePanelChange = function(item, panel, value) end
	}
	return setmetatable(_UIMenuPercentagePanel, UIMenuPercentagePanel)
end

function UIMenuPercentagePanel:Percentage(value)
	if value ~= nil then
		self.Percentage = value
		if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
			local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
			local van = IndexOf(self.ParentItem.Panels, self)
			ScaleformUI.Scaleforms._ui:CallFunction("SET_PERCENT_PANEL_RETURN_VALUE", false, it, van, value)
		end
	else
		return self.Percentage
	end
end

---SetParentItem
---@param Item table
function UIMenuPercentagePanel:SetParentItem(Item) -- required
	if not Item() == nil then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end


--///////////////////////////////////////--
UIMenuStatisticsPanel = setmetatable({}, UIMenuStatisticsPanel)
UIMenuStatisticsPanel.__index = UIMenuStatisticsPanel
UIMenuStatisticsPanel.__call = function() return "UIMenuPanel", "UIMenuStatisticsPanel" end

---New
---@param title string
---@param colorType int
---@param startIndex number
function UIMenuStatisticsPanel.New(items)
	_UIMenuStatisticsPanel = {
		Items = items or {},
		ParentItem = nil, -- required
	}
	return setmetatable(_UIMenuStatisticsPanel, UIMenuStatisticsPanel)
end

---SetParentItem
---@param Item table
function UIMenuStatisticsPanel:SetParentItem(Item) -- required
	if not Item() == nil then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end

---AddStatistic
---@param Item table
function UIMenuStatisticsPanel:AddStatistic(name, value) -- required
    if name ~= nil and name ~= "" and value ~= nil then
        if value > 100 then
            value = 100
        elseif value < 0 then
            value = 0
        end
        table.insert(self.Items, {['name'] = name, ['value'] = value}) 
		if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
			local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
			local van = IndexOf(self.ParentItem.Panels, self)
			ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", false, it, van, name, value)
		end
    end
end

function UIMenuStatisticsPanel:GetPercentage(id)
	if id ~= nil then
		return self.Items[id].value
	end
end

function UIMenuStatisticsPanel:UpdateStatistic(id, value)
    if value ~= nil then
        if value > 100 then
            value = 100
        elseif value < 0 then
            value = 0
        end
		self.Items[id].value = value
		if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
			local it = IndexOf(self.ParentItem:SetParentMenu().Items, self.ParentItem)
			local van = IndexOf(self.ParentItem.Panels, self)
			ScaleformUI.Scaleforms._ui:CallFunction("SET_PANEL_STATS_ITEM_VALUE", false, it, van, id-1, value)
		end
    end
end


--///////////////////////////////////////--
BasicTabItem = setmetatable({}, BasicTabItem)
BasicTabItem.__index = BasicTabItem
BasicTabItem.__call = function()
    return "BasicTabItem", "BasicTabItem"
end

function BasicTabItem.New(label)
    data = {
        Label = label or "",
        Parent = nil
    }
    return setmetatable(data, BasicTabItem)
end


--///////////////////////////////////////--
KeymapItem = setmetatable({}, KeymapItem)
KeymapItem.__index = KeymapItem
KeymapItem.__call = function()
    return "BasicTabItem", "KeymapItem"
end

function KeymapItem.New(title, primaryKeyboard, primaryGamepad, secondaryKeyboard, secondaryGamepad)
    data = {}
    if secondaryKeyboard == nil and secondaryGamepad == nil then
        data = {
            Label = title,
            PrimaryKeyboard = primaryKeyboard,
            PrimaryGamepad = primaryGamepad,
            SecondaryKeyboard = "",
            SecondaryGamepad = "",
        }
    else
        data = {
            Label = title,
            PrimaryKeyboard = primaryKeyboard or "",
            PrimaryGamepad = primaryGamepad or "",
            SecondaryKeyboard = secondaryKeyboard or "",
            SecondaryGamepad = secondaryGamepad or "",
        }
    end
    return setmetatable(data, KeymapItem)
end



--///////////////////////////////////////--
SettingsTabItem = setmetatable({}, SettingsTabItem)
SettingsTabItem.__index = SettingsTabItem
SettingsTabItem.__call = function()
    return "BasicTabItem", "SettingsTabItem"
end

function SettingsTabItem.NewBasic(label, rightLabel)
    data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = SettingsItemType.Basic,
        Label = label or "", 
        _rightLabel = rightLabel or "",
        Parent = nil,
        OnActivated = function(item, index) 
        end
    }
    return setmetatable(data, SettingsTabItem)
end

function SettingsTabItem.NewList(label, items, index)
    data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = SettingsItemType.ListItem,
        Label = label or "", 
        ListItems = items or {},
        _itemIndex = index or 0,
        Parent = nil,
        OnListChanged = function(item, value, listItem)
        end
    }
    return setmetatable(data, SettingsTabItem)
end

function SettingsTabItem.NewProgress(label, max, startIndex, masked, barColor)
    local _type = SettingsItemType.ProgressBar
    if(masked) then
        _type = SettingsItemType.MaskedProgressBar
    end
    data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = _type,
        Label = label or "", 
        MaxValue = max,
        _value = startIndex,
        _coloredBarColor = barColor or Colours.HUD_COLOUR_FREEMODE,
        Parent = nil,
        OnBarChanged = function(item, value)
        end
    }
    return setmetatable(data, SettingsTabItem)
end

function SettingsTabItem.NewCheckbox(label, style, checked)
    data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = SettingsItemType.CheckBox,
        Label = label or "", 
        CheckBoxStyle = style or 0,
        _isChecked = checked,
        Parent = nil,
        OnCheckboxChanged = function(item, _checked)
        end
    }
    return setmetatable(data, SettingsTabItem)
end

function SettingsTabItem.NewSlider(label, max, startIndex, barColor)
    data = {
        Base = BasicTabItem.New(label or ""),
        ItemType = SettingsItemType.SliderBar,
        Label = label or "", 
        MaxValue = max,
        _value = startIndex,
        _coloredBarColor = barColor or Colours.HUD_COLOUR_FREEMODE,
        Parent = nil,
        OnBarChanged = function(item, value)
        end
    }
    return setmetatable(data, SettingsTabItem)
end

function SettingsTabItem:RightLabel(label)
    if self.ItemType == SettingsItemType.Basic then
        if label ~= nil then
            self._rightLabel = label
            local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
            local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
            local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu:UpdateItemRightLabel(tab, leftItem, rightIndex, self._rightLabel)
        else
            return self._rightLabel
        end
    else
        local _type = ""
        for k, v in pairs(SettingsItemType) do
            if v == self.ItemType then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: RightLabel function can only be called by Basic items.. your item is of type: " .. _type)
    end
end

function SettingsTabItem:Value(value)
    if self.ItemType == SettingsItemType.SliderBar or self.ItemType == SettingsItemType.ProgressBar or self.ItemType == SettingsItemType.MaskedProgressBar then
        if value ~= nil then
            self._value = value
            local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
            local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
            local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemValue(tab, leftItem, rightIndex, value)
            self.OnBarChanged(self, value)
        else
            return self._value
        end
    else
        local _type = ""
        for k, v in pairs(SettingsItemType) do
            if v == self.ItemType then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: Value function can only be called by colored bar items.. your item is of type: " .. _type)
    end
end

function SettingsTabItem:ItemIndex(index)
    if self.ItemType == SettingsItemType.ListItem then
        if index ~= nil then
            self._itemIndex = index
            local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
            local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
            local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemIndex(tab, leftItem, rightIndex, index)
            self.OnListChanged(self, itemIndex, tostring(self.ListItems[index]))
        else
            return self._itemIndex
        end
    else
        local _type = ""
        for k, v in pairs(SettingsItemType) do
            if v == self.ItemType then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: ItemIndex function can only be called by ListItem items.. your item is of type: " .. _type)
    end
end


function SettingsTabItem:Checked(checked)
    if self.ItemType == SettingsItemType.CheckBox then
        if checked ~= nil then
            self._isChecked = checked
            local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
            local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
            local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu:SetRightSettingsItemBool(tab, leftItem, rightIndex, checked)
            self.OnCheckboxChanged(self, checked)
        else
            return self._isChecked
        end
    else
        local _type = ""
        for k, v in pairs(SettingsItemType) do
            if v == self.ItemType then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: Checked function can only be called by CheckBox items.. your item is of type: " .. _type)
    end
end

function SettingsTabItem:ColoredBarColor(color)
    if self.ItemType == SettingsItemType.SliderBar or self.ItemType == SettingsItemType.ProgressBar or self.ItemType == SettingsItemType.MaskedProgressBar then
        if color ~= nil then
            self._coloredBarColor = color
            local tab = IndexOf(self.Parent.Parent.Base.Parent.Tabs, self.Parent.Parent) - 1
            local leftItem = IndexOf(self.Parent.Parent.LeftItemList, self.Parent) - 1
            local rightIndex = IndexOf(self.Parent.ItemList, self) - 1
            ScaleformUI.Scaleforms._pauseMenu:UpdateItemColoredBar(tab, leftItem, rightIndex, color)
        else
            return self._coloredBarColor
        end
    else
        local _type = ""
        for k, v in pairs(SettingsItemType) do
            if v == self.ItemType then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: ColoredBarColor function can only be called by colored bar items.. your item is of type: " .. _type)
    end
end



--///////////////////////////////////////--
StatsTabItem = setmetatable({}, StatsTabItem)
StatsTabItem.__index = StatsTabItem
StatsTabItem.__call = function()
    return "BasicTabItem", "StatsTabItem"
end

function StatsTabItem.NewBasic(label, rightLabel)
    data = {
        Base = BasicTabItem.New(label or ""),
        Type = StatItemType.Basic,
        Label = label or "", 
        _rightLabel = rightLabel or ""
    }
    return setmetatable(data, StatsTabItem)
end

function StatsTabItem.NewBar(label, value, color)
    data = {
        Base = BasicTabItem.New(label or ""),
        Type = StatItemType.ColoredBar,
        Label = label or "", 
        _value = value,
        _coloredBarColor = color or Colours.HUD_COLOUR_FREEMODE
    }
    return setmetatable(data, StatsTabItem)
end

function StatsTabItem:RightLabel(label)
    if self.Type == StatItemType.Basic then
        if label ~= nil then
            self._rightLabel = label
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBasic(tab, leftItem, rightIndex, self.Label, self._rightLabel)
        else
            return self._rightLabel
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: RightLabel function can only be called by Basic items.. your item is of type: " .. _type)
    end
end

function StatsTabItem:Value(value)
    if self.Type == SettingsItemType.ColoredBar then
        if value ~= nil then
            self._value = value
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBar(tab, leftItem, rightIndex, _value)
            self.OnBarChanged(self, value)
        else
            return self._value
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: Value function can only be called by colored bar items.. your item is of type: " .. _type)
    end
end

function StatsTabItem:ColoredBarColor(color)
    if self.Type == SettingsItemType.ColoredBar then
        if color ~= nil then
            self._coloredBarColor = color
            local tab = IndexOf(self.Base.Parent.Parent.Parent.Tabs, self.Base.Parent.Parent) - 1
            local leftItem = IndexOf(self.Base.Parent.Parent.LeftItemList, self.Base.Parent) - 1
            local rightIndex = IndexOf(self.Base.Parent.ItemList, self) - 1
            self.Base.Parent.Parent.Parent._pause:UpdateStatsItemBar(tab, leftItem, rightIndex, color)
        else
            return self._coloredBarColor
        end
    else
        local _type = ""
        for k, v in pairs(StatItemType) do
            if v == self.Type then _type = tostring(k) end
        end
        print("SCALEFORMUI - WARNING: ColoredBarColor function can only be called by colored bar items.. your item is of type: " .. _type)
    end
end



--///////////////////////////////////////--
StatItemType = {
    Basic = 0,
    ColoredBar = 1,
    
}

SettingsItemType = {
    Basic = 0,
    ListItem = 1,
    ProgressBar = 2,
    MaskedProgressBar = 3,
    CheckBox = 4,
    SliderBar = 5
}

LeftItemType = {
    Empty = 0,
    Info = 1,
    Statistics = 2,
    Settings = 3,
    Keymap = 4
}


--///////////////////////////////////////--
BaseTab = setmetatable({}, BaseTab)
BaseTab.__index = BaseTab
BaseTab.__call = function()
    return "BaseTab", "BaseTab"
end

function BaseTab.New(title)
    data = {
        Title = title or "",
        Visible = false,
        Focused = false,
        Active = false,
        Parent = nil,
        LeftItemList = {},
        Activated = function(item) end
    }
    return setmetatable(data, BaseTab)
end


--///////////////////////////////////////--
TabLeftItem = setmetatable({}, TabLeftItem)
TabLeftItem.__index = TabLeftItem
TabLeftItem.__call = function()
    return "TabLeftItem", "TabLeftItem"
end

function TabLeftItem.New(label, _type, mainColor, highlightColor)
    data = {
        Label = label or "",
        ItemType = _type,
        Focused = false,
        MainColor = mainColor or Colours.NONE, 
        HighlightColor = highlightColor or Colours.NONE,
        Highlighted = false,
        ItemIndex = 0,
        ItemList = {},
        TextTitle = "",
        KeymapRightLabel_1 = "",
        KeymapRightLabel_2 = "",
        OnIndexChanged = function(item, index) end,
        OnActivated = function(item, index) end,
        Index = 0,
        Parent = nil
    }
    return setmetatable(data, TabLeftItem)
end

function TabLeftItem:AddItem(item)
    item.Parent = self
    table.insert(self.ItemList, item)
end


--///////////////////////////////////////--
TabSubMenuItem = setmetatable({}, TabSubMenuItem)
TabSubMenuItem.__index = TabSubMenuItem
TabSubMenuItem.__call = function()
    return "BaseTab", "TabSubMenuItem"
end

function TabSubMenuItem.New(name)
    data = {
        Base = BaseTab.New(name or ""),
        Label = name or "",
        TextTitle = "",
        LeftItemList = {},
        Index = 0,
        Focused = false,
        Parent = nil,
    }
    return setmetatable(data, TabSubMenuItem)
end

function TabSubMenuItem:AddLeftItem(item)
    item.Parent = self
    table.insert(self.LeftItemList, item)
end


--///////////////////////////////////////--
TabTextItem = setmetatable({}, TabTextItem)
TabTextItem.__index = TabTextItem
TabTextItem.__call = function()
    return "BaseTab", "TabTextItem"
end

function TabTextItem.New(name, _title)
    data = {
        Base = BaseTab.New(name or ""),
        Label = name,
        TextTitle = _title or "",
        LabelsList = {},
        Index = 0,
        Focused = false,
        Parent = nil
    }
    return setmetatable(data, TabTextItem)
end

function TabTextItem:AddTitle(title)
    if not title:IsNullOrEmpty() then
        self.TextTitle = title
    end
end

function TabTextItem:AddItem(item)
    table.insert(self.LabelsList, item)
end



--///////////////////////////////////////--
TabView = setmetatable({}, TabView)
TabView.__index = TabView
TabView.__call = function()
    return "PauseMenu"
end

function TabView.New(title, subtitle, sideTop, sideMid, sideBot)
    _data = {
        Title = title or "",
        Subtitle = subtitle or "",
        SideTop = sideTop or "",
        SideMid = sideMid or "",
        SideBot = sideBot or "",
        _headerPicture = {},
        _crewPicture = {},
        Tabs = {},
        Index = 0,
        _visible = false,
        focusLevel = 0,
        rightItemIndex = 0,
        leftItemIndex = 0,
        TemporarilyHidden = false,
        controller = false,
        _loaded = false,
        _timer = 0,
        InstructionalButtons = {
            InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 176, 176, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1),
            InstructionalButton.New(GetLabelText("HUD_INPUT1C"), -1, -1, -1, "INPUTGROUP_FRONTEND_BUMPERS")
        },
        OnPauseMenuOpen = function(menu)
        end,
        OnPauseMenuClose = function(menu)
        end,
        OnPauseMenuTabChanged = function(menu, tab, tabIndex)
        end,
        OnPauseMenuFocusChanged = function(menu, tab, focusLevel, leftItem)
        end,
        OnLeftItemChange = function(menu, tabIndex, focusLevel, leftItem)
        end,
        OnRightItemChange = function(menu, tabIndex, focusLevel, leftItem, rightItem)
        end
    }
    return setmetatable(_data, TabView)
end

function TabView:LeftItemIndex(index)
    if index ~= nil then
        self.leftItemIndex = index
        self.OnLeftItemChange(self, self.Index, self:FocusLevel(), index)
    else
        return self.leftItemIndex
    end
end

function TabView:RightItemIndex(index)
    if index ~= nil then
        self.rightItemIndex = index
        self.OnRightItemChange(self, self.Index, self:FocusLevel(), self:LeftItemIndex(), index)
    else
        return self.rightItemIndex
    end
end

function TabView:FocusLevel(index)
    if index ~= nil then
        self.focusLevel = index
        self.OnPauseMenuFocusChanged(self, self.Tabs[self.Index], index, self:LeftItemIndex())
    else
        return self.focusLevel
    end
end

function TabView:Visible(visible)
    if(visible ~= nil) then
        if(visible == true)then
            self:BuildPauseMenu()
            self.OnPauseMenuOpen(self)
            AnimpostfxPlay("FocusOut", 800, false)
            TriggerScreenblurFadeIn(700)
            ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self.InstructionalButtons)
            SetPlayerControl(PlayerId(), false, 0)
        else
            ScaleformUI.Scaleforms._pauseMenu:Dispose()
            AnimpostfxPlay("FocusOut", 500, false)
            TriggerScreenblurFadeOut(400)
            self.OnPauseMenuClose(self)
            SetPlayerControl(PlayerId(), true, 0)
        end
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(visible)
        self._visible = visible
        ScaleformUI.Scaleforms._pauseMenu:Visible(visible)
    else
        return self._visible
    end
end

function TabView:AddTab(item)
    item.Base.Parent = self
    table.insert(self.Tabs, item)
end

function TabView:HeaderPicture(Txd, Txn)
    if(Txd ~= nil and Txn ~= nil) then
        self._headerPicture = {txd = Txd, txn = Txn}
    else
        return self._headerPicture
    end
end
function TabView:CrewPicture(Txd, Txn)
    if(Txd ~= nil and Txn ~= nil) then
        self._crewPicture = {txd = Txd, txn = Txn}
    else
        return self._crewPicture
    end
end

function TabView:ShowHeader()
    if self.Subtitle:IsNullOrEmpty() then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title)
    else
        ScaleformUI.Scaleforms._pauseMenu:ShiftCoronaDescription(true, false)
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderTitle(self.Title, self.Subtitle)
    end
    if (self:HeaderPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderCharImg(self:HeaderPicture().txd, self:HeaderPicture().txn, true)
    end
    if (self:CrewPicture() ~= nil) then
        ScaleformUI.Scaleforms._pauseMenu:SetHeaderSecondaryImg(self:CrewPicture().txd, self:CrewPicture().txn, true)
    end
    ScaleformUI.Scaleforms._pauseMenu:SetHeaderDetails(self.SideTop, self.SideMid, self.SideBot)
    self._loaded = true
end

function TabView:BuildPauseMenu()
    self:ShowHeader()
    for k, tab in pairs(self.Tabs) do
        local tabIndex = k-1
        local type, subtype = tab()
        if subtype == "TabTextItem" then
            ScaleformUI.Scaleforms._pauseMenu:AddPauseMenuTab(tab.Base.Title, 0)
            if not tostring(tab.TextTitle):IsNullOrEmpty() then
                ScaleformUI.Scaleforms._pauseMenu:AddRightTitle(tabIndex, 0, tab.TextTitle)
            end
            for j,item in pairs(tab.LabelsList) do
                ScaleformUI.Scaleforms._pauseMenu:AddRightListLabel(tabIndex, 0, item.Label)
            end
        elseif subtype == "TabSubMenuItem" then
            ScaleformUI.Scaleforms._pauseMenu:AddPauseMenuTab(tab.Base.Title, 1)
            for j,item in pairs(tab.LeftItemList) do
                local itemIndex = j-1
                ScaleformUI.Scaleforms._pauseMenu:AddLeftItem(tabIndex, item.ItemType, item.Label, item.MainColor, item.HighlightColor)

                if item.TextTitle ~= nil and not item.TextTitle:IsNullOrEmpty() then
                    if (item.ItemType == LeftItemType.Keymap) then
                        ScaleformUI.Scaleforms._pauseMenu:AddKeymapTitle(tabIndex , itemIndex, item.TextTitle, item.KeymapRightLabel_1, item.KeymapRightLabel_2)
                    else
                        ScaleformUI.Scaleforms._pauseMenu:AddRightTitle(tabIndex , itemIndex, item.TextTitle)
                    end
                end

                for l, ii in pairs(item.ItemList) do
                    local __type, __subtype = ii()
                    if __subtype == "StatsTabItem" then
                        if (ii.Type == StatItemType.Basic) then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightStatItemLabel(tabIndex , itemIndex, ii.Label, ii._rightLabel)
                        elseif (ii.Type == StatItemType.ColoredBar) then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightStatItemColorBar(tabIndex , itemIndex, ii.Label, ii._value, ii._coloredBarColor)
                        end
                    elseif __subtype == "SettingsTabItem" then
                        if ii.ItemType == SettingsItemType.Basic then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsBaseItem(tabIndex , itemIndex, ii.Label, ii._rightLabel)
                        elseif ii.ItemType == SettingsItemType.ListItem then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsListItem(tabIndex , itemIndex, ii.Label, ii.ListItems, ii._itemIndex)
                        elseif ii.ItemType == SettingsItemType.ProgressBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsProgressItem(tabIndex , itemIndex, ii.Label, ii.MaxValue, ii._coloredBarColor, ii._value)
                        elseif ii.ItemType == SettingsItemType.MaskedProgressBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsProgressItemAlt(tabIndex , itemIndex, ii.Label, ii.MaxValue, ii._coloredBarColor, ii._value)
                        elseif ii.ItemType == SettingsItemType.CheckBox then
                            while (not HasStreamedTextureDictLoaded("commonmenu")) do
                                Citizen.Wait(0)
                                RequestStreamedTextureDict("commonmenu", true)
                            end
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsCheckboxItem(tabIndex , itemIndex, ii.Label, ii.CheckBoxStyle, ii._isChecked)
                        elseif ii.ItemType == SettingsItemType.SliderBar then
                            ScaleformUI.Scaleforms._pauseMenu:AddRightSettingsSliderItem(tabIndex , itemIndex, ii.Label, ii.MaxValue, ii._coloredBarColor, ii._value)
                        end
                    elseif __subtype == "KeymapItem" then
                        if IsInputDisabled(2) then
                            ScaleformUI.Scaleforms._pauseMenu:AddKeymapItem(tabIndex , itemIndex, ii.Label, ii.PrimaryKeyboard, ii.SecondaryKeyboard)
                        else
                            ScaleformUI.Scaleforms._pauseMenu:AddKeymapItem(tabIndex , itemIndex, ii.Label, ii.PrimaryGamepad, ii.SecondaryGamepad)
                        end
                        self:UpdateKeymapItems()

                    else
                        ScaleformUI.Scaleforms._pauseMenu:AddRightListLabel(tabIndex , itemIndex, ii.Label)
                    end
                end
            end
        end
    end
end

function TabView:UpdateKeymapItems()
    if not IsInputDisabled(2) then
        if not self.controller then
            self.controller = true
            for j, tab in pairs(self.Tabs) do
                local type, subtype = tab()
                if subtype == "TabSubMenuItem" then
                    for k, lItem in pairs(tab.LeftItemList) do
                        local idx = k-1
                        if lItem.ItemType == LeftItemType.Keymap then
                            for i = 1, #lItem.ItemList, 1 do
                                local item = lItem.ItemList[i]
                                ScaleformUI.Scaleforms._pauseMenu:UpdateKeymap(j-1, idx, i-1, item.PrimaryGamepad, item.SecondaryGamepad)
                            end
                        end
                    end
                end
            end
        end
    else
        if self.controller then
            self.controller = false
            for j, tab in pairs(self.Tabs) do
                local type, subtype = tab()
                if subtype == "TabSubMenuItem" then
                    for k, lItem in pairs(tab.LeftItemList) do
                        local idx = k-1
                        if lItem.ItemType == LeftItemType.Keymap then
                            for i = 1, #lItem.ItemList, 1 do
                                local item = lItem.ItemList[i]
                                ScaleformUI.Scaleforms._pauseMenu:UpdateKeymap(j-1, idx, i-1, item.PrimaryKeyboard, item.SecondaryKeyboard)
                            end
                        end
                    end
                end
            end
        end
    end
end

function TabView:Draw()
    if not self:Visible() or self.TemporarilyHidden then
        return 
    end
    ScaleformUI.Scaleforms._pauseMenu:Draw()
    self:UpdateKeymapItems()
end

function TabView:ProcessControl()
    if not self:Visible() or self.TemporarilyHidden then
        return 
    end
    local result = ""
    if (IsControlJustPressed(2, 172)) then
        if (self:FocusLevel() == 0) then return end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(8)

    end
    if (IsControlJustPressed(2, 173)) then
        if (self:FocusLevel() == 0) then return end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(9)

    end
    if (IsControlJustPressed(2, 174)) then
        if (self:FocusLevel() == 1) then return end
        if (self:FocusLevel() == 0) then
            ScaleformUI.Scaleforms._pauseMenu:HeaderGoLeft()
        end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(10)

    end
    if (IsControlJustPressed(2, 175)) then
        if (self:FocusLevel() == 1) then return end
        if (self:FocusLevel() == 0) then
            ScaleformUI.Scaleforms._pauseMenu:HeaderGoRight()
        end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(11)

    end
    if (IsControlJustPressed(2, 205)) then
        if (self:FocusLevel() == 0) then
            ScaleformUI.Scaleforms._pauseMenu:HeaderGoLeft()
        end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(10)

    end
    if (IsControlJustPressed(2, 206)) then
        if (self:FocusLevel() == 0) then
                ScaleformUI.Scaleforms._pauseMenu:HeaderGoRight()
        end
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(11)

    end
    if (IsControlJustPressed(2, 201)) then
        result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(16)
        if self:FocusLevel() == 1 then
            local tab = self.Tabs[self.Index]
            local _, subt = tab()
            if(subt ~= "TabTextItem") then
                if (tab.LeftItemList[self:LeftItemIndex()].ItemType == LeftItemType.Info or tab.LeftItemList[self:LeftItemIndex()].ItemType == LeftItemType.Empty) then
                    tab.LeftItemList[self:LeftItemIndex()].OnActivated(tab.LeftItemList[self:LeftItemIndex()], self:LeftItemIndex())
                end
            end
        elseif self:FocusLevel() == 2 then
            local aa, subt = self.Tabs[self.Index].LeftItemList[self:LeftItemIndex()].ItemList[self:RightItemIndex()]()
            if subt == "SettingsTabItem" then
                if(self.Tabs[self.Index].LeftItemList[self:LeftItemIndex()].ItemList[self:RightItemIndex()].ItemType == SettingsItemType.Basic) then
                    self.Tabs[self.Index].LeftItemList[self:LeftItemIndex()].ItemList[self:RightItemIndex()].OnActivated(self.Tabs[self.Index].LeftItemList[self:LeftItemIndex()].ItemList[self:RightItemIndex()], self:RightItemIndex())
                end
            end
        end
    end
    if (IsControlJustPressed(2, 177)) then
        if self:FocusLevel() > 0 then
            result = ScaleformUI.Scaleforms._pauseMenu:SendInputEvent(17)
        else
            self:Visible(false)
        end
    end

    if (IsControlJustPressed(1, 241)) then
        result = ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(-1)
    end
    if (IsControlJustPressed(1, 242)) then
        result = ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(1)
    end


    if (IsControlPressed(2, 3)) then
        if (GetGameTimer() - self._timer > 250) then
                result = ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(-1)
            self._timer = GetGameTimer()
        end

    end
    if (IsControlPressed(2, 4)) then
        if (GetGameTimer() - self._timer > 250) then
                result = ScaleformUI.Scaleforms._pauseMenu:SendScrollEvent(1)
            self._timer = GetGameTimer()
        end
    end

    if (IsControlJustPressed(0, 24) and IsInputDisabled(2)) then
        if (GetGameTimer() - self._timer > 250) then
                result = ScaleformUI.Scaleforms._pauseMenu:SendClickEvent()
            self._timer = GetGameTimer()
        end
    end

    if not result:IsNullOrEmpty() and result:find(",") then
        local split = split(result, ',')
        local curTab = tonumber(split[1])+1
        local focusLevel = tonumber(split[2])
        local leftItemIndex = -1
        local rightPanelIndex = -1
        local retVal = -1
        local retBool = false
        if (#split > 2)then
            if #split == 3 then
                if(split[3] ~= "undefined") then
                    leftItemIndex = tonumber(split[3]) + 1
                else
                    leftItemIndex = -1
                end
            elseif #split == 5 then
                leftItemIndex = tonumber(split[3]) + 1
                rightPanelIndex = tonumber(split[4]) + 1
                if (split[5] == "true" or split[5] == "false") then
                    retBool = tobool(split[5])
                else
                    retVal = tonumber(split[5])
                end
            end
        end

        self.Index = curTab
        self:FocusLevel(focusLevel)

        if (focusLevel == 0) then
            for k,v in pairs(self.Tabs) do
                v.Focused = k == self.Index
            end
            self.OnPauseMenuTabChanged(self, self.Tabs[self.Index], self.Index)
        end

        if (focusLevel == 1) then
            local tab = self.Tabs[self.Index]
            local it, subit = tab()
            if (subit ~= "TabTextItem") then
                tab.Index = leftItemIndex
                self:LeftItemIndex(leftItemIndex)
                for l, m in pairs(tab.LeftItemList) do
                    m.Highlighted = l == leftItemIndex
                end
            end
        end            

        if (focusLevel == 2) then
            local leftItem = self.Tabs[self.Index].LeftItemList[leftItemIndex]
            if leftItem ~= nil then
                if leftItem.ItemType == LeftItemType.Settings then
                    leftItem.ItemIndex = rightPanelIndex
                    self:RightItemIndex(leftItem.ItemIndex)
                    for h, it in pairs(leftItem.ItemList) do
                        it.Highlighted = h == rightPanelIndex
                        if it.Highlighted then
                            if it.ItemType == SettingsItemType.ListItem then
                                it:ItemIndex(retVal)
                            elseif it.ItemType == SettingsItemType.SliderBar or it.ItemType == SettingsItemType.ProgressBar or it.ItemType == SettingsItemType.MaskedProgressBar then
                                it:Value(retVal)
                            elseif it.ItemType == SettingsItemType.CheckBox then
                                it:Checked(retBool)
                            end
                        end
                    end
                end
            end
        end
        -- DEBUG
        --print("Scaleform [tabIndex, focusLevel, currentTabLeftItemIndex, currentRightPanelItemIndex, retVal] = " .. result)
        --print("LUA [tabIndex, focusLevel, currentTabLeftItemIndex, currentRightPanelItemIndex, retVal] = " ..self.Index..", " ..self:FocusLevel()..", " ..self:LeftItemIndex()..", " ..self:RightItemIndex())
    end
end


--///////////////////////////////////////--
BigMessageInstance = {}

local m = {}
m = setmetatable({}, m)

m.__call = function()
    return true
end
m.__index = m

function BigMessageInstance.New()
    local _sc = 0
    local _start = 0
    local _timer = 0
    local data = {_sc = _sc, _start = _start, _timer = _timer}
    return setmetatable(data, m)
end

function m:Load()
    if self._sc ~= 0 then return end
    self._sc = Scaleform.Request("MP_BIG_MESSAGE_FREEMODE")
    local timeout = 1000
    local start = GetGameTimer()
    while not self._sc:IsLoaded() and GetGameTimer() - start < timeout do Citizen.Wait(0) end
end

function m:Dispose()
    self._sc:Dispose()
    self._sc = 0
end

function m:ShowMissionPassedMessage(msg, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_MISSION_PASSED_MESSAGE", false, msg, "", 100, true, 0, true)
    self._timer = time
end

function m:ShowColoredShard(msg, desc, textColor, bgColor, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_SHARD_CENTERED_MP_MESSAGE", false, msg, desc, bgColor, textColor)
    self._timer = time
end

function m:ShowOldMessage(msg, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_MISSION_PASSED_MESSAGE", false, msg)
    self._timer = time
end

function m:ShowSimpleShard(msg, subtitle, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_SHARD_CREW_RANKUP_MP_MESSAGE", false, title, subtitle)
    self._timer = time
end

function m:ShowRankupMessage(msg, subtitle, rank, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_BIG_MP_MESSAGE", false, msg, subtitle, rank, "", "")
    self._timer = time
end

function m:ShowWeaponPurchasedMessage(bigMessage, weaponName, weaponHash, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_WEAPON_PURCHASED", false, bigMessage, weaponName, weaponHash, "", 100)
    self._timer = time
end

function m:ShowMpMessageLarge(msg, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_CENTERED_MP_MESSAGE_LARGE", false, msg, "", 100, true, 100)
    self._sc:CallFunction("TRANSITION_IN", false)
    self._timer = time
end

function m:ShowMpWastedMessage(msg, subtitle, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    self._sc:CallFunction("SHOW_SHARD_WASTED_MP_MESSAGE", false, msg, subtitle)
    self._timer = time
end

function m:Update()
    if self._sc == 0 or IsPauseMenuActive() then return end
    self._sc:Render2D()
    if self._start ~= 0 and GetGameTimer() - self._start > self._timer then
        self._sc:CallFunction("TRANSITION_OUT", false)
        self._start = 0
        self:Dispose()
    end
end


--///////////////////////////////////////--
ButtonsHandler = {}

local handler = {}
handler = setmetatable({}, handler)

handler.__call = function()
    return true
end
handler.__index = handler

function ButtonsHandler.New()
    local data ={
        _sc = 0,
        UseMouseButtons = false,
        _enabled = false,
        IsUsingKeyboard = false,
        _changed = true,
        savingTimer = 0,
        IsSaving = false,
        ControlButtons = {}
    } 
    return setmetatable(data, handler) 
end

function handler:Enabled(bool)
    if bool == nil then
        return self._enabled
    else
        if not bool then
            self._sc:CallFunction("CLEAR_ALL", false)
            self._sc:CallFunction("CLEAR_RENDER", false)
        end
        self._enabled = bool
        self._changed = bool
    end
end

function handler:Load()
    if self._sc ~= 0 then return end
    self._sc = Scaleform.Request("INSTRUCTIONAL_BUTTONS")
    local timeout = 1000
    local start = GetGameTimer()
    while not self._sc:IsLoaded() and GetGameTimer() - start < timeout do Citizen.Wait(0) end
end

function handler:SetInstructionalButtons(buttons)
    self.ControlButtons = buttons
    self._changed = true
end

function handler:AddInstructionalButton(button)
    table.insert(ControlButtons, button)
    self._changed = true
end

function handler:RemoveInstructionalButton(button)
    local bt
    for k,v in pairs (self.ControlButtons) do
        if v.Text == button.Text then
            self.ControlButtons[k] = nil
        end
    end
    self._changed = true
end

function handler:ClearButtonList()
    self.ControlButtons = {}
    self._changed = true
end

function handler:ShowBusySpinner(spinnerType, text, time)
    if time == nil or time < 0 then time = 3000 end
    self.IsSaving = true
    self._changed = true
    self.savingTimer = GetGameTimer()

    if text == nil or text == "" then
        BeginTextCommandBusyString(nil)
    else
        BeginTextCommandBusyString("STRING")
        AddTextComponentSubstringPlayerName(text)
    end
    EndTextCommandBusyString(spinnerType)
    while GetGameTimer() - self.savingTimer <= time do Citizen.Wait(100) end
    RemoveLoadingPrompt()
    self.IsSaving = false
end

function handler:UpdateButtons()
    if not self._changed then return end
    self._sc:CallFunction("SET_DATA_SLOT_EMPTY", false)
    self._sc:CallFunction("TOGGLE_MOUSE_BUTTONS", false, self.UseMouseButtons)
    local count = 0

    for k, button in pairs (self.ControlButtons) do
        if button:IsUsingController() then
            if button.PadCheck == 0 or button.PadCheck == -1 then
                if ScaleformUI.Scaleforms.Warning:IsShowing() then
                    self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 0, -1)
                else
                    self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text)
                end
            end
        else
            if button.PadCheck == 1 or button.PadCheck == -1 then
                if self.UseMouseButtons then
                    _sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 1, button.KeyboardButton)
                else
                    if ScaleformUI.Scaleforms.Warning:IsShowing() then
                        self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text, 0, -1)
                    else
                        self._sc:CallFunction("SET_DATA_SLOT", false, count, button:GetButtonId(), button.Text)
                    end
                end
            end
        end
        count = count + 1
    end
    self._sc:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS", false, -1)
    self._changed = false
end

function handler:Draw()
    self._sc:Render2D()
end

function handler:DrawScreeSpace(x, y)
    self._sc:Render2DNormal(0.5 - x, 0.5 - y, 1, 1)
end

function handler:Update()
    if self._sc == 0 or not self._enabled then self:Load() end
    if (self.ControlButtons == nil or #self.ControlButtons == 0) and not self.IsSaving then return end
    if IsUsingKeyboard(2) then
        if not self.IsUsingKeyboard then
            self.IsUsingKeyboard = true
            self._changed = true
        end
    else
        if self.IsUsingKeyboard then
            self.IsUsingKeyboard = false
            self._changed = true
        end
    end
    self:UpdateButtons()
    if not ScaleformUI.Scaleforms.Warning:IsShowing() then self:Draw() end
    if self.UseMouseButtons then ShowCursorThisFrame() end
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(9)
end


--///////////////////////////////////////--
InstructionalButton = {}

local button = {}
button = setmetatable({}, button)

button.__call = function()
    return true
end
button.__index = button

function InstructionalButton.New(text, padcheck, gamepadControls, keyboardControls, inputGroup)
    local _button = {
        Text = text or "",
        GamepadButtons = nil,
        GamepadButton = -1,
        KeyboardButtons = nil,
        KeyboardButton = -1,
        PadCheck = padcheck or -1
    }
    
    if type(gamepadControls) == "table" then
        if padcheck == 0 or padcheck == -1 then
            _button.GamepadButtons = gamepadControls
        end
    else
        if padcheck == 0 or padcheck == -1 then
            _button.GamepadButton = gamepadControls
        else 
            _button.GamepadButton= -1
        end
    end
    if type(keyboardControls) == "table" then
        if padcheck == 1 or padcheck == -1 then
            _button.KeyboardButtons = keyboardControls
        end
    else
        if padcheck == 1 or padcheck == -1 then
            _button.KeyboardButton = keyboardControls 
        else
            _button.KeyboardButton = -1
        end
    end
    _button.InputGroupButton = inputGroup or -1
    
    return setmetatable(_button, button)
end

function button:IsUsingController()
    return not IsUsingKeyboard(2)
end

function button:GetButtonId()
    if self.KeyboardButtons ~= nil or self.GamepadButtons ~= nil then
        local retVal = ""
        if self:IsUsingController() then
            if self.GamepadButtons ~= nil then
                for i=#self.GamepadButtons, 1, -1 do
                    if i == 1 then
                        retVal = retVal .. GetControlInstructionalButton(2, self.GamepadButtons[i], 1)
                    else
                        retVal = retVal .. GetControlInstructionalButton(2, self.GamepadButtons[i], 1) .. "%"
                    end
                end
            end
        else
            if self.KeyboardButtons ~= nil then
                for i=#self.KeyboardButtons, 1, -1 do
                    if i == 1 then
                        retVal = retVal .. GetControlInstructionalButton(2, self.KeyboardButtons[i], 1)
                    else
                        retVal = retVal .. GetControlInstructionalButton(2, self.KeyboardButtons[i], 1) .. "%"
                    end
                end
            end
        end
        return retVal
    elseif self.InputGroupButton ~= -1 then 
        return "~"..self.InputGroupButton.."~"
    end
    if self:IsUsingController() then
        return GetControlInstructionalButton(2, self.GamepadButton, 1)
    else
        return GetControlInstructionalButton(2, self.KeyboardButton, 1)
    end
end




--///////////////////////////////////////--
ScaleformUI = {}
ScaleformUI.Scaleforms = {}
ScaleformUI.Notifications = nil
ScaleformUI.Scaleforms._ui = 0
ScaleformUI.Scaleforms.PauseMenu = nil
ScaleformUI.Scaleforms.MidMessageInstance = nil
ScaleformUI.Scaleforms.InstructionalButtons = nil
ScaleformUI.Scaleforms.BigMessageInstance = nil
ScaleformUI.Scaleforms.Warning = nil
ScaleformUI.Scaleforms.PlayerListInstance = nil
ScaleformUI.Scaleforms._pauseMenu = nil

AddEventHandler("onResourceStop", function(resName) 
    if resName == GetCurrentResourceName() then
        ScaleformUI.Scaleforms._pauseMenu:Dispose()
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL", false)
        ScaleformUI.Scaleforms._ui:Dispose()
        if not IsPlayerControlOn(PlayerId()) then
            SetPlayerControl(PlayerId(), true, 0)
        end
    end
end)

Citizen.CreateThread(function()
    ScaleformUI.Scaleforms._ui = Scaleform.Request("scaleformui")
    ScaleformUI.Scaleforms.BigMessageInstance = BigMessageInstance.New()
    ScaleformUI.Scaleforms.MidMessageInstance = MidMessageInstance.New()
    ScaleformUI.Scaleforms.Warning = WarningInstance.New()
    ScaleformUI.Scaleforms.InstructionalButtons = ButtonsHandler.New()
    ScaleformUI.Notifications = Notifications.New()
    ScaleformUI.Scaleforms._pauseMenu = PauseMenu.New()
    ScaleformUI.Scaleforms._pauseMenu:Load()
    
    while true do
        Wait(0)
        ScaleformUI.Scaleforms.BigMessageInstance:Update()
        ScaleformUI.Scaleforms.MidMessageInstance:Update()
        ScaleformUI.Scaleforms.InstructionalButtons:Update()
        ScaleformUI.Scaleforms.Warning:Update()
        if ScaleformUI.Scaleforms._ui == 0 or ScaleformUI.Scaleforms._ui == nil then
            ScaleformUI.Scaleforms._ui = Scaleform.Request("scaleformui")
        end
        if(not ScaleformUI.Scaleforms._pauseMenu.Loaded) then
            ScaleformUI.Scaleforms._pauseMenu:Load()
        end
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Wait(0)
--         if IsControlJustPressed(0, 47) then
--             -- INSTRUCTIONAL BUTTONS
--             --[[ 
--             local bts = {
--                 InstructionalButton.New("Button 1", -1, 51, 51, -1),
--                 InstructionalButton.New("Button 2", -1, -1, -1, "INPUTGROUP_LOOK"),
--                 InstructionalButton.New("Button 3", -1, 51, 47, -1),
--                 InstructionalButton.New("Button 4", -1, {32, 34, 33, 35}, {20, 52, 48, 51}, -1),
--             }
--             ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(bts)
--             ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
--             Citizen.Wait(5000)
--             ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
--             ScaleformUI.Scaleforms.InstructionalButtons:ClearButtonList()
--             ]]
--             -- WARNING
--             ScaleformUI.Scaleforms.Warning:ShowWarning("Title", "subtitle", "prompt", "errorMsg", 0)
--             Citizen.Wait(5000)
--             ScaleformUI.Scaleforms.Warning:Dispose()
--         end
--     end
-- end)



--///////////////////////////////////////--
MidMessageInstance = {}

local m = {}
m = setmetatable({}, m)

m.__call = function()
    return true
end
m.__index = m

function MidMessageInstance.New()
    local _sc = 0
    local _start = 0
    local _timer = 0
    local _hasAnimatedOut = false
    local data = {_sc = _sc, _start = _start, _timer = _timer, _hasAnimatedOut = _hasAnimatedOut}
    return setmetatable(data, m)
end

function m:Load()
    if self._sc ~= 0 then return end
    self._sc = Scaleform.Request("MIDSIZED_MESSAGE")
    local timeout = 1000
    local start = GetGameTimer()
    while not self._sc:IsLoaded() and GetGameTimer() - start < timeout do Citizen.Wait(0) end
end

function m:Dispose()
    self._sc:Dispose()
    self._sc = 0
end

function m:ShowColoredShard(msg, desc, textColor, useDarkerShard, useCondensedShard, time)
    if time == nil then  time = 5000 end
    self:Load()
    self._start = GetGameTimer()
    _sc:CallFunction("SHOW_SHARD_MIDSIZED_MESSAGE", false, msg, desc, bgColor, useDarkerShard, useCondensedShard)
    self._timer = time
    self._hasAnimatedOut = false
end

function m:Update()
    if self._sc == 0 or IsPauseMenuActive() then return end
    self._sc:Render2D()
    if self._start ~= 0 and GetGameTimer() - self._start > self._timer then
        if not _hasAnimatedOut then
            self._sc:CallFunction("SHARD_ANIM_OUT", false, 21, 750)
            self._hasAnimatedOut = true
            self._timer = self._timer + 750
        else
            PlaySoundFrontend(-1, "Shard_Disappear", "GTAO_FM_Events_Soundset", true)
            self._start = 0
            self:Dispose()
        end
    end
end


--///////////////////////////////////////--
PauseMenu = {}

local Pause = {}
Pause = setmetatable({}, Pause)

Pause.__call = function()
    return true
end
Pause.__index = Pause


function PauseMenu.New()
    _data = {
        _header = nil,
        _pause = nil,
        Loaded = false,
        _visible = false,
    }
    return setmetatable(_data, Pause)
end

function Pause:Visible(visible)
    if tobool(visible) then
        self._visible = visible
    else
        return self._visible
    end
end

function Pause:Load()
    if(self._header ~= nil and self._pause ~= nil) then return end
    self._header = Scaleform.Request("pausemenuheader")
    self._pause = Scaleform.Request("pausemenu")
    self.Loaded = self._header:IsLoaded() and self._pause:IsLoaded()
end

function Pause:SetHeaderTitle(title, subtitle, shiftUpHeader)
    if(subtitle == nil) then subtitle = "" end
    if(shiftUpHeader == nil) then shiftUpHeader = false end
    self._header:CallFunction("SET_HEADER_TITLE", false, title, subtitle, shiftUpHeader)
end

function Pause:SetHeaderDetails(topDetail, midDetail, botDetail)
    self._header:CallFunction("SET_HEADER_DETAILS", false, topDetail, midDetail, botDetail, false)
end

function Pause:ShiftCoronaDescription(shiftDesc, hideTabs)
    self._header:CallFunction("SHIFT_CORONA_DESC", false, shiftDesc, hideTabs)
end

function Pause:ShowHeadingDetails(show)
    self._header:CallFunction("SHOW_HEADING_DETAILS", false, show)
end

function Pause:SetHeaderCharImg(txd, charTexturePath, show)
    self._header:CallFunction("SET_HEADER_CHAR_IMG", false, txd, charTexturePath, show)
end

function Pause:SetHeaderSecondaryImg(txd, charTexturePath, show)
    self._header:CallFunction("SET_HEADER_CREW_IMG", false, txd, charTexturePath, show)
end

function Pause:HeaderGoRight()
    self._header:CallFunction("GO_RIGHT", false)
end

function Pause:HeaderGoLeft()
    self._header:CallFunction("GO_LEFT", false)
end

function Pause:AddPauseMenuTab(title, _type)
    self._header:CallFunction("ADD_HEADER_TAB", false, title)
    self._pause:CallFunction("ADD_TAB", false, _type)
end

function Pause:AddLeftItem(tab, _type, title, itemColor, highlightColor)
    if itemColor == nil then itemColor = Colours.NONE end
    if highlightColor == nil then highlightColor = Colours.NONE end

    if itemColor ~= Colours.NONE and highlightColor == Colours.NONE then
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title, itemColor)
    elseif (itemColor ~= Colours.NONE and highlightColor ~= Colours.NONE) then
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title, itemColor, highlightColor)
    else
        self._pause:CallFunction("ADD_LEFT_ITEM", false, tab, _type, title)
    end

end

function Pause:AddRightTitle(tab, leftItem, title)
    self._pause:CallFunction("ADD_RIGHT_TITLE", false, tab, leftItem, title)
end

function Pause:AddRightListLabel(tab, leftItem, label)
    AddTextEntry("PauseMenu_"..tab.."_"..leftItem, label)
    BeginScaleformMovieMethod(self._pause.handle, "ADD_RIGHT_LIST_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItem)
    ScaleformMovieMethodAddParamInt(0)
    BeginTextCommandScaleformString("PauseMenu_"..tab.."_"..leftItem)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

function Pause:AddRightStatItemLabel(tab, leftItem, label, rightLabel)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 1, 0, label, rightLabel)
end

function Pause:AddRightStatItemColorBar(tab, leftItem, label, value, barColor)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 1, 1, label, value, barColor)
end

function Pause:AddRightSettingsBaseItem(tab, leftItem, label, rightLabel)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 0, label, rightLabel)
end

function Pause:AddRightSettingsListItem(tab, leftItem, label, items, startIndex)
    stringList = table.concat(items, ",")
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 1, label, stringList, startIndex)
end

function Pause:AddRightSettingsProgressItem(tab, leftItem, label, max, color, index)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 2, label, max, color, index)
end

function Pause:AddRightSettingsProgressItemAlt(tab, leftItem, label, max, color, index)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 3, label, max, color, index)
end

function Pause:AddRightSettingsSliderItem(tab, leftItem, label, max, color, index)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 5, label, max, color, index)
end

function Pause:AddRightSettingsCheckboxItem(tab, leftItem, label, style, check)
    self._pause:CallFunction("ADD_RIGHT_LIST_ITEM", false, tab, leftItem, 2, 4, label, style, check)
end

function Pause:AddKeymapTitle(tab, leftItem, title, rightLabel_1, rightLabel_2)
    self._pause:CallFunction("ADD_RIGHT_TITLE", false, tab, leftItem, title, rightLabel_1, rightLabel_2)
end

function Pause:AddKeymapItem(tab, leftItem, label, control1, control2)
    BeginScaleformMovieMethod(self._pause.handle, "ADD_RIGHT_LIST_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItem)
    ScaleformMovieMethodAddParamInt(3)
    PushScaleformMovieFunctionParameterString(label)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(control1)
    EndTextCommandScaleformString_2()
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(control2)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

function Pause:UpdateKeymap(tab, leftItem, rightItem, control1, control2)
    BeginScaleformMovieMethod(self._pause.handle, "UPDATE_KEYMAP_ITEM")
    ScaleformMovieMethodAddParamInt(tab)
    ScaleformMovieMethodAddParamInt(leftItem)
    ScaleformMovieMethodAddParamInt(rightItem)
    BeginTextCommandScaleformString("string")
    AddTextComponentScaleform(control1)
    EndTextCommandScaleformString_2()
    BeginTextCommandScaleformString("string")
    AddTextComponentScaleform(control2)
    EndTextCommandScaleformString_2()
    EndScaleformMovieMethod()
end

function Pause:SetRightSettingsItemBool(tab, leftItem, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItem, rightItem, value)
end

function Pause:SetRightSettingsItemIndex(tab, leftItem, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItem, rightItem, value)
end

function Pause:SetRightSettingsItemValue(tab, leftItem, rightItem, value)
    self._pause:CallFunction("SET_RIGHT_SETTINGS_ITEM_VALUE", false, tab, leftItem, rightItem, value)
end

function Pause:UpdateItemRightLabel(tab, leftItem, rightItem, label)
    self._pause:CallFunction("UPDATE_RIGHT_ITEM_RIGHT_LABEL", false, tab, leftItem, rightItem, label)
end

function Pause:UpdateStatsItemBasic(tab, leftItem, rightItem, label, rightLabel)
    self._pause:CallFunction("UPDATE_RIGHT_STATS_ITEM", false, tab, leftItem, rightItem, label, rightLabel)
end

function Pause:UpdateStatsItemBar(tab, leftItem, rightItem, label, value, color)
    self._pause:CallFunction("UPDATE_RIGHT_STATS_ITEM", false, tab, leftItem, rightItem, label, value, color)
end

function Pause:UpdateItemColoredBar(tab, leftItem, rightItem, color)
    if(color == nil or color == Colours.NONE) then
        self._pause:CallFunction("UPDATE_COLORED_BAR_COLOR", false, tab, leftItem, rightItem, Colours.HUD_COLOUR_WHITE)
    else
        self._pause:CallFunction("UPDATE_COLORED_BAR_COLOR", false, tab, leftItem, rightItem, color)
    end
end

function Pause:SendInputEvent(direction) -- to be awaited
    local return_value = self._pause:CallFunction("SET_INPUT_EVENT", true, direction)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    return GetScaleformMovieFunctionReturnString(return_value)
end

function Pause:SendScrollEvent(direction) -- to be awaited
    local return_value = self._pause:CallFunction("SET_SCROLL_EVENT", true, direction, not IsInputDisabled(2))
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    return GetScaleformMovieFunctionReturnString(return_value)
end

function Pause:SendClickEvent() -- to be awaited
    local return_value = self._pause:CallFunction("MOUSE_CLICK_EVENT", true)
    while not IsScaleformMovieMethodReturnValueReady(return_value) do
        Citizen.Wait(0)
    end
    return GetScaleformMovieFunctionReturnString(return_value)
end

function Pause:Dispose()
    self._pause:CallFunction("CLEAR_ALL", false)
    self._header:CallFunction("CLEAR_ALL", false)
    self._pause:Dispose()
    self._header:Dispose()
    _visible = false
end

function Pause:Draw()
    if self._visible and not IsPauseMenuActive() then
        if IsInputDisabled(2) then
            ShowCursorThisFrame()
        end
        self._header:Render2DNormal(0.501, 0.162, 0.6782, 0.145)
        self._pause:Render2DNormal(0.6617187, 0.7166667, 1.0, 1.0)
    end
end


--///////////////////////////////////////--
Scaleform = {}

local scaleform = {}
scaleform = setmetatable({}, scaleform)

scaleform.__call = function()
    return true
end

scaleform.__index = scaleform

function Scaleform.Request(Name)
	local ScaleformHandle = RequestScaleformMovie(Name)
	local data = {name = Name, handle = ScaleformHandle}
	return setmetatable(data, scaleform)
end

function scaleform:CallFunction(theFunction, returndata, ...)
    BeginScaleformMovieMethod(self.handle, theFunction)
    local arg = {...}
    if arg ~= nil then
        for i=1,#arg do
            local sType = type(arg[i])
            if sType == "boolean" then
                PushScaleformMovieMethodParameterBool(arg[i])
			elseif sType == "number" then
				if math.type(arg[i]) == "integer" then
					PushScaleformMovieMethodParameterInt(arg[i])
				else
					PushScaleformMovieMethodParameterFloat(arg[i])
				end
            elseif sType == "string" then
				if arg[i]:find("^desc_{") ~= nil then
					BeginTextCommandScaleformString(arg[i])
					EndTextCommandScaleformString_2()
				elseif arg[i]:find("^PauseMenu_") ~= nil then
					BeginTextCommandScaleformString(arg[i])
					EndTextCommandScaleformString_2()
				else
					PushScaleformMovieMethodParameterString(arg[i])
				end
            end
		end
	end

	if not returndata then
		return EndScaleformMovieMethod()
	else
		return EndScaleformMovieMethodReturnValue()
	end
end

function scaleform:Render2D()
	DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255)
end

function scaleform:Render2DNormal(x, y, width, height)
	DrawScaleformMovie(self.handle, x, y, width, height, 255, 255, 255, 255)
end

function scaleform:Render2DScreenSpace(locx, locy, sizex, sizey)
	local Width, Height = GetScreenResolution()
	local x = locy / Width
	local y = locx / Height
	local width = sizex / Width
	local height = sizey / Height
	DrawScaleformMovie(self.handle, x + (width / 2.0), y + (height / 2.0), width, height, 255, 255, 255, 255)
end

function scaleform:Render3D(x, y, z, rx, ry, rz, scalex, scaley, scalez)
	DrawScaleformMovie_3dNonAdditive(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Render3DAdditive(x, y, z, rx, ry, rz, scalex, scaley, scalez)
	DrawScaleformMovie_3d(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Dispose()
	SetScaleformMovieAsNoLongerNeeded(self.handle)
	self = nil
end

function scaleform:IsValid()
	return self and true or false
end

function scaleform:IsLoaded() 
    return HasScaleformMovieLoaded(self.handle)
end


--///////////////////////////////////////--
WarningInstance = {}

local warn = {}
warn = setmetatable({}, warn)

warn.__call = function()
    return true
end
warn.__index = warn

function WarningInstance.New()
    local data = {
        _sc = 0,
        _disableControls = false,
        _buttonList = {},
        OnButtonPressed = function(button)
        end
    }
    return setmetatable(data, warn)
end

function warn:IsShowing()
    return self._sc ~= 0
end

function warn:Load()
    if self._sc ~= 0 then return end
    self._sc = Scaleform.Request("POPUP_WARNING")
    local timeout = 1000
    local start = GetGameTimer()
    while not self._sc:IsLoaded() and GetGameTimer() - start < timeout do Citizen.Wait(0) end
end

function warn:Dispose()
    if self._sc == 0 then return end
    self._sc:CallFunction("HIDE_POPUP_WARNING", false, 1000)
    self._sc:Dispose()
    self._sc = 0
    self._disableControls = false
end

function warn:ShowWarning(title, subtitle, prompt, errorMsg, warningType)
    self:Load()
    self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, true, warningType, errorMsg)
end

function warn:UpdateWarning(title, subtitle, prompt, errorMsg, warningType)
    self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, true, warningType, errorMsg)
end

function warn:ShowWarningWithButtons(title, subtitle, prompt, buttons, errorMsg, warningType)
    self:Load()
    self._disableControls = true
    self._buttonList = buttons
    if buttons == nil or #buttons == 0 then return end
    ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(self._buttonList)
    ScaleformUI.Scaleforms.InstructionalButtons.UseMouseButtons = true
    self._sc:CallFunction("SHOW_POPUP_WARNING", false, 1000, title, subtitle, prompt, true, warningType, errorMsg)
    ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
end

function warn:Update()
    if self._sc == 0 then return end
    self._sc:Render2D()
    if self._disableControls then
        ScaleformUI.Scaleforms.InstructionalButtons:Draw()
        for k,v in pairs(self._buttonList) do
            if IsControlJustPressed(1, v.GamepadButton) or IsControlJustPressed(1, v.KeyboardButton) then
                self.OnButtonPressed(v)
                self:Dispose()
                ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
                ScaleformUI.Scaleforms.InstructionalButtons.UseMouseButtons = false
            end
        end
    end
end


--///////////////////////////////////////--
UIMenuFreemodeDetailsItem = setmetatable({}, UIMenuFreemodeDetailsItem)
UIMenuFreemodeDetailsItem.__index = UIMenuFreemodeDetailsItem
UIMenuFreemodeDetailsItem.__call = function() return "UIMenuFreemodeDetailsItem", "UIMenuFreemodeDetailsItem" end

function UIMenuFreemodeDetailsItem.New(textLeft, textRight, seperator, icon, iconColor, tick)
    if seperator then
        _type = 3
    elseif icon ~= nil and iconColor ~= nil then
        _type = 2
    else
        _type = 0
    end
    _UIMenuFreemodeDetailsItem = {
        Type = _type,
        TextLeft = textLeft,
        TextRight = textRight,
        Icon = icon,
        IconColor = iconColor,
        Tick = tick or false
	}
	return setmetatable(_UIMenuFreemodeDetailsItem, UIMenuFreemodeDetailsItem)
end


--///////////////////////////////////////--
UIMissionDetailsPanel = setmetatable({}, UIMissionDetailsPanel)
UIMissionDetailsPanel.__index = UIMissionDetailsPanel
UIMissionDetailsPanel.__call = function() return "UIMissionDetailsPanel", "UIMissionDetailsPanel" end

function UIMissionDetailsPanel.New(side, title, color, inside, txd, txn)
	if inside == -1 then
        _titleType = 1
    elseif inside then
        _titleType = 2
    else
        _titleType = 0
    end

    if color ~= -1 then
        _titleColor = color
    else
        _titleColor = Colours.NONE
    end

    _UIMissionDetailsPanel = {
        PanelSide = side,
        Title = title,
        TitleColor = _titleColor,
        TitleType = _titleType,
        TextureDict = txd or "",
        TextureName = txn or "",
        Items = {},
        ParentItem = nil
	}
	return setmetatable(_UIMissionDetailsPanel, UIMissionDetailsPanel)
end

function UIMissionDetailsPanel:SetParentItem(Item) -- required
	if Item() == "UIMenuItem" then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end

function UIMissionDetailsPanel:UpdatePanelTitle(title)
    self.Title = title

    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_SIDE_PANEL_TITLE", false, item, title)
    end
end

function UIMissionDetailsPanel:UpdatePanelPicture(txd, txn)
    self.TextureDict = txd
    self.TextureName = txn

    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_MISSION_DETAILS_PANEL_IMG", false, item, txd, txn)
    end
end

function UIMissionDetailsPanel:AddItem(newitem)
    table.insert(self.Items, newitem)
    if self.ParentItem ~= nil then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("ADD_MISSION_DETAILS_DESC_ITEM", false, item, newitem.Type, newitem.TextLeft, newitem.TextRight, newitem.Icon, newitem.IconColor, newitem.Ticked)
    end
end

function UIMissionDetailsPanel:RemoveItemAt(index)	
    table.remove(self.Items, index)	
    if self.ParentItem ~= nil then	
        ScaleformUI.Scaleforms._ui:CallFunction("REMOVE_MISSION_DETAILS_DESC_ITEM", false, index - 1)	
    end	
end


--///////////////////////////////////////--
UIVehicleColorPickerPanel = setmetatable({}, UIVehicleColorPickerPanel)
UIVehicleColorPickerPanel.__index = UIVehicleColorPickerPanel
UIVehicleColorPickerPanel.__call = function() return "UIVehicleColorPickerPanel", "UIVehicleColorPickerPanel" end

function UIVehicleColorPickerPanel.New(side, title, color)
    if color ~= -1 then
        _titleColor = color
    else
        _titleColor = Colours.NONE
    end

    _UIVehicleColorPickerPanel = {
        PanelSide = side,
        Title = title,
        TitleColor = _titleColor,
        TitleType = _titleType,
        Value = 1,
        ParentItem = nil,
        PickerSelect = function(menu, item, newindex) end
	}
	return setmetatable(_UIVehicleColorPickerPanel, UIVehicleColorPickerPanel)
end

function UIVehicleColorPickerPanel:SetParentItem(Item) -- required
	if not Item() == nil then
		self.ParentItem = Item
	else
		return self.ParentItem
	end
end

function UIVehicleColorPickerPanel:UpdatePanelTitle(title)
    self.Title = title
    if self.ParentItem ~= nil and self.ParentItem:SetParentMenu() ~= nil and self.ParentItem:SetParentMenu():Visible() then
        local item = IndexOf(self.ParentItem.Base.ParentMenu.Items, self.ParentItem) - 1
        ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_SIDE_PANEL_TITLE", false, item, title)
    end
end


--///////////////////////////////////////--
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

string.StartsWith = function(self, str) 
    return self:find('^' .. str) ~= nil
end

string.IsNullOrEmpty = function(self)
    return self == nil or self == '' or not not tostring(self):find("^%s*$") 
end
function string.IsNullOrEmpty(s)
    return s == nil or s == '' or not not tostring(s):find("^%s*$") 
 end
   
string.Insert = function(self, pos, str2)
    return self:sub(1,pos)..str2..self:sub(pos+1)
end

-- Return the first index with the given value (or -1 if not found).
function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return -1
end

-- Return a key with the given value (or nil if not found).  If there are
-- multiple keys with that value, the particular key returned is arbitrary.
function keyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function tobool(input)
	if input == "true" or tonumber(input) == 1 or input == true then
		return true
	else
		return false
	end
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
 end
 


--///////////////////////////////////////--
UIMenuDetailsWindow = setmetatable({}, UIMenuDetailsWindow)
UIMenuDetailsWindow.__index = UIMenuDetailsWindow
UIMenuDetailsWindow.__call = function() return "UIMenuWindow", "UIMenuDetailsWindow" end

---New
---@param Mom number
---@param Dad number
function UIMenuDetailsWindow.New(...)
    local args = {...}

    if #args == 3 or #args == 4 then
        _UIMenuDetailsWindow = {
            id = 1,
            DetailTop = args[1],
            DetailMid = args[2],
            DetailBottom = args[3],
            StatWheelEnabled = false,
            DetailLeft = args[4] or {
                Txd = "",
                Txn = "",
                Pos = vector2(0, 0),
                Size = vector2(0, 0),
            },
            ParentMenu = nil, -- required
        }
    elseif #args == 5 then
        _UIMenuDetailsWindow = {
            id = 1,
            DetailTop = args[1],
            DetailMid = args[2],
            DetailBottom = args[3],
            StatWheelEnabled = args[4],
            DetailStats = args[5],
            DetailLeft = {
                Txd = "statWheel",
                Txn = "",
                Pos = vector2(0, 0),
                Size = vector2(0, 0),
            },
            ParentMenu = nil, -- required
        }
    end
	return setmetatable(_UIMenuDetailsWindow, UIMenuDetailsWindow)
end

---SetParentMenu
---@param Menu table
function UIMenuDetailsWindow:SetParentMenu(Menu) -- required
	if Menu() == "UIMenu" then
		self.ParentMenu = Menu
	else
		return self.ParentMenu
	end
end

function UIMenuDetailsWindow:UpdateLabels(top, mid, bot, leftDetail)
    self.DetailTop = top
    self.DetailMid = mid
    self.DetailBottom = bot
    self.DetailLeft = leftDetail or {
        Txd = "",
        Txn = "",
        Pos = vector2(0, 0),
        Size = vector2(0, 0),
    }

    if self.ParentMenu ~= nil then
        local wid = IndexOf(self.ParentMenu.Windows, self) - 1
        if self.StatWheelEnabled then
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_DETAILS_WINDOW_VALUES", false, wid, self.DetailBottom, self.DetailMid, self.DetailTop, "statWheel")
        else
            ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_DETAILS_WINDOW_VALUES", false, wid, self.DetailBottom, self.DetailMid, self.DetailTop, self.DetailLeft.Txd, self.DetailLeft.Txn, self.DetailLeft.Pos.x, self.DetailLeft.Pos.y, self.DetailLeft.Size.x, self.DetailLeft.Size.y)
        end
    end
end

function UIMenuDetailsWindow:AddStatsListToWheel(stats)
    if self.StatWheelEnabled then
        self.DetailStats = stats
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            for key, value in pairs(self.DetailStats) do
                ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false, wid, value.Percentage, value.HudColor)
            end
        end
    end
end

function UIMenuDetailsWindow:AddStatSingleToWheel(stat)
    if self.StatWheelEnabled then
        table.insert(self.DetailStats, stat)
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATS_DETAILS_WINDOW_STATWHEEL", false, wid, stat.Percentage, stat.HudColor)
        end
    end
end

function UIMenuDetailsWindow:UpdateStatsToWheel()
    if self.StatWheelEnabled then
        if self.ParentMenu ~= nil then
            local wid = IndexOf(self.ParentMenu.Windows, self) - 1
            for key, value in pairs(self.DetailStats) do
                ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_STATS_DETAILS_WINDOW_STATWHEEL", false, wid, key - 1, value.Percentage, value.HudColor)
            end
        end
    end
end


--///////////////////////////////////////--
UIMenuHeritageWindow = setmetatable({}, UIMenuHeritageWindow)
UIMenuHeritageWindow.__index = UIMenuHeritageWindow
UIMenuHeritageWindow.__call = function() return "UIMenuWindow", "UIMenuHeritageWindow" end

---New
---@param Mom number
---@param Dad number
function UIMenuHeritageWindow.New(Mom, Dad)
	if not tonumber(Mom) then Mom = 0 end
	if not (Mom >= 0 and Mom <= 21) then Mom = 0 end
	if not tonumber(Dad) then Dad = 0 end
	if not (Dad >= 0 and Dad <= 23) then Dad = 0 end
	_UIMenuHeritageWindow = {
		id = 0,
		Mom = Mom,
		Dad = Dad,
		ParentMenu = nil, -- required
	}
	return setmetatable(_UIMenuHeritageWindow, UIMenuHeritageWindow)
end

---SetParentMenu
---@param Menu table
function UIMenuHeritageWindow:SetParentMenu(Menu) -- required
	if Menu() == "UIMenu" then
		self.ParentMenu = Menu
	else
		return self.ParentMenu
	end
end

function UIMenuHeritageWindow:Index(Mom, Dad)
	if not tonumber(Mom) then Mom = self.Mom end
	if not tonumber(Dad) then Dad = self.Dad end

	if tonumber(Mom) == -1 then
		Mom = self.Mom
	elseif tonumber(Dad) == -1 then
		Dad = self.Dad
	end

	self.Mom = Mom-1
	self.Dad = Dad-1

	local wid = IndexOf(self.ParentMenu.Windows, self) - 1
	ScaleformUI.Scaleforms._ui:CallFunction("UPDATE_HERITAGE_WINDOW", false, wid, self.Mom, self.Dad)
end

