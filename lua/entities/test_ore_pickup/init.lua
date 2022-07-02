AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local Item = GFACTORY.Classes.Item
local rockModels = {
	"models/props_foliage/rock_forest01b.mdl",
	"models/props_mining/rock_caves01.mdl",
	"models/props_mining/rock_caves01a.mdl"
}
function ENT:Initialize()
    self:SetModel(selectRandom(rockModels))
    self:SetMaterial("models/props/hr_massive/ground_rock_2/rock_wall_2b")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    self:GetPhysicsObject():Wake()
    self:SetUseType(SIMPLE_USE)
    self.Item = Item.new("testitem", {quantity = 1})
    self.GettingRemoved = false
    self:SetCL_Quantity(self.Item.quantity)
    --self:SetModelScale(0.8)
end
function ENT:pickup(player)
    local itemClone = Item.new(self.Item.ID, {quantity = self.Item.quantity})
    local successfull = player.Inventory:tryAdd(itemClone)
    print(successfull)
    if successfull or not itemClone.quantity then
        self:EmitSound("Item.Pickup")
        self:Remove()
        return
    end
    self.Item.quantity = itemClone.quantity
    self:SetCL_Quantity(self.Item.quantity or 0)
    player:EmitSound("HL2Player.UseDeny")
end
function ENT:StartTouch(entity)
	if self:GetClass() ~= entity:GetClass() or self.GettingRemoved or entity.GettingRemoved then return end
    if self.Item.quantity == self.Item.stackSize then return end 
    local successfull = self.Item:tryCombine(entity.Item)
    if (entity.Item.quantity or 0) == 0 then
        entity.GettingRemoved = true
        self:EmitSound("items/gunpickup2.wav", 75, 255, 1, CHAN_AUTO)
        entity:Remove()
    end
    self:SetCL_Quantity(self.Item.quantity or 0)
    entity:SetCL_Quantity(entity.Item.quantity or 0)
end
function ENT:PhysicsCollide( data, phys )
    if self.GettingRemoved then return end
    self:GetPhysicsObject():ApplyForceOffset(-self:GetVelocity() * 5, data.HitPos)
    --self:GetPhysicsObject():ApplyForceCenter(-self:GetVelocity() * 5)
    if data.Speed > 300 then
        local s1 = "physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav"
        self:EmitSound(s1, 90, 200 - math.Clamp(data.Speed / 10, 0, 100), data.Speed / 1000, CHAN_AUTO)
    elseif data.Speed > 50 then
        local s1 = "physics/concrete/rock_impact_hard" .. math.random(1, 3) .. ".wav"
        self:EmitSound(s1, 90, 100 - math.Clamp(data.Speed / 25, 0, 75), data.Speed / 1000, CHAN_AUTO)
    end
end
function ENT:Use(activator)
    if activator:GetEyeTrace().Entity ~= self then return end
    self:pickup(activator)
end