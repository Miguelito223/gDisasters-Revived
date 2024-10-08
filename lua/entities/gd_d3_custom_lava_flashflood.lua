AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lava flood"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(self.Model)

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		if IsMapRegistered() == true then
			self.Child = createlava(math.random(GetConVar("gdisasters_envdynamicwater_level_min"):GetInt(),GetConVar("gdisasters_envdynamicwater_level_max"):GetInt()), self)
		else
			self:Remove()
			gDisasters:Warning("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.", true) 
		end
			
		
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	
	if IsMapRegistered() == false then 
		ent:SetPos( tr.HitPos + tr.HitNormal * 1  )
	else 
		
		ent:SetPos( getMapCenterFloorPos() )
	end
	
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:IsLinkDestroyed()
	if self.Child == nil or self.Child:IsValid()==false then self:Remove() end

end

function ENT:Think()

	if (SERVER) then
		self:IsLinkDestroyed()
	end

end

function ENT:OnRemove()

end
	
function ENT:Draw()
			
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


