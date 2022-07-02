
-- [Shared] --
GFACTORY = GFACTORY or {}

local Inventory = {}
Inventory.__index = Inventory
local Item = {}
Item.__index = Item

GFACTORY.Classes = {}
GFACTORY.Classes.Item = Item
GFACTORY.Classes.Inventory = Inventory

GFACTORY.ItemRegistry = {}
GFACTORY.ItemStrIds = {}
GFACTORY.ItemNumIds = {}
-- Item methods --
function GFACTORY.RegisterNewItem(stringID, tableData)
    GFACTORY.ItemRegistry[stringID] = tableData
    local NumericalID = #(GFACTORY.ItemNumIds) + 1
    GFACTORY.ItemStrIds[NumericalID] = stringID
    GFACTORY.ItemNumIds[stringID] = NumericalID
end
function Item.new(stringID, data)
    local self = {}
    local data = data or {}
    local RegisteredItem = GFACTORY.ItemRegistry[stringID]
    if RegisteredItem == nil then return end
    self.quantity = math.Clamp(data.quantity or 1, 1, RegisteredItem.stackSize)
    self.objectClass = data.class
    self.stackSize = RegisteredItem.stackSize
    self.currentInventory = nil
    self.currentSlot = nil
    self.ID = stringID
    return setmetatable(self, Item)
end
function Item:tryCombine(item)
    if not self.ID then return false end
    if not item.ID then return false end
    if item == self or not item or not self then return false end
    local combined = self.quantity + item.quantity
    local overflow = math.max(combined - self.stackSize, 0)
    item.quantity = overflow

    if overflow == 0 then
        if item.currentInventory then
            item.currentInventory.slots[item.currentSlot] = nil
        end
        --item.quantity = nil
        table.Empty(item)
        self.quantity = combined
        return false
    end

    self.quantity = self.stackSize
    return true 
end
function Item:removeFromInventory()
    if self.currentInventory then
        self.currentInventory.slots[self.currentSlot] = nil
        self.currentInventory = nil
        self.currentSlot = nil
    end
end

-- Inventory methods --
function Inventory.new(slotsN)
    local self = {}
    self.slots = {}
    self.slotQuantity = slotsN
    self.OnChanged = function(self)

    end
    return setmetatable(self, Inventory)
end
function Inventory:findAvailableSlot(item, slotIndex)
    -- check slots with items in before choosing an empty slot
    if not slotIndex then
        local firstEmptySlot = 0
        for slotIndex = 1, self.slotQuantity do
            local slot = self.slots[slotIndex]
            -- Check slot availability

            -- If slot is empty, use slot for later
            if not slot and firstEmptySlot == 0 then
                firstEmptySlot = slotIndex
            end

            -- If slot is not full but still has some items, use slot
            if slot and slot.quantity then
                if slot.ID == item.ID and slot.quantity < slot.stackSize then
                    return slotIndex, false
                end
            end
        end

        if firstEmptySlot ~= 0 then
            return firstEmptySlot, true
        end
        return nil, false
    else
        local slot = self.slots[slotIndex]
        -- Check slot availability

        -- If slot is empty, use slot for later
        if not slot then
            return slotIndex, true
        end

        -- If slot is not full but still has some items, use slot
        if slot then
            if slot.ID == item.ID and slot.quantity < slot.stackSize then
                return slotIndex, false
            end
        end
    end
end
function Inventory:tryAdd(item, _slotIndex)
    if not item then return false end
    if not item.ID then return false end
    local slotIndex, isEmpty = self:findAvailableSlot(item, _slotIndex)
    --local slotIndex = slotIndex or _slotIndex
    if not slotIndex then return false end
    if item.currentInventory == self and item.currentSlot == slotIndex then return false end
    if item.currentInventory == self then self.slots[item.currentSlot] = nil return true end


    if isEmpty then
        item.currentInventory = self
        item.currentSlot = slotIndex
        self.slots[slotIndex] = item
        return true 
    end

    local slot = self.slots[slotIndex]
    if slot then
        slot:tryCombine(item)
    end
    // pcall to prevent rare stack overflow
    if table.Count(self.slots) == self.slotQuantity then return false end
    pcall(function()
        self:tryAdd(item)
    end)
    return true 
end
function Inventory.trySwap(self, index, otherInventory, otherIndex)
    if not otherInventory then return end
    local slot = self.slots[index]
    local otherSlot = otherInventory.slots[otherIndex]
    if not slot and otherSlot then
        slot = otherSlot
        slot.currentInventory = self
        slot.currentSlot = index
        otherInventory.slots[otherIndex] = nil
        return
    end

    if not otherSlot and slot then
        otherSlot = slot
        otherSlot.currentInventory = otherInventory
        otherSlot.currentSlot = index
        self.slots[otherIndex] = nil
        return
    end

    if slot and otherSlot then
        self.slots[index] = otherSlot
        otherInventory.slots[otherIndex] = slot

        self.slots[index].currentInventory = self.slots[index]
        otherInventory.slots[index].currentInventory = otherInventory.slots[otherIndex]

        self.slots[index].currentSlot = index
        otherInventory.slots[index].currentSlot = otherIndex
        self.OnChanged(self)
    end
end

GFACTORY.RegisterNewItem("testitem", {
    stackSize = 64
})
-- [Client] --
if CLIENT then

end
-- [Server] --
if SERVER then

end