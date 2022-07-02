ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Test Ore"
ENT.Category = "GFactory"
ENT.Spawnable = true
ENT.isInteractable = true
function selectRandom(tbl)
    return tbl[math.random(1, #tbl)]
end