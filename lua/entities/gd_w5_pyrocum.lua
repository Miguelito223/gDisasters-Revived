AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Pyrocumulus"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
	
	local bool recentTor = false
	
	self:Lightning()
	if (CLIENT) then
	
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		
		LocalPlayer().Sounds["Ashstorm_IDLE"]         = createLoopedSound(LocalPlayer(), "streams/disasters/nature/sandstorm_loop.wav")
		LocalPlayer().Sounds["Ashstorm_muffled_IDLE"] = createLoopedSound(LocalPlayer(), "streams/disasters/nature/sandstorm_muffled_loop.wav")

	end
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=88,["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 101000, ["Temperature"] = math.random(52,56), ["Humidity"]    = math.random(5,7), ["BRadiation"]  = 0.1}}
		
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
			self.Original_SkyData["TopColor"]    = Vector(0.1, 0.1,0.1)
			self.Original_SkyData["BottomColor"] = Vector(0.1, 0.1,0.1)
			self.Original_SkyData["DuskScale"]   = 0
			
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
		
		
		setMapLight("a")
		physenv.SetAirDensity(60)
		
		self.SpawnTime = CurTime()
		local data = {}
			data.Color = Color(180,180,188)
			data.DensityCurrent = 0
			data.DensityMax     = 0.6
			data.DensityMin     = 0.1
			data.EndMax         = 50
			data.EndMin         = 40
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0   

		timer.Simple(40, function()
			if !self:IsValid() then return end 
			self:Remove()
		end)	
	
	end
end




function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	if GetConVar("gdisasters_atmosphere"):GetInt() <= 0 then return end
	
	if #ents.FindByClass("gd_w*") >= 1 then return end
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
	ent:Spawn()
	ent:Activate()
	

	
	return ent
end


function ENT:TryChokeOnAsh(v)
	
	if v.NextChokeOnAsh == nil then v.NextChokeOnAsh = CurTime() end
	
	if CurTime() >= v.NextChokeOnAsh then 
		local mouth_attach = v:LookupAttachment("mouth")
		ParticleEffectAttach( "cough_ash", PATTACH_POINT_FOLLOW, v, mouth_attach )
		v:TakeDamage( math.random(8,10), self, self)
		clPlaySound(v, "steams/disasters/player/cough.wav", math.random(80,120), 1)
		
		v.NextChokeOnAsh = CurTime() + math.random(3,7)
	else
	
	end
	
end

function ENT:AffectPlayers()

	local time_mul = math.Round(((math.Clamp((CurTime() - self.SpawnTime),0,20)/20)*100))
	

	
	for k, v in pairs(player.GetAll()) do
		
		
		self:TryChokeOnAsh(v)

		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(time_mul) then
				if math.random(1,3)==1 then
					net.Start("gd_screen_particles")
					net.WriteString("hud/snow")
					net.WriteFloat(math.random(100,1538))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,0.5,0))
					net.Send(v)
				end
				
				local ang = (v:GetPos()-self:GetPos()):Angle().y + 90

				net.Start("gd_clParticles")
				net.WriteString("localized_ash_effect_2")
				
				net.WriteAngle(Angle(0,ang,0))
				net.Send(v)
				
				
				net.Start("gd_clParticles")
				net.WriteString("localized_ash_effect_2")
				
				net.WriteAngle(Angle(0,ang,0))
				net.Send(v)
			
			end
	
		end
		
		if math.random(1,2) == 2 then
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
			if math.random(1,2) == 2 then		
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
				end
			end
		
		self:HailFollowPlayer(v)
		
	end
end

function ENT:HailFollowPlayer(ply)
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	local z         = max.z 
	local pos       = ply:GetPos()
	local hitchance = math.Clamp(100 / ( (#player.GetAll()) ),5,50)
	
	if HitChance( hitchance ) then
			
		if HitChance(95) then
		
			local x = pos.x + math.random(-2000,2000)
			local y = pos.y + math.random(-2000,2000)
			local z = pos.z + 1000
			local hail = ents.Create("gd_d1_hail")
			
			hail:SetPos( Vector(x, y, z ) )
			hail:Spawn()
			hail:Activate()
			hail:GetPhysicsObject():EnableMotion(true)
			hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000) )
			hail:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
		else
		
			local x = pos.x 
			local y = pos.y
			local z = pos.z + 1000
			local hail = ents.Create("gd_d1_hail")
			
			hail:SetPos( Vector(x, y, z ) )
			hail:Spawn()
			hail:Activate()
			hail:GetPhysicsObject():EnableMotion(true)
			hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000) )
		end
	end
	

end


function ENT:Think()
	
	if (CLIENT) then

		
		local muffled_volume = math.Clamp(1 - ( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8), 0, 1)
		local idle_volume = math.Clamp(( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)-0.25, 0, 1)
		
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
		
		if math.random(1,2000)==1 then surface.PlaySound("streams/disasters/nature/thunder"..tostring(math.random(1,3))..".wav") end 

			
	end
	if (SERVER) then
		if !self:IsValid() then return end

		self:AffectPlayers()

		self:Ignite(v)
		
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		

		self:NextThink(CurTime() + t)
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
		physenv.SetAirDensity(2)
		setMapLight("t")
		for k, v in pairs(ents.FindByClass("gd_w2_thunderstorm_cl")) do v:Remove() end
	end
	
	
	if (CLIENT) then

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


function ENT:Lightning()

	local pos = self:GetPos()
	
	timer.Simple(0.1, function()
	if !self:IsValid() then return end
		local ent = ents.Create("gd_w2_thunderstorm_cl")
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()
		
	end)
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end

if (CLIENT) then
	function createLoopedSound(client, sound)
		local sound = Sound(sound)

		CSPatch = CreateSound(client, sound)
		CSPatch:Play()
		return CSPatch
		
	end
	
	
end

function ENT:Ignite(v)
    v:Ignite()
	v:TakeDamage(2, self, self)
end





