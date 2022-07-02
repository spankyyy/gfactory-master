-- power source
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_vehicles/generatortrailer01.mdl")
    self:SetColor(Color(128, 128, 255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():Wake()
    self:SetUseType(SIMPLE_USE)
    

    -- electricity
    self:InitElectricitySystem(false, true)
    self:SetOutput(1000)
    self:SetBuffer(50000, 0)

    -- Local position
    self.OutputPosition = Vector(-1, 23, 34)
end
function ENT:Think()
    self.eBuffer.stored = math.Clamp(self.eBuffer.stored + 50, 0, self.eBuffer.capacity)
    
    self:ElectricityThink()
    self:SetNWStored(self.eBuffer.stored)
    self:NextThink(CurTime() + 0.05)
    return true
end