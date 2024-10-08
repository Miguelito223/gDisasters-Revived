AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Steam Devil"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100
ENT.Effects                          = {"steam_devil_small", "steam_devil_medium", "steam_devil_big"}
ENT.MaxSpeed                         = 1
function ENT:Initialize()		
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetNoDraw(true)
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self.SpeedBoost = 0
		
		self.MovementVector = Vector(math.random(-100,100)/100,math.random(-100,100)/100,0)
		
		local effect  = table.Random(self.Effects)
		self.OriginalEffect = effect
		self.CurrentParticleEffect = effect
		
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)
		
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:SpeedBoostDecay()
	self.SpeedBoost = math.Clamp(self.SpeedBoost - 0.01,0,3)

end

function ENT:OverWater()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,11),
		mask   = MASK_WATER 
	} )
	
	return tr.HitWorld
	
end

function ENT:PlayParticleEffect()
	local isOnWater    = self:OverWater()
	local water_effect = self.OriginalEffect.."_water"
	local org_effect   = self.OriginalEffect

	
	if isOnWater==true and self.CurrentParticleEffect != water_effect then
		self.CurrentParticleEffect = water_effect
		self:StopParticles()
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)

	elseif isOnWater==false and  self.CurrentParticleEffect != self.OriginalEffect then
		self.CurrentParticleEffect = org_effect
		self:StopParticles()
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)	
	end
	


end


function ENT:Movement()

	local vector = self.MovementVector + ((Vector((math.random(-10,10)/100) * math.sin(CurTime()),(math.random(-10,10)/100) * math.sin(CurTime()), 0) ))
	self.MovementVector = Vector(math.Clamp(vector.x,-(self.MaxSpeed),(self.MaxSpeed)), math.Clamp(vector.y,-(self.MaxSpeed),(self.MaxSpeed)), 0) * (1+self.SpeedBoost)
	
	if math.random(1,500)==500  then self.SpeedBoost = math.random(120,220)/100 end
	
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,50000),
		mask   = MASK_WATER + MASK_SOLID_BRUSHONLY 
	} )
	
	self:SetPos( tr.HitPos + Vector(0,0,10) + vector ) 

	
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		
		local t =   (66/ ( 1/engine.TickInterval())) * 0.01	
		
		self:SpeedBoostDecay()
		self:Movement()
		self:PlayParticleEffect()
		
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		self:StopParticles()
	end
end








