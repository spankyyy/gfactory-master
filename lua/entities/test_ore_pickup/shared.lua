ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Test Ore Pickup"
ENT.Category = "GFactory"
ENT.Spawnable = true
ENT.isInteractable = true
ENT.isPickupable = true
function selectRandom(tbl)
    return tbl[math.random(1, #tbl)]
end
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CL_Quantity")
end