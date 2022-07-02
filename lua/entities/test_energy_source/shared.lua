ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Test Energy Source"
ENT.Category = "GFactory"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "NWStored")
end