if SERVER then return end
print("loaded inventory")
local GUI = GFACTORY.GUI
local BASE = GUI.BASE
GUI.FRAMES = GUI.FRAMES  or {}
GUI.Inventory = GUI.Inventory or {}
local Inventory = GFACTORY.Classes.Inventory
local Item = GFACTORY.Classes.Inventory
--local FRAMES = GFACTORY.GUI.FRAMES
local T = surface.CreateFont( "SlotFont", {
    font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 14,
    weight = 0,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )
function populateFromInventory(self, inventory)
    requestPlayerInventory(function(len)
        inventory:ReceiveFromServer()
        for k, item in pairs(inventory.slots) do
            local gridSlot = self.Items[item.currentSlot]
            gridSlot:SetItem(item)
        end
    end)
end
net.Receive("inv", function()
    LocalPlayer().ContainerInventory:ReceiveFromServer()
    GUI.Inventory.toggleInventory()
end)
function updateGridItems(grid)
    local items = grid:GetItems()
    for k,v in pairs(items) do
        v:UpdateItem()
    end
end
function GUI.Inventory.CreateInventoryFrame(slots, slots2)
    local w, h = 1920 - 0, 1080 - 0
    local InventoryGUI = vgui.Create("GF_Frame")
    LocalPlayer()._CursorItem = nil
    LocalPlayer().InventoryGUI = InventoryGUI
    InventoryGUI:SetKeyboardInputEnabled(false)
    InventoryGUI.CTitle:SetText("Inventory")
    InventoryGUI:SetDraggable(false)
    InventoryGUI:SetSizable(false)
    InventoryGUI:Center()
    local SlotsPerRow = 16
    local size = math.floor(((w * 0.5) - 24) / SlotsPerRow)

    local scrollpan = InventoryGUI:Add("DScrollPanel")
    scrollpan:SetPos(8, 32)
    scrollpan:SetSize((w * 0.5) - 16, (h * 0.5) - 36)
    local scrollbar = scrollpan:GetVBar()
    function scrollbar:OnCursorMoved( x, y )

        if ( !self.Enabled ) then return end
        if ( !self.Dragging ) then return end
    
        local x, y = self:ScreenToLocal( 0, gui.MouseY() )
    
        -- Uck.
        y = y - self.btnUp:GetTall()
        y = y - self.HoldPos
    
        local BtnHeight = self:GetWide()
        if ( self:GetHideButtons() ) then BtnHeight = 0 end
    
        local TrackSize = self:GetTall() - BtnHeight * 2 - self.btnGrip:GetTall()
    
        y = y / TrackSize

        if self.CurrentScroll == nil then self.CurrentScroll = self:GetScroll() end
        self.CurrentScroll = math.Clamp(y * self.CanvasSize, 0, self.CanvasSize)
        self:SetScroll(self.CurrentScroll)
    
    end

    function scrollbar:Paint(w, h)
        surface.SetDrawColor(Color(96, 96, 96))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnUp:Paint(w, h)
        surface.SetDrawColor(Color(128, 128, 128))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnDown:Paint(w, h)
        surface.SetDrawColor(Color(128, 128, 128))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(Color(200, 200, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(36, 36, 36))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar:OnMouseWheeled( dlta )
        if not self:IsVisible() then return false end
        -- We return true if the scrollbar changed.
        -- If it didn't, we feed the mousehweeling to the parent panel
        if self.CurrentScroll == nil then self.CurrentScroll = self:GetScroll() end
        self.CurrentScroll = math.Clamp(self.CurrentScroll + (dlta * -size), 0, self.CanvasSize)
        self:AnimateTo(self.CurrentScroll, 0.1, 0, 0.5)
        return self:AddScroll( dlta * -2 )
    end
    local grid = InventoryGUI:Add("DGrid")
    scrollpan:AddItem(grid)
    grid:SetPos(0, 0)
    grid:SetCols( SlotsPerRow )
    grid:SetColWide(size)
    grid:SetRowHeight(size)
    InventoryGUI.InventoryGrid = grid
    for i = 1, slots do
        --local but = vgui.Create( "GF_InvSlot" )
        --but:SetSize(size + 2, size + 2)
        --but:SetText("")
        --but.slotIndex = i
        --but.inventory = LocalPlayer().Inventory
        --grid:AddItem( but )

        local item = LocalPlayer().Inventory.slots[i]
        local but = vgui.Create("GF_InvSlot")
        but:SetSize(size + 2, size + 2)
        but:SetText("")
        but.slotIndex = i
        but.inventory = LocalPlayer().Inventory
        but:SetItem(item)
        but.grid = grid
        grid:AddItem( but )
    end

    --[]-- second grid --[]--
    local scrollpan = InventoryGUI:Add("DScrollPanel")
    scrollpan:SetPos(8, (h * 0.5) + 32)
    scrollpan:SetSize((w * 0.5) - 16, (h * 0.5) - 36)
    local scrollbar = scrollpan:GetVBar()
    function scrollbar:OnCursorMoved( x, y )

        if ( !self.Enabled ) then return end
        if ( !self.Dragging ) then return end
    
        local x, y = self:ScreenToLocal( 0, gui.MouseY() )
    
        -- Uck.
        y = y - self.btnUp:GetTall()
        y = y - self.HoldPos
    
        local BtnHeight = self:GetWide()
        if ( self:GetHideButtons() ) then BtnHeight = 0 end
    
        local TrackSize = self:GetTall() - BtnHeight * 2 - self.btnGrip:GetTall()
    
        y = y / TrackSize

        if self.CurrentScroll == nil then self.CurrentScroll = self:GetScroll() end
        self.CurrentScroll = math.Clamp(y * self.CanvasSize, 0, self.CanvasSize)
        self:SetScroll(self.CurrentScroll)
    
    end
    function scrollbar:Paint(w, h)
        surface.SetDrawColor(Color(96, 96, 96))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnUp:Paint(w, h)
        surface.SetDrawColor(Color(128, 128, 128))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnDown:Paint(w, h)
        surface.SetDrawColor(Color(128, 128, 128))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(48, 48, 48))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(Color(200, 200, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(36, 36, 36))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function scrollbar:OnMouseWheeled( dlta )
        if not self:IsVisible() then return false end
        -- We return true if the scrollbar changed.
        -- If it didn't, we feed the mousehweeling to the parent panel
        if self.CurrentScroll == nil then self.CurrentScroll = self:GetScroll() end
        self.CurrentScroll = math.Clamp(self.CurrentScroll + (dlta * -size), 0, self.CanvasSize)
        self:AnimateTo(self.CurrentScroll, 0.1, 0, 0.5)
        return self:AddScroll( dlta * -2 )
    end
    local grid = InventoryGUI:Add("DGrid")
    scrollpan:AddItem(grid)
    grid:SetPos(0, 0)
    grid:SetCols( SlotsPerRow )
    grid:SetColWide(size)
    grid:SetRowHeight(size)
    InventoryGUI.ContainerGrid = grid
    for i = 1, LocalPlayer().ContainerInventory.slotQuantity do
        local item = LocalPlayer().ContainerInventory.slots[i]
        local but = vgui.Create( "GF_InvSlot" )
        but:SetSize(size + 2, size + 2)
        but:SetText("")
        but.slotIndex = i
        but.inventory = LocalPlayer().ContainerInventory
        but:SetItem(item)
        but.grid = grid
        grid:AddItem( but )
    end
    function InventoryGUI:Paint(w, h)
        self:_Paint(w, h)
        surface.SetDrawColor(Color(72, 72, 72))
        surface.DrawRect(4, 4 + self.TitleHeight, (w * 0.5) - 8, h - (8 + self.TitleHeight))
        
        surface.SetDrawColor(Color(64, 64, 64))
        surface.DrawOutlinedRect(4, 4 + self.TitleHeight, (w * 0.5) - 8, h - (8 + self.TitleHeight), 2)

        surface.SetDrawColor(Color(52, 52, 52))
        surface.DrawLine(w * 0.5, self.TitleHeight, w * 0.5 , h)
        surface.DrawOutlinedRect(4, 4 + self.TitleHeight, (w * 0.5) - 8, h - (8 + self.TitleHeight), 1)
    end
    InventoryGUI:ScaleOpen(w, h)
    return InventoryGUI
end
function GUI.Inventory.toggleInventory()
    if GUI.Inventory.Frame and GUI.Inventory.Frame:IsValid() then 
        LocalPlayer().ContainerInventory.slotQuantity = 0
        GUI.Inventory.Frame:ScaleClose()
        return 
    end
    local LocalInventory = LocalPlayer().Inventory
    GUI.Inventory.Frame = GUI.Inventory.CreateInventoryFrame(LocalInventory.slotQuantity)
    populateFromInventory(GUI.Inventory.Frame.InventoryGrid, LocalInventory)
    return InventoryGUI
end
concommand.Add("gf_toggleinv", function()
    GFACTORY.GUI.Inventory.toggleInventory()
end)