-- battery
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/items/car_battery01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():Wake()
    self:SetUseType(SIMPLE_USE)

    -- electricity
    self:InitElectricitySystem(true, true)
    self:SetInput(20)
    self:SetOutput(10)
    self:SetBuffer(50000, 0)

    -- Local position
    self.InputPosition = Vector(0, -7.5, 5.8)
    self.OutputPosition = Vector(0, 7.5, 5.8)
end

function ENT:Think()
    self:ElectricityThink()
    self:NextThink(CurTime() + 0.05)
    self:SetNWStored(self.eBuffer.stored)
    return true
end