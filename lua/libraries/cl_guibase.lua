if SERVER then return end
print("guibase loaded")
GFACTORY.GUI = {}
GFACTORY.GUI.BASE = {}
local GUI = GFACTORY.GUI
local BASE = GFACTORY.GUI.BASE
local Inventory = GFACTORY.Classes.Inventory
local Item = GFACTORY.Classes.Item
BASE.Theme = {
    Border = Color(52, 52, 52),
    Border2 = Color(58, 58, 58),
    Center = Color(64, 64, 64),
    Title = Color(72, 72, 72),
    TitleMaterial = Material("noicon.png", "noclamp smooth"),
    TitleMaterial2 = Material("gui/gradient_down", "noclamp smooth"),
    TitleMaterial3 = Material("gui/gradient_up", "noclamp smooth")
}
local T = surface.CreateFont( "BaseTitle", {
    font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 22,
    weight = 1000,
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
local BASEPanel = {}
function BASEPanel:ScaleOpen(w, h)
    local animTime, animDelay, animEase = 0.5, 0, 0.1
    self:SetAlpha(0)
    --self:SetSize(0, h)
    self:SizeTo(w, h, animTime, animDelay, animEase, function()
        self.isOpenAnimating = false
    end)
    self:AlphaTo(255, 0.1, animDelay)
    self.isOpenAnimating = true
    self.Think = function(self)
        if self.isOpenAnimating then
            self:Center()
        end
    end
end
function BASEPanel:ScaleClose()
    local animTime, animDelay, animEase = 0.1, 0, 1
    self:SizeTo(0, 0, animTime, animDelay, animEase, function()
        self.isCloseAnimating = false
        self:Close()
    end)
    self:AlphaTo(0, animTime * 0.9, animDelay)
    self.isCloseAnimating = true
    self.Think = function(self)
        if self.isCloseAnimating then
            self:Center()
        end
    end
    if LocalPlayer()._CursorItem then
        LocalPlayer().Inventory:tryAdd(LocalPlayer()._CursorItem)
        LocalPlayer().Inventory:OnChanged()
        LocalPlayer()._CursorItem = nil
    end
    self.Closing = true
end
function BASEPanel:Init()
    local _gui = self
    _gui.CTitle = _gui:Add("DLabel")
    _gui.CTitle:SetPos(3, 0)
    _gui.CTitle:SetFont("BaseTitle")
    _gui.CTitle:SetText("")
    _gui.Closing = false
    _gui:SetTitle("")
    _gui.TitleHeight = 24
    _gui:SetSize(512, 512)
    _gui:ShowCloseButton(false)
    _gui.Paint = BASE.Paint
    _gui:SetSizable(true)
    _gui:MakePopup(true)
    function _gui:OnSizeChanged(w, h)
        self.CloseButton:SetPos((w + 3) - (self.TitleHeight), 3)
        self.CTitle:SetSize(w, 24)
    end
    local CloseButton = _gui:Add("DButton")
    CloseButton:SetText("")
    CloseButton:SetSize(_gui.TitleHeight - 6, _gui.TitleHeight - 6)
    function CloseButton:Paint(w, h)
        if self:IsDown() then
            draw.RoundedBox(100, 0, 0, w, h, Color(64, 64, 64))
            draw.RoundedBox(100, 1, 1, w - 2, h - 2, Color(255, 24, 24))
        elseif self:IsHovered() then
            draw.RoundedBox(100, 0, 0, w, h, Color(64, 64, 64))
            draw.RoundedBox(100, 1, 1, w - 2, h - 2, Color(255, 72, 72))
        else
            draw.RoundedBox(100, 0, 0, w, h, Color(64, 64, 64))
            draw.RoundedBox(100, 1, 1, w - 2, h - 2, Color(255, 64, 64))
        end
        
    end
    function CloseButton:DoClick()
        _gui:ScaleClose()
    end
    _gui.CloseButton = CloseButton
end
function BASEPanel:Paint(w, h)
    surface.SetDrawColor(BASE.Theme.Center)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(255, 255, 255))
    surface.SetMaterial(BASE.Theme.TitleMaterial)
    surface.DrawTexturedRectUV(0, 0, w, self.TitleHeight, 0, 0, (w / (self.TitleHeight * 2)), (24 / (self.TitleHeight * 2)))

    surface.SetDrawColor(Color(36, 36, 36, 255))
    surface.SetMaterial(BASE.Theme.TitleMaterial2)
    surface.DrawTexturedRect(0, 0, w, 10)
    surface.SetMaterial(BASE.Theme.TitleMaterial3)
    surface.DrawTexturedRect(0, self.TitleHeight - 10, w, 10)

    surface.SetDrawColor(BASE.Theme.Border2)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.DrawOutlinedRect(0, 0, w, self.TitleHeight, 2)
    surface.DrawOutlinedRect(0, self.TitleHeight - 1, w, h - self.TitleHeight, 2)
    surface.SetDrawColor(BASE.Theme.Border)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.DrawOutlinedRect(0, 0, w, self.TitleHeight, 1)
end
BASEPanel._Paint = BASEPanel.Paint
vgui.Register("GF_Frame", BASEPanel, "DFrame")

local INVENTORYSlot = {}
function INVENTORYSlot:Init()
    self.DoubleClickTime = 0
end
function INVENTORYSlot:Paint(w, h)
    local w, h = w - 4, h - 4
    draw.RoundedBoxEx(6, 1, 1, w, h, Color(36, 36, 36), false, true, true, false)
    draw.RoundedBoxEx(5, 2, 2, w - 2, h - 2, Color(48, 48, 48), false, true, true, false)

    if self:IsHovered() then
        draw.RoundedBoxEx(6, 1, 1, w, h, Color(255, 255, 255, 4), false, true, true, false)
    end
    draw.DrawText(self.Text or "", "SlotFont", w * 0.5, h * 0.25, Color(192, 192, 192), TEXT_ALIGN_CENTER)
end
function INVENTORYSlot:SetItem(item)
    if not item or not item.ID or not item.quantity then 
        self.Text = nil
        self.item = nil
        return 
    end
    self.Text = item.ID .. "\n(" .. item.quantity .. "x)"
    self.item = item
    if self.slotIndex and self.item.currentInventory then
        self.item.currentInventory[self.item.currentSlot] = nil
        self.item.currentInventory[self.slotIndex] = self.item
        self.item.currentSlot = self.slotIndex
    end
end
function INVENTORYSlot:UpdateItem()
    self:SetItem()
    self:SetItem(self.inventory[self.slotIndex])
end
function INVENTORYSlot:SetSlot(slot)
    self.slotIndex = slot
end
function INVENTORYSlot:SetInventory(inv)
    self.inventory = inv
end
function INVENTORYSlot:DoClick()
    local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
    -- if theres nothing in the slot and nothing on the cursor, return
    local cursorItem = LocalPlayer()._CursorItem
    -- if we have an item on the cursor but none in the slot, move item to slot
    if not shift or true then
        if not self.item and cursorItem then 
            self.inventory:tryAdd(cursorItem, self.slotIndex)
            self:SetItem(cursorItem)
            self.inventory:OnChanged()
            LocalPlayer()._CursorItem = nil
            return
        end
        -- if we have nothing on the cursor but something in the slot, put item on cursor
        if not cursorItem and self.item then
            LocalPlayer()._CursorItem = self.item
            self.item:removeFromInventory()
            self:SetItem()
            self.inventory:OnChanged()
            return
        end
        -- if we have something in both, we swap or combine
        if cursorItem and self.item then
            if self.item.quantity == self.item.stackSize and cursorItem.quantity ~= cursorItem.stackSize then
                -- simulate swapping to prevent some fucked bug
                local cursorQuantity = cursorItem.quantity
                local cursorID = cursorItem.ID
                cursorItem.quantity = self.item.quantity
                cursorItem.ID = self.item.ID
                self.item.quantity = cursorQuantity
                self.item.ID = cursorID
                self:UpdateItem()
            elseif self.item.ID == cursorItem.ID then
                self.item:tryCombine(cursorItem)
                local success = (cursorItem.quantity or 0) == 0
                if success then
                    LocalPlayer()._CursorItem = nil
                    self.inventory:OnChanged()
                end
                self:UpdateItem()
            end
        end
    else
        -- shift
        if not self.item and cursorItem then 
            self.inventory:tryAdd(cursorItem, self.slotIndex)
            self:SetItem(cursorItem)
            self.inventory:OnChanged()
            LocalPlayer()._CursorItem = nil
            return
        end
        -- if we have nothing on the cursor but something in the slot, put item on cursor
        if not cursorItem and self.item and LocalPlayer().ContainerInventory.slotQuantity ~= 0 then
            --LocalPlayer()._CursorItem = self.item
            --self.item:removeFromInventory()
            --self:SetItem()
            --self.inventory:OnChanged()
            local item = self.item
            local inv1, inv2 = LocalPlayer().Inventory, LocalPlayer().ContainerInventory
            if self.inventory == inv2 then inv1, inv2 = inv2, inv1 end
            item:removeFromInventory()
            inv2:tryAdd(item)
            updateGridItems(GFACTORY.GUI.Inventory.Frame.InventoryGrid)
            updateGridItems(GFACTORY.GUI.Inventory.Frame.ContainerGrid)
            self.inventory:OnChanged()
            inv2:OnChanged()
            return
        end
        -- if we have something in both, we swap or combine
        if cursorItem and self.item then
            if self.item.quantity == self.item.stackSize and cursorItem.quantity ~= cursorItem.stackSize then
                -- simulate swapping to prevent some fucked bug
                local cursorQuantity = cursorItem.quantity
                local cursorID = cursorItem.ID
                cursorItem.quantity = self.item.quantity
                cursorItem.ID = self.item.ID
                self.item.quantity = cursorQuantity
                self.item.ID = cursorID
                self:UpdateItem()
            elseif self.item.ID == cursorItem.ID then
                self.item:tryCombine(cursorItem)
                local success = (cursorItem.quantity or 0) == 0
                if success then
                    LocalPlayer()._CursorItem = nil
                    self.inventory:OnChanged()
                end
                self:UpdateItem()
            end
        end
    end
end
function INVENTORYSlot:DoRightClick()
    -- take half if none in cursor
    local cursorItem = LocalPlayer()._CursorItem
    if self.item and not cursorItem then
        if self.item.quantity ~= 1 then
            local half = math.ceil(self.item.quantity * 0.5)
            local otherHalf = self.item.quantity - half
            self.item.quantity = otherHalf
            self:UpdateItem()
            LocalPlayer()._CursorItem = Item.new(self.item.ID, {quantity = half})
        else
            LocalPlayer()._CursorItem = self.item
            self:SetItem()
        end
        return 
    end
    -- add onto the stack
    if self.item and cursorItem then
        if self.item.quantity == self.item.stackSize then return end
        self.item.quantity = self.item.quantity + 1
        cursorItem.quantity = cursorItem.quantity - 1
        if cursorItem.quantity == 0 then
            LocalPlayer()._CursorItem = nil
        end
        self:UpdateItem()
        self.inventory:OnChanged()
        return
    end
    -- create new item and put in slot
    if not self.item and cursorItem then
        local newItem = Item.new(cursorItem.ID, {quantity = 1})
        self.inventory:tryAdd(newItem, self.slotIndex)
        self:SetItem(newItem)
        cursorItem.quantity = cursorItem.quantity - 1
        if cursorItem.quantity == 0 then
            LocalPlayer()._CursorItem = nil
        end
        self.inventory:OnChanged()
        return
    end
end
function INVENTORYSlot:OnMousePressed(mousecode)
    if mousecode == MOUSE_LEFT then
        self:DoClick()
    end
    if mousecode == MOUSE_RIGHT then
        self:DoRightClick()
    end
end
vgui.Register("GF_InvSlot", INVENTORYSlot, "DButton")

