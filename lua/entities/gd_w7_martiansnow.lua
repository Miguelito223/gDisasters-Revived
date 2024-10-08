AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Martian Snow Storm"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	if (CLIENT) then
	
		
		
		LocalPlayer().Sounds["Sandstorm_IDLE"]         = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/sandstorm_loop.wav")
		LocalPlayer().Sounds["Sandstorm_muffled_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/sandstorm_muffled_loop.wav")
	end
	if (SERVER) then

		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(50,95),["Direction"]=Vector(math.random(-1,1),math.random(-1,1),0)}, ["Pressure"]    = 96000, ["Temperature"] = -100, ["Humidity"]    = math.random(10,45), ["BRadiation"]  = 100, ["Oxygen"]  = 5}}

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
			self.Original_SkyData["TopColor"]    = Vector(0.2, 0.3, 0.2)
			self.Original_SkyData["BottomColor"] = Vector(0.05, 0.2, 0.05)
			self.Original_SkyData["DuskScale"]   = 0
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0,0.40,0)
		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
		self:CreateSandDecals()
		setMapLight("c")		
		gDisasters_CreateGlobalGFX("sandstormy", self)	
	


		local data = {}
			data.Color = Color(125,174,125)
			data.DensityCurrent = 0
			data.DensityMax     = 0.25
			data.DensityMin     = 0.05
			data.EndMax         = 10050
			data.EndMin         = 100
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		gDisasters_CreateGlobalFog(self, data, true)	
		
		
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

function ENT:SpawnSand()

	if HitChance(2) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
			start = startpos,
			endpos = startpos - Vector(0,0,50000),
		} )

		local endpos   = tr.HitPos
		
		if #ents.FindByClass("gd_d1_quicksand") < 10 then
			

			local ice = ents.Create("gd_d1_quicksand")
			ice:Spawn()
			ice:Activate()	
			ice:SetPos( tr.HitPos )
			ice:SetAngles( (tr.HitNormal:Angle()) - Angle(-90,0,0) ) 
			
			timer.Simple( math.random(10,20), function()
				if ice:IsValid() then ice:Remove() end
				
			end)
		
		end
	
	end
end

function ENT:AffectPlayers()
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if math.random(1,3) == 1 then
			
				
				net.Start("gd_clParticles")
				net.WriteString("localized_acid_rain_effect", Angle(0,math.random(1,40),0))
				net.Send(v)
				net.Start("gd_clParticles_ground")
				net.WriteString("rain_splash_effect", Angle(0,math.random(1,40),0))
				net.Send(v)
				
			end
			
			if math.random(1,4)==1 then
				net.Start("gd_clParticles")
				net.WriteString("localized_dust_effect")
				net.Send(v)		
			end
			
			if math.random(1,10)==10 then
			net.Start("gd_clParticles")
			net.WriteString("localized_snow_effect", Angle(0,math.random(1,40),0))
			net.Send(v)		
			net.Start("gd_clParticles_ground")
			net.WriteString("snow_ground_effect", Angle(0,math.random(1,40),0))
			net.Send(v)		
			end
			
			if math.random(1,10) == 10 then
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,228))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	
			end
			
			if math.random(1,10)==10 then
				
				net.Start("gd_screen_particles")
				net.WriteString(table.Random({"hud/sand_1","hud/sand_2","hud/sand_3"}))
				net.WriteFloat(math.random(100,438))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,0.5,0))
				net.Send(v)
					
			end
			
			if math.random(1,6) == 1 then
				net.Start("gd_screen_particles")
				net.WriteString("hud/snow")
				net.WriteFloat(math.random(5,228))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	
			end
			
			if HitChance(0.5) then
			
				InflictDamage(v, self, "acid", math.random	(15,20))
				InflictDamage(v, self, "cold", math.random	(5,10))
			
			end
			
		end
	end
end

function ENT:CreateSandDecals()
	for k, v in pairs(player.GetAll()) do
		net.Start("gd_createdecals")
		if HitChance(15) then
			net.WriteString("snow")	
		else
			net.WriteString("sand")	
		end
		net.WriteBool(self.CreatedDecals)
		net.Send(v)
	end
end


function ENT:Think()
	if (CLIENT) then

		
		local muffled_volume = math.Clamp(1 - ( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8), 0, 1)
		local idle_volume = math.Clamp(( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)-0.25, 0, 1)
		
		if   LocalPlayer().Sounds["Sandstorm_muffled_IDLE"]!=nil then
			 LocalPlayer().Sounds["Sandstorm_muffled_IDLE"]:ChangeVolume(muffled_volume, 0)
		end
		
		if   LocalPlayer().Sounds["Sandstorm_IDLE"]!=nil then
			 LocalPlayer().Sounds["Sandstorm_IDLE"]:ChangeVolume(idle_volume, 0)
		end
		
		if math.random(1, 2) == 1 then
			local x, y, z = LocalPlayer():EyeAngles().x, LocalPlayer():EyeAngles().y, LocalPlayer():EyeAngles().z
			LocalPlayer():SetEyeAngles( Angle(x + (math.random(-100,100)/500), y + (math.random(-100,100)/500), z) )
			util.ScreenShake( LocalPlayer():GetPos(), 0.4, 5, 0.2, 500 )
		end
		
		if math.random(1,2000)==1 then surface.PlaySound("streams/disasters/nature/thunder"..tostring(math.random(1,3))..".wav") end
		
		
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()	
		self:SpawnSand()	

		self:NextThink(CurTime() + 0.01)
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

		
		if LocalPlayer().Sounds["Sandstorm_IDLE"]!=nil then 
			LocalPlayer().Sounds["Sandstorm_IDLE"]:Stop()
			LocalPlayer().Sounds["Sandstorm_IDLE"]=nil
		end
		
		if LocalPlayer().Sounds["Sandstorm_muffled_IDLE"]!=nil then 
			LocalPlayer().Sounds["Sandstorm_muffled_IDLE"]:Stop()
			LocalPlayer().Sounds["Sandstorm_muffled_IDLE"]=nil
		end
		
	end
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






