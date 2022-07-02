AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local BreakDurability = 1
local SoftHarvestSound = "Concrete_Block.ImpactHard"
local HardHarvestSound = "Breakable.Concrete"

local rockModels = {
	"models/props_wasteland/rockcliff01b.mdl",
	"models/props_wasteland/rockcliff01j.mdl",
	"models/props_wasteland/rockcliff01k.mdl"
}
function ENT:Initialize()
    self:SetModel(selectRandom(rockModels))
	--self:SetMaterial("models/props/hr_massive/ground_rock_2/rock_wall_2b")
	//self:SetPos(self:GetPos() - Vector(0, 0, 8))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
	//self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableMotion(false)
	self:SetUseType(SIMPLE_USE)
	self.HarvestState = 0
	self.BreakOnState = BreakDurability
end

function ENT:SpawnFunction(ply, traceResult, class)
	local ent = ents.Create(class)
	ent:SetPos(traceResult.HitPos + Vector(0, 0, 64)) 
	ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
	ent:Spawn()
	ent:Activate()
	undo.Create("prop")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	return ent
end

function ENT:Think()
	if self:GetPhysicsObject():IsMotionEnabled() then
		self:GetPhysicsObject():EnableMotion(false)
	end
end
function ENT:OnTakeDamage( dmginfo )
	--self:RemoveAllDecals()
	local attacker = dmginfo:GetAttacker()
	--if attacker:GetActiveWeapon():GetClass() ~= "weapon_crowbar" then return end
	self.HarvestState = self.HarvestState + 1

	attacker:ChatPrint("" .. self.HarvestState)

	--self:EmitSound(SoftHarvestSound)

	if self.HarvestState >= self.BreakOnState then
		self.HarvestState = 0
		local orePickup = ents.Create("test_ore_pickup")
		orePickup:SetPos(dmginfo:GetDamagePosition())
		orePickup:SetAngles(Angle(math.Rand(0, 180), math.Rand(0, 180), math.Rand(0, 180)))
		orePickup:Spawn()

		--orePickup:EmitSound(HardHarvestSound)
		local mass = orePickup:GetPhysicsObject():GetMass() * 125
		orePickup:GetPhysicsObject():ApplyTorqueCenter(Vector(math.random(0, 1) - 0.5, math.random(0, 1) - 0.5, 0.0001) * mass)
		orePickup:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, mass))
		orePickup:GetPhysicsObject():ApplyForceCenter((dmginfo:GetDamagePosition() - self:GetPos()):GetNormalized() * Vector(mass, mass, 0))
	end
	hook.Run("GF_OnHarvest", attacker, self, self.HarvestState)
end