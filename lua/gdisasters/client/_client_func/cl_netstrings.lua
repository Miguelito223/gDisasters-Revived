net.Receive("gd_ambientlight", function()

	local tr = util.TraceLine( {
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos() - Vector(0,0,100),
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
	} )

	if tr.Entity:IsValid() then LocalPlayer().AmbientLight = Vector(0,0,0) return end 

	LocalPlayer().AmbientLight = render.ComputeLighting(  tr.HitPos, tr.HitNormal )

	net.Start("gd_ambientlight")
	net.WriteEntity(LocalPlayer())
	net.WriteVector(LocalPlayer().AmbientLight)
	net.SendToServer()

end)

net.Receive("gd_createdecals", function()
	if GetConVar("gdisasters_graphics_experimental_overdraw"):GetInt() != 1 then return end

	decal = net.ReadString()
	bool = net.ReadBool()

	if bool then return end
	bool = true

	for i=0, 25 do
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]

		local startpos  = Vector(math.random(min.x,max.x), math.random(min.y,max.y), max.z )
		
		local tr = util.TraceLine( {
			start = startpos,
			endpos = startpos - Vector(0,0,50000),
			mask = MASK_SOLID_BRUSHONLY
		} )	

		util.Decal(decal, tr.HitPos + tr.HitNormal,  tr.HitPos - tr.HitNormal)
	end
end)

net.Receive("gd_clParticles", function()
	if GetConVar("gdisasters_graphics_enable_weather_particles"):GetInt() <= 0 then return end

	local effect = net.ReadString()
	local angle  = convert_VectorToAngle(-GetGlobalVector("gDisasters_Wind_Direction"))
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )

end)

net.Receive("gd_clParticles_ground", function()
	if GetConVar("gdisasters_graphics_enable_ground_particles"):GetInt() <= 0 then return end
	for k,v in pairs(player.GetAll()) do
		if !v:IsOnGround() then return end
	end

	local effect = net.ReadString()
	local angle  = convert_VectorToAngle(-GetGlobalVector("gDisasters_Wind_Direction"))
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )

end)

net.Receive("gd_CreateCeilingWaterDrops", function()

	if GetConVar("gdisasters_graphics_draw_ceiling_effects"):GetInt() <= 0 then return end 

	timer.Create("CeilingWaterDrops", 10, 0, function()
		AddCeilingWaterDrops("rain_ceiling_drops_effect", "rain_ceiling_drop_ground_splash", 2, 1, Angle(0,0,0))
	end)

end)

net.Receive("gd_RemoveCeilingWaterDrops", function()

	if GetConVar("gdisasters_graphics_draw_ceiling_effects"):GetInt() <= 0 then return end 

	timer.Stop("CeilingWaterDrops")
	timer.Remove("CeilingWaterDrops")

end)


net.Receive("gd_seteyeangles_cl", function()

	local offset = net.ReadAngle()
	local angle  = LocalPlayer():EyeAngles()
	x, y, z = offset.x, offset.y, offset.z 
	x2, y2, z2 = angle.x, angle.y, angle.z 


	LocalPlayer():SetEyeAngles( Angle(x+x2, y+y2, z+z2) )



end)

net.Receive("gd_screen_particles", function()

	if GetConVar("gdisasters_graphics_enable_screen_particles"):GetInt() <= 0 then return end

	if LocalPlayer().ScreenParticles == nil then LocalPlayer().ScreenParticles = {} end

	local texture  = net.ReadString()
	local size     = net.ReadFloat()
	local life     = net.ReadFloat() + CurTime()

	if GetConVar("gdisasters_graphics_enable_manual_number_of_screen_particles"):GetInt() == 1 then
		number   = math.random(0,GetConVar("gdisasters_graphics_number_of_screen_particles"):GetFloat())
	else
		number   = net.ReadFloat()
	end

	local vel      = net.ReadVector()


	for i=0, number do
		local pos      = Vector( math.random(0,ScrW()), math.random(0,ScrH()), 0) 
		local center   = pos - Vector(size/2,size/2,0)

		LocalPlayer().ScreenParticles[#LocalPlayer().ScreenParticles+1] = {["Texture"]=surface.GetTextureID(texture),
																			["Material"]=Material(texture),
																			["Size"]   = size, 
																			["Life"]   = life,
																			["Pos"]    = center,
																			["Velocity"] = vel
																			}
		hook.Add( "RenderScreenspaceEffects", "Draw Particles", gfx_screenParticles)
	end	

end)

net.Receive("gd_lightning_bolt", function()

	local ent1   = net.ReadEntity()
	local ent2   = net.ReadEntity()
	local effect = net.ReadString()

	if !ent1:IsValid() or !ent2:IsValid() then return end


	local CPoint0 = {
		["entity"] = ent1,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}
	local CPoint1 = {
		["entity"] =  ent2,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}


	ent1:CreateParticleEffect(effect,{CPoint0,CPoint1})


end)

net.Receive("gd_soundwave", function()

	local s 	 = net.ReadString()
	local stype 	 = net.ReadString() -- "mono or stereo or 3d"
	local pos  		 = net.ReadVector() or LocalPlayer():GetPos() -- epicenter
	local pitchrange = net.ReadTable() or {100,100}

	if stype == "mono" then
		surface.PlaySound( s )
	elseif stype == "stereo" then
		LocalPlayer():EmitSound( s, 100, math.random(pitchrange[1], pitchrange[2]), GetConVar("gdisasters_volume_soundwave"):GetFloat() )
	elseif stype == "3d" then
		sound.Play( s,  pos, 150, math.random(pitchrange[1], pitchrange[2]), GetConVar("gdisasters_volume_soundwave"):GetFloat() )
	end



end)

