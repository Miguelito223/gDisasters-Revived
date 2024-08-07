AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Volcanic rock"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = {"models/ramses/models/nature/volcanic_rock_03_128.mdl","models/ramses/models/nature/volcanic_rock_02_128.mdl","models/ramses/models/nature/volcanic_rock_01_128.mdl", "models/ramses/models/nature/volcanic_rock_03_64.mdl", "models/ramses/models/nature/volcanic_rock_02_64.mdl", "models/ramses/models/nature/volcanic_rock_01_64.mdl"}

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(table.Random(self.Model))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(700)
			phys:Wake()
		end 		
		
		phys:EnableDrag( false )
		
		timer.Simple(20, function()
			if !self:IsValid() then return end
			self:Remove()
		end)
			
		timer.Simple(0.1, function()
			if !self:IsValid() then return end	
			ParticleEffectAttach("meteor_burnup_main", PATTACH_POINT_FOLLOW, self, 0)
		end)

	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -1.00  ) 
	ent:Spawn()
	ent:Activate()
	return ent
	
end


function ENT:PhysicsCollide( data, phys )
	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * -200
	tr.endpos = tr.start + self:GetForward() * 500
	tr.filter = { self, physobj }
	trace = util.TraceLine( tr )

	if( trace.HitSky ) then
	
		self:Remove()
		
		return
		
	end

	if ( data.Speed > 200 ) then 
			
		self:Explode()

		ParticleEffect("lavabomb_explosion_main", data.HitPos, Angle(0,0,0), nil)
		
		local h = data.HitPos + data.HitNormal
		local p = data.HitPos - data.HitNormal
		util.Decal("Scorch", h, p )
	
	end
end

function ENT:Explode()
	
	local sound = table.Random({"streams/event/explosion/explosion_medium_a.mp3","streams/event/explosion/explosion_medium_b.mp3","streams/event/explosion/explosion_medium_e.mp3","streams/event/explosion/explosion_medium_f.mp3","streams/event/explosion/explosion_medium_g.mp3"})

	CreateSoundWave(sound, self:GetPos(), "3d" ,340.29/2, {80,100}, 5)
	
	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos( self:GetPos() );
	pe:SetKeyValue( "Magnitude", 1500 );
	pe:SetKeyValue( "radius", 2000 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	util.BlastDamage( self, self, self:GetPos()+Vector(0,0,12), 1200, math.random( 10, 20 ) )		

	self:Remove()
	
end

function ENT:Think()

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	
		
	if (SERVER) then

		if isinWater(self) then 
			self:Remove() 
		elseif isinLava(self) then
			self:Remove()
		end

		for k,v in pairs(ents.GetAll()) do
		
			local dist = (self:GetPos() - v:GetPos()):Length() 

			if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then

				if ( dist <= 400 ) and v:IsValid() and self:IsValid() then
				
					InflictDamage(v, self, "fire", math.random(2,4))
				
				
				end

			end

			if ( dist <= 400 ) and v:IsValid() and self:IsValid() and v != self and (v:GetClass() == "prop_physics") then v:Ignite() end
		
		end
	
		self:NextThink(CurTime() + t)
		return true
	
	end
			
end


function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end




