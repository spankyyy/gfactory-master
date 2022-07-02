AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local slots = 32
function ENT:Initialize()
    self:SetModel(self.Model)
	--self:SetMaterial("models/props/hr_massive/ground_rock_2/rock_wall_2b")
	//self:SetPos(self:GetPos() - Vector(0, 0, 8))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
	//self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableMotion(false)
	self:SetUseType(SIMPLE_USE)
    self.Inventory = GFACTORY.Classes.Inventory.new(slots)
end
function ENT:SpawnFunction(ply, traceResult, class)
	local ent = ents.Create(class)
	ent:SetPos(traceResult.HitPos + Vector(0, 0, 32)) 
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
	ent:DropToFloor()
    ent:SetPos(ent:GetPos() + Vector(0, 0, 18)) 
	ent:Spawn()
	ent:Activate()
	undo.Create(ent.PrintName)
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
end
function ENT:Use(ply)
    if ply:GetEyeTrace().Entity ~= self then return end
    self:EmitSound("AmmoCrate.Open", 75, 100, 1, CHAN_AUTO)
    
    self.Inventory:NetworkToClient(ply, "inv")
    ply.ContainerInventory = self.Inventory
    print("networking to player " .. ply:Nick())
end