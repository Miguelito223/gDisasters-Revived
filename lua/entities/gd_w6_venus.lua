AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Neptune"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(300,400),["Direction"]=Vector(math.random(-1,1),math.random(-1,1),0)}, ["Pressure"]    = 10000, ["Temperature"] = math.random(430,462), ["Humidity"]    = math.random(0,0), ["BRadiation"]  = 0.1, ["Oxygen"] = 0}}

		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 
		
		self.Original_SkyData = {}
		self.Original_SkyData["TopColor"]    = Vector(0.89, 0.84, 0.64)
		self.Original_SkyData["BottomColor"] = Vector(0.89, 0.84, 0.64)
		self.Original_SkyData["DuskScale"]   = 0
		self.Original_SkyData["SunScale"]   = 2.56
			
		self.Reset_SkyData    = {}
		self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
		self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
		self.Reset_SkyData["DuskScale"]      = 1
		self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
	setMapLight("d")

	self.SpawnTime = CurTime()
	
	local data = {}
		data.Color = Color(250,238,215)
		data.DensityCurrent = 0
		data.DensityMax     = 0.2
		data.DensityMin     = 0.1
		data.EndMax         = 2000
		data.EndMin         = 1000
		data.EndMinCurrent  = 0
		data.EndMaxCurrent  = 0       

	gDisasters_CreateGlobalFog(self, data, true)	
	
	gDisasters_CreateGlobalGFX("hotwave", self)						
		
	end
end

function ENT:AffectPlayers()
	local time_mul = math.Round(((math.Clamp((CurTime() - self.SpawnTime),0,20)/20)*100))

	for k, v in pairs(player.GetAll()) do


		if v.gDisasters.Area.IsOutdoor then
			
			net.Start("gd_clParticles")
			net.WriteString("localized_acid_rain_effect", Angle(0,math.random(1,40),0))
			net.Send(v)
			net.Start("gd_clParticles_ground")
			net.WriteString("rain_splash_effect")
			net.Send(v)	
				
			
			if math.random(1,12) == 1 then
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,250))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	


			end

			if math.random(time_mul) then
				if math.random(1,3)==1 then
					net.Start("gd_screen_particles")
					net.WriteString("hud/snow")
					net.WriteFloat(math.random(100,1538))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,0.5,0))
					net.Send(v)
				end

				net.Start("gd_clParticles")
				net.WriteString("localized_ash_effect_2")
				net.Send(v)
			end


			
		end
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
	if (CLIENT) then

		
		local muffled_volume = math.Clamp(1 - ( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8), 0, 1) - 0.25
		local idle_volume = math.Clamp(( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)-0.25, 0, 1)
		
		if   LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]:ChangeVolume(muffled_volume, 0)
		end
		
		if   LocalPlayer().Sounds["Rainstorm_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_IDLE"]:ChangeVolume(idle_volume, 0)
		end

		if   LocalPlayer().Sounds["Ashstorm_muffled_IDLE"]!=nil then
			 LocalPlayer().Sounds["Ashstorm_muffled_IDLE"]:ChangeVolume(muffled_volume, 0)
		end
		
		if   LocalPlayer().Sounds["Ashstorm_IDLE"]!=nil then
			 LocalPlayer().Sounds["Ashstorm_IDLE"]:ChangeVolume(idle_volume, 0)
		end
		
		if math.random(1, 2) == 1 then
			local x, y, z = LocalPlayer():EyeAngles().x, LocalPlayer():EyeAngles().y, LocalPlayer():EyeAngles().z
			LocalPlayer():SetEyeAngles( Angle(x + (math.random(-100,100)/500), y + (math.random(-100,100)/500), z) )
			util.ScreenShake( LocalPlayer():GetPos(), 0.4, 5, 0.2, 500 )
		end
		
		if math.random(1,1000)==1 then surface.PlaySound("streams/disasters/nature/thunder"..tostring(math.random(1,3))..".wav") end 
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:NextThink(CurTime() + 0.01)
		self:AffectPlayers()
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		local resetdata = self.Reset_SkyData
		GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL

		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(resetdata,0.05)
			end)
		end
		
		setMapLight("t")	
	end

	if (CLIENT) then


		

		if LocalPlayer().Sounds["Rainstorm_IDLE"]!=nil then 
			LocalPlayer().Sounds["Rainstorm_IDLE"]:Stop()
			LocalPlayer().Sounds["Rainstorm_IDLE"]=nil
		end
		
		if LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]!=nil then 
			LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]:Stop()
			LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]=nil
		end
		
		if LocalPlayer().Sounds["Ashstorm_IDLE"]!=nil then 
			LocalPlayer().Sounds["Ashstorm_IDLE"]:Stop()
			LocalPlayer().Sounds["Ashstorm_IDLE"]=nil
		end
		
		if LocalPlayer().Sounds["Ashstorm_muffled_IDLE"]!=nil then 
			LocalPlayer().Sounds["Ashstorm_muffled_IDLE"]:Stop()
			LocalPlayer().Sounds["Ashstorm_muffled_IDLE"]=nil
		end
		
		
	end
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