net.Receive("gd_soundwave_stop", function()

	local s 	 = net.ReadString()
	local t 	 = net.ReadString()
	
	if t == "mono" then
		surface.StopSound(s)
	elseif t == "stereo" then
		LocalPlayer():StopSound(s)
	elseif t == "3d" then
		sound.Stop(s)
	end		
	

end)

net.Receive("gd_shakescreen", function()

	if GetConVar("gdisasters_graphics_shakescreen_enable"):GetInt() == 0 then return end

	local duration = net.ReadFloat()
	local a        = net.ReadFloat() or 25
	local f        = net.ReadFloat() or 25

	util.ScreenShake( LocalPlayer():GetPos(), a, f, duration, 10000 )



end)


net.Receive("gd_sendsound", function()

	local sound  = net.ReadString()
	local pitch  = net.ReadFloat() or 100
	local volume = net.ReadFloat() or 1
	LocalPlayer():EmitSound(sound, 100, pitch, volume)



end)

net.Receive("gd_stopsound", function()

	local sound  = net.ReadString()
	LocalPlayer():StopSound(sound)



end)

net.Receive("gd_isOutdoor", function()
	isOutside                = net.ReadBool()

	if LocalPlayer().gDisasters == nil then return end


	LocalPlayer().gDisasters.Outside.IsOutside     = isOutside




	if isOutside then

		LocalPlayer().gDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().gDisasters.Outside.OutsideFactor, 100)

		LocalPlayer().gDisasters.Fog.Data.DensityCurrent =  Lerp( 0.02, LocalPlayer().gDisasters.Fog.Data.DensityCurrent, LocalPlayer().gDisasters.Fog.Data.DensityMax )
		LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  =  Lerp( 0.02, LocalPlayer().gDisasters.Fog.Data.EndMinCurrent, LocalPlayer().gDisasters.Fog.Data.EndMin )
	else
		LocalPlayer().gDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().gDisasters.Outside.OutsideFactor, 0)
		LocalPlayer().gDisasters.Fog.Data.DensityCurrent =  Lerp( 0.01, LocalPlayer().gDisasters.Fog.Data.DensityCurrent, LocalPlayer().gDisasters.Fog.Data.DensityMin )
		LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  =  Lerp( 0.01, LocalPlayer().gDisasters.Fog.Data.EndMinCurrent, LocalPlayer().gDisasters.Fog.Data.EndMax )
	end

end)




net.Receive("gd_seteyeangles_cl", function()

	local offset = net.ReadAngle()
	local angle  = LocalPlayer():EyeAngles()
	x, y, z = offset.x, offset.y, offset.z 
	x2, y2, z2 = angle.x, angle.y, angle.z 


	LocalPlayer():SetEyeAngles( Angle(x+x2, y+y2, z+z2) )



end)



net.Receive( "gd_maplight_cl", function( len, pl ) 
	timer.Simple(0.1, function()
		render.RedownloadAllLightmaps()
	end)
end )

net.Receive("gd_removegfxfog", function()

	local remove_fog = net.ReadBool()
	local remove_gfx = net.ReadBool()

	if remove_fog then
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_RenderFog")
		hook.Remove("SetupSkyboxFog", "gd_RenderFogSkybox")
		hook.Remove("SetupWorldFog", "gd_RenderFogWorld")
		LocalPlayer().gDisasters.Fog.Parent = "none"	

	elseif remove_gfx then
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") 
		LocalPlayer().gDisasters.GFX.Effect = "none" 
		LocalPlayer().gDisasters.GFX.Parent = false 

	
	end

end)

net.Receive("gd_resetoutsidefactor", function()

	LocalPlayer().gDisasters.Outside.OutsideFactor = 0 

end)	

net.Receive("gd_createfog", function()

	local entity = net.ReadEntity()
	local oq     = net.ReadBool()
	local info   = net.ReadTable()

	LocalPlayer().gDisasters.Fog.Data   = info
	LocalPlayer().gDisasters.Fog.Parent = entity
	LocalPlayer().gDisasters.Fog.OQ     = oq

	gDisasters_Effects["RENDERFOG"]()

end)


net.Receive("gd_creategfx", function()

	local entity = net.ReadEntity()
	local effect  = net.ReadString()

	LocalPlayer().gDisasters.GFX.Parent = entity
	LocalPlayer().gDisasters.GFX.Effect = effect

	gDisasters_Effects[effect]()


end)

net.Receive( "gd_entity_exists_on_server", function() 
	local string = net.ReadString()
	gDisasters.CachedExists[string] = ents.FindByClass(string)

	if !IsValid(gDisasters.CachedExists[string]) then
		gDisasters.CachedExists[string] = ents.Create(string)
		gDisasters.CachedExists[string]:Spawn()
		gDisasters.CachedExists[string]:Activate()
	end
end)

net.Receive("gd_WeatherChange", function()
	currentWeather = net.ReadString()
	print("El clima ha cambiado a: " .. currentWeather)
end)





