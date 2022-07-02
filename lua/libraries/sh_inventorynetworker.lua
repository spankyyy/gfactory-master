print("sh_inventorynetworker loaded")
local Inventory = GFACTORY.Classes.Inventory
local Item = GFACTORY.Classes.Item
function Inventory:CreateFromCheap(cheap)
    self.slots = {}
    for k, v in pairs(cheap) do
        local StringID = ItemStrIds[v[1]]
        local Quantity = v[2]
        local slot
        local newItem = Item.new(StringID, {quantity = Quantity})
        self:tryAdd(newItem, k)
    end
end
function Inventory:CreateCheap()
    local cheap = {}
    local slots = self.slots
    for k, v in pairs(slots) do
        -- use numerical id to save bytes
        v.quantity = v.quantity or 1
        cheap[k] = {GFACTORY.ItemNumIds[v.ID], v.quantity, v.currentSlot}
    end
    return cheap
end
-- TODO find a way to network specific inventories
if SERVER then
    util.AddNetworkString("plyinv")
    util.AddNetworkString("plyinvcl")
    util.AddNetworkString("plyinvclmove")
    util.AddNetworkString("inv")
    util.AddNetworkString("invcl")
    util.AddNetworkString("invclmove")
    net.Receive("plyinvcl", function(len, ply)
        ply.Inventory:NetworkToClient(ply, "plyinv")
    end)
    net.Receive("plyinvclmove", function(len, ply)
        ply.Inventory:ReceiveFromClient()
    end)
    net.Receive("invcl", function(len, ply)
        --ply.ContainerInventory:NetworkToClient(ply, "inv")
    end)
    net.Receive("invclmove", function(len, ply)
        print("received move packet")
        ply.ContainerInventory:ReceiveFromClient()
    end)
    function Inventory:NetworkToClient(client, networkString)
        net.Start(networkString)
        -- send inventory max slots
        net.WriteUInt(self.slotQuantity - 1, 10)
        local cheap = self:CreateCheap()
        -- send slot amount
        net.WriteUInt(table.Count(cheap), 8)
        for k, v in pairs(cheap) do
            -- write id
            net.WriteUInt(v[1] - 1, 8)
            -- write quantity
            net.WriteUInt(v[2] - 1, 8)
            -- write slot
            net.WriteUInt(v[3] - 1, 8)
        end
        net.Send(client)
    end
    function Inventory:ReceiveFromClient()
        local SlotQuantity = net.ReadUInt(10) + 1
        --local SlotQuantity = GFACTORY.InventorySlotQuantity
        local SlotsN = net.ReadUInt(8)
        -- clear slots
        self.slots = {}
        -- update slot quantity 
        self.slotQuantity = SlotQuantity
        for i=1, SlotsN do
            local StringID = GFACTORY.ItemStrIds[net.ReadUInt(8) + 1]
            local Quantity = net.ReadUInt(8) + 1
            local Slot = net.ReadUInt(8) + 1
            local newItem = Item.new(StringID, {quantity = Quantity})
            self:tryAdd(newItem, Slot, true)
        end
    end
else
    function Inventory:NetworkToServer(networkString)
        net.Start(networkString)
        -- send inventory max slots
        net.WriteUInt(self.slotQuantity - 1, 10)
        local cheap = self:CreateCheap()
        -- send slot amount
        net.WriteUInt(table.Count(cheap), 8)
        for k, v in pairs(cheap) do
            -- write id
            net.WriteUInt(v[1] - 1, 8)
            -- write quantity
            net.WriteUInt(v[2] - 1, 8)
            -- write slot
            net.WriteUInt(v[3] - 1, 8)
        end
        net.SendToServer()
    end
    function Inventory:ReceiveFromServer()
        local SlotQuantity = net.ReadUInt(10) + 1
        --local SlotQuantity = GFACTORY.InventorySlotQuantity
        local SlotsN = net.ReadUInt(8)
        -- clear slots
        self.slots = {}
        -- update slot quantity 
        self.slotQuantity = SlotQuantity
        for i=1, SlotsN do
            local StringID = GFACTORY.ItemStrIds[net.ReadUInt(8) + 1]
            local Quantity = net.ReadUInt(8) + 1
            local Slot = net.ReadUInt(8) + 1

            local newItem = Item.new(StringID, {quantity = Quantity})
            self:tryAdd(newItem, Slot, true)
        end
    end
    function requestPlayerInventory(callback)
        --ping to start request
        net.Start("plyinvcl")
        net.SendToServer()
        net.Receive("plyinv", callback)
    end
end
