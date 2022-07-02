GFACTORY = GFACTORY or {}
print("sh init")
-- Shared
do
    //AddCSLuaFile("libraries/sh_itemlib.lua")`

    AddCSLuaFile("libraries/sh_itemlib.lua")
    include("libraries/sh_itemlib.lua")
    AddCSLuaFile("libraries/sh_inventorynetworker.lua")
    include("libraries/sh_inventorynetworker.lua")

    include("libraries/sh_electricitylib.lua")

end
GFACTORY.InventorySlotQuantity = 16 * 12
local Inventory = GFACTORY.Classes.Inventory
-- Server
if SERVER then
    local function initialize()
        for k, ply in pairs(player.GetAll()) do
            --ply.Inventory = nil
            ply.Inventory = Inventory.new(GFACTORY.InventorySlotQuantity)
            ply.Inventory.ply = ply
        end
    end
    hook.Add("PlayerInitialSpawn", "GF_InitialSpawn", initialize)
    initialize()
end

-- Client
if CLIENT then
    --AddCSLuaFile("libraries/cl_guibase.lua")
    include("libraries/cl_guibase.lua")
    --AddCSLuaFile("libraries/gui/inventory.lua")
    include("libraries/gui/inventory.lua")

    local function initialize()
        LocalPlayer().Inventory = Inventory.new(GFACTORY.InventorySlotQuantity)
        LocalPlayer().Inventory.OnChanged = function(self)
            self:NetworkToServer("plyinvclmove")
            print("networked player inventory")
        end

        LocalPlayer().ContainerInventory = Inventory.new(0)
        LocalPlayer().ContainerInventory.OnChanged = function(self)
            self:NetworkToServer("invclmove")
            print("networked container")
        end
    end

    hook.Add( "InitPostEntity", "GF_ClientInit", initialize)
    initialize()
end