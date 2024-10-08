AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Iridescent Cloudy"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Mass                             =  25
ENT.Models                           =  {"models/ramses/models/nature/cloud_iridescent_01.mdl", "models/ramses/models/nature/cloud_iridescent_02.mdl"}  

ENT.LifeMin                          = 10 
ENT.LifeMax                          = 20 

function ENT:Initialize()	

	if (SERVER) then
		self.Life = math.random(self.LifeMin, self.LifeMax)	

		self:SetModelScale(math.random(5,15), 0)
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		

		self:SetAngles( Angle(0,math.random(1,180), 0))
		self:AtmosphericReposition()
		local tint = Color(math.random(155,255), math.random(155,255),math.random(155,255))
		self:SetColor(tint)

		self:SetNoDraw(false)
		
		
	end
end

function ENT:AtmosphericReposition()
	local max_height_below_ceiling, min_height_below_ceiling = 5000,2000
	local height = math.random(min_height_below_ceiling, max_height_below_ceiling)
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	local spawnpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z - height )

		
	self:SetPos( spawnpos )
	
	

end

function ENT:MoveCloud()
	local wind_speed, wind_dir = GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"], GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"]
	local next_pos = self:GetPos() + (wind_dir * (wind_speed/40))
	self:SetPos(next_pos)
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end

		self:MoveCloud()
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




