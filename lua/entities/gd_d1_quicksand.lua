AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Quicksand"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/sand"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}  


function ENT:Initialize()	
	if (CLIENT) then
		SetMDScale(self, Vector(1,1,0.05))
	end
	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetMaterial(self.Material)
		
		self:SetTrigger( true )

		self:SetModelScale( math.random(1,4) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))

		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		

		
		
		
		
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end






function ENT:Touch( entity )

	local vlength = entity:GetVelocity():Length()
	local eye = entity:EyePos()	
	
	if vlength > 100 then return end 
	
	if entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot()then
		
		
		if entity:IsPlayer() then
			entity:SetPos( entity:GetPos() - Vector(0,0,3))
		else
			entity:SetPos( entity:GetPos() - Vector(0,0,40))
		end
		
	
	else
		entity:SetPos( entity:GetPos() - Vector(0,0,3))
	end
	
	if eye.z <= getMapCenterFloorPos().z then
		entity:SetNWBool("IsUnderGround", true)
	else
		entity:SetNWBool("IsUnderGround", false)
	end
end

function ENT:DrownUnderGround()
	for k, entity in pairs(ents.GetAll()) do
		local eye = entity:EyePos()
		
		if eye.z <= getMapCenterFloorPos().z then
			entity:SetNWBool("IsUnderGround", true)
		else
			entity:SetNWBool("IsUnderGround", false)
		end
	end
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		self:DrownUnderGround()
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()
	for k, v in pairs(ents.GetAll()) do
		v:SetNWBool("IsUnderGround", false)
	end
end

function ENT:Draw()



	self:DrawModel()
	
end




