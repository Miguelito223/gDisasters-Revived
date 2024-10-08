AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Firenado"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      

ENT.Data                             = {GroundSpeed = {}, MaxFunnel = {}, MinFunnel = {}, Life={}, MaxGroundFunnel={}, MinGroundFunnel={}}
ENT.Data.Effect                      = {"mini_lavanado_hd_main"}
ENT.Data.Parent                      = nil
ENT.Data.ShouldFollowPath            = true
ENT.Data.EnhancedFujitaScale         = "-1"

ENT.Data.MaxFunnel.Height 			 = 2000
ENT.Data.MaxFunnel.Radius 			 = 700 -- funnel radius at max height
ENT.Data.MinFunnel.Height			 = -50   
ENT.Data.MinFunnel.Radius 			 = 700    -- funnel radius at min height

ENT.Data.GroundSpeed.Min  			 = 3
ENT.Data.GroundSpeed.Max 			 = 6



ENT.Data.MaxGroundFunnel.Height      = -1
ENT.Data.MaxGroundFunnel.Radius      = -1
ENT.Data.MinGroundFunnel.Height      = -1
ENT.Data.MinGroundFunnel.Radius      = -1



function ENT:Initialize()		
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetNoDraw(true)
		
		self.Data.Parent = self
		
		self.TornadoENT = createTornado(table.Copy(self.Data))
		self:SetNWEntity("TornadoENT", self.TornadoENT)
		
	end
	self:PostSpawn()
end

function ENT:PostSpawn()
	local me  = self  
		
	if (SERVER) then 
	function self.TornadoENT:DamagingAura()
		
		if CurTime() >= self.NextFireDamageTime then
			self.NextFireDamageTime = self.NextFireDamageTime + 0.4 
			 self:OnDamagingAura()
			---
		else 
		
		end
	
	end
	
	function self.TornadoENT:Physics(crap)
	end
	
	function self.TornadoENT:OnDamagingAura()
		
		
		local pos         = self:GetPos() + Vector(0,0,self.Data.MaxGroundFunnel.Height)
		local funnel_ents = FindInCone(pos, self.Data.MaxFunnel.Height, self.Data.MinFunnel.Height, self.Data.MaxFunnel.Radius, self.Data.MinFunnel.Radius, true )
		

		for k, v in pairs(funnel_ents) do
			
			local radius =         v[2]
			local ent              = v[1] 
			local entpos 		   = ent:GetPos()
			
			local height              =  self.Data.MaxFunnel.Height - ((self:GetPos().z + self.Data.MaxFunnel.Height) - ent:GetPos().z)

			if ent:IsValid() and self:CanBeSeenByTheWind(ent) then 

				if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
					InflictDamage(ent, me, "fire", 8)
					ent:Ignite(3)

					if ent:IsPlayer() and ent:Alive() and ent:Health() <= 5 then	
						MakeBurn( ent )
					elseif ent:Health() <= 5 and ent:IsNPC() or ent:IsNextBot() then
						MakeBurn( ent )
					end
				else
		
					if ent:GetClass() != self and ent:IsSolid() and (!ent:IsPlayer() and !ent:IsNPC()) then
						if math.random(1,2) == 1 then
							ent:Ignite(math.random(3,5),0)
							MakeBurn( ent )
						end
					end
				end
			end
			
		end
		
	
	
	end
	
	function self.TornadoENT:Think()
		if (SERVER) then
			if !self:IsValid() then return end
			
			self:Move()
			--self:Physics()
			self:IsParentValid()
			self:DamagingAura()
			
			
			self:NextThink(CurTime() + 0.01)
			return true
		end
		
	end
	
	function self.TornadoENT:CustomPostSpawn()
		self.NextFireDamageTime = CurTime() 
		self:GetRidOfSounds()
	
		
		timer.Simple(1, function()
			if !self:IsValid() then return end
			local sound = Sound(table.Random( {"streams/disasters/environment/wind_shared/firenado.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_1.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_2.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_3.wav"}))

			CSPatch = CreateSound(self, sound)
			CSPatch:SetSoundLevel( 100 )
			CSPatch:Play()
			CSPatch:ChangeVolume( 1 )
			self.Sound = CSPatch
		end)
		
	end
	self.TornadoENT:CustomPostSpawn()

	end
	

	
	
	
	
	if (CLIENT) then 
	
		timer.Simple(1, function()
			if !self:IsValid() then return end 
			self.TornadoENT = self:GetNWEntity("TornadoENT")
			
			function self.TornadoENT:CustomPostSpawn()
				self.NextFireDamageTime = CurTime() 
				
				self:GetRidOfSounds()
				
				timer.Simple(1, function()
					if !self:IsValid() then return end
					local sound = Sound(table.Random( {"streams/disasters/environment/wind_shared/firenado.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_1.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_2.wav", "streams/disasters/environment/wind_shared/small_firenado_loop_3.wav"}))

					CSPatch = CreateSound(self, sound)
					CSPatch:SetSoundLevel( 100 )
					CSPatch:Play()
					CSPatch:ChangeVolume( 1 )
					self.Sound = CSPatch
				end)
				
			end
			
			function self.TornadoENT:Think()
			


				if (CLIENT) then 
			
					local dlight = DynamicLight( self:EntIndex() )
					if ( dlight ) then
						dlight.pos = self:GetPos()
						dlight.r = 255
						dlight.g = 12
						dlight.b = 0
						dlight.brightness = 12
						dlight.Decay = 5
						dlight.Size = 1024
						dlight.DieTime = CurTime() + 0.4
					end
				end
				
			end
			
			
			self.TornadoENT:CustomPostSpawn()
		end)
	
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




function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
	
		self:NextThink(CurTime() + 1)
		return true
	end
end









