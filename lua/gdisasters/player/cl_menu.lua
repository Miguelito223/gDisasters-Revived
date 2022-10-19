
-- SV MENU 
gDisasters_gDisastersSetupTime = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( label )
end

local function AddComboBox( CPanel, title, listofitems, convar)
		
	local combobox, label = CPanel:ComboBox( title, convar)
		
		
	for k, item in pairs(listofitems) do
		combobox:AddChoice(item)
	end
		
	return combobox
end
	
local function CreateTickboxConVariable(CPanel, desc, convarname)
	local CB = AddControlCB(CPanel, desc, convarname)
	
 
	CB.OnChange = function( panel, bVal ) 
	if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() )and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "gdisasters_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	timer.Simple(0.1, function()
	
		if( CB ) then
			CB:SetValue( GetConVar(( convarname )):GetFloat() );
		end
	end)
	
	return CB 
	
end

local function CreateSliderConVariable(CPanel, desc, minvar, maxvar, dp, convarname)
	local CB = CPanel:NumSlider(desc, convarname, minvar, maxvar, dp);
	
 	CB.Scratch.ConVarChanged = function() end	
	CB.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() )and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "gdisasters_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat(tonumber(val) );
			net.SendToServer();
		end
		
	end
		

	timer.Simple(0.1, function()
		
		if( CB ) then
			CB:SetValue( GetConVar(( convarname )):GetFloat() );
		end
	end)
	
	return CB
end

local function gDisastersSVSettings( CPanel )

	AddControlLabel( CPanel, "wind/tornado/water Related Damage options: " )

	CreateTickboxConVariable(CPanel, "Enable Water Related Damage"  , "gdisasters_envdynamicwater_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Tornado Related Damage" ,"gdisasters_envtornado_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Wind Related Damage" ,"gdisasters_wind_candamageconstraints");

	AddControlLabel( CPanel, "Temp options: " )

	CreateTickboxConVariable(CPanel, "Enable Temp Breathing" ,"gdisasters_hud_temp_breathing");
	CreateTickboxConVariable(CPanel, "Enable Temp Vomit" ,"gdisasters_hud_temp_vomit");
	CreateTickboxConVariable(CPanel, "Enable Temp Sneeze" ,"gdisasters_hud_temp_sneeze");

	AddControlLabel( CPanel, "Oxygen options: " )
	
	CreateTickboxConVariable(CPanel, "Enable Oxygen enable" ,"gdisasters_oxygen_enable");
	CreateTickboxConVariable(CPanel, "Enable oxygen damage" ,"gdisasters_oxygen_damage");


	AddControlLabel( CPanel, "Other options: \n\nThe Atmophere option requires a map RESTART to take effect."  )

	CreateTickboxConVariable(CPanel, "Enable Atmosphere"  , "gdisasters_atmosphere");
	CreateTickboxConVariable(CPanel, "Enable Hud"  , "gdisasters_hud_enabled");
	CreateTickboxConVariable(CPanel, "Enable Experimental Overdraw"  , "gdisasters_experimental_overdraw");
	CreateTickboxConVariable(CPanel, "Enable Stormfox2 compatibility"  , "gdisasters_stormfox_enable");
	CreateTickboxConVariable(CPanel, "Enable Day And Night Cycle"  , "gdisasters_dnc_enabled");
end

-- ADVANCED SV MENU
local function gDisastersSVADVSettings( CPanel )

	AddControlLabel( CPanel, "Don't mess with these settings unless you know what you're doing.\n\nAdvanced options: ")
	
	AddControlLabel( CPanel, "Simulation Option: Change the quality of simulation.")
	CreateSliderConVariable(CPanel, "Tornado Simulation Quality", 0.1, 0.50, 2, "gdisasters_envtornado_simquality" );
	CreateSliderConVariable(CPanel, "Earthquake Simulation Quality", 0.1, 0.50, 2, "gdisasters_envearthquake_simquality" );
	CreateSliderConVariable(CPanel, "Water Simulation Quality", 0.1, 0.50, 2, "gdisasters_envdynamicwater_simquality");
	CreateSliderConVariable(CPanel, "Wind Simulation Quality", 0.1, 0.50, 2, "gdisasters_wind_physics_simquality");

	AddControlLabel( CPanel, "Advanced Wind options: " )
	
	CreateTickboxConVariable(CPanel, "Enable Wind physical" ,"gdisasters_wind_physics_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetime" ,"gdisasters_wind_postdamage_nocollide_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetimeout" ,"gdisasters_wind_postdamage_nocollide_basetimeout");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetime spread" ,"gdisasters_wind_postdamage_nocollide_basetimeout_spread");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage reducemass" ,"gdisasters_wind_postdamage_reducemass_enabled");

	AddControlLabel( CPanel, "Advanced Temp options: " )

	CreateTickboxConVariable(CPanel, "Enable Temp Related Damage" ,"gdisasters_hud_temp_damage");
	CreateTickboxConVariable(CPanel, "Enable Temp UpdateVars" ,"gdisasters_hud_temp_updatevars");
	CreateTickboxConVariable(CPanel, "Enable Temp ClientSide" ,"gdisasters_hud_temp_cl");
	CreateTickboxConVariable(CPanel, "Enable Temp ServerSide" ,"gdisasters_hud_temp_sv");

	AddControlLabel( CPanel, "Water/lava flood or tsunami options: " )
	
	CreateSliderConVariable(CPanel, "min flood level" , 0, 10000, 1,"gdisasters_envdynamicwater_level_min");
	CreateSliderConVariable(CPanel, "max flood level", 0, 10000, 1 ,"gdisasters_envdynamicwater_level_max");

	CreateSliderConVariable(CPanel, "Tsunami start level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_startlevel");
	CreateSliderConVariable(CPanel, "Tsunami middel level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_middellevel");
	CreateSliderConVariable(CPanel, "Tsunami end level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_endlevel");

	CreateSliderConVariable(CPanel, "Tsunami speed", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_speed");

	
	AddControlLabel( CPanel, "Tornado options: i need talk about this?")
	
	CreateTickboxConVariable(CPanel, "Enable Custom Tornado Speed" ,"gdisasters_envtornado_manualspeed");
	CreateSliderConVariable(CPanel, "Tornado Speed", 4, 20, 2, "gdisasters_envtornado_speed" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime min", 1, 1000, 0, "gdisasters_envtornado_lifetime_min" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime max", 1, 1000, 0, "gdisasters_envtornado_lifetime_max" );
	CreateSliderConVariable(CPanel, "Tornado Damage", 0, 5000, 0, "gdisasters_envtornado_damage" );

	AddControlLabel( CPanel, "Hud type options: \n\n1: body hud\n\n2: pressure hud\n\n3: earthquake hud")
	
	CreateSliderConVariable(CPanel, "Hud Type", 1, 3, 0, "gdisasters_hud_type" );
	
	
end

local function gDisastersServerGraphics( CPanel )

	AddControlLabel( CPanel, "Antilag collision settings: \n\nPD NC BT: Post Damage No Collide Base Time\n\nCPPPS: Collisions Per Prop Per Second\n\nCAPS:Collisions Average Per Second" )
	
	CreateSliderConVariable(CPanel,"Max CPPPS", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_per_prop");
	CreateSliderConVariable(CPanel,"Max PD NC BT", 0, 1000, 0,"gdisasters_antilag_post_damage_no_collide_base_time");
	CreateSliderConVariable(CPanel,"Max CAPS (s)", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_average" );

	AddControlLabel( CPanel, "Antilag options: remove the lag :)" )
	
	CreateSliderConVariable(CPanel,"Antilag Mode (s)", 0, 2, 0,"gdisasters_antilag_mode" );
	CreateTickboxConVariable(CPanel,"Enable Antilag", "gdisasters_antilag_enabled" );
	
end

local function gDisastersGraphicsSettings( CPanel )

	gDisasters_gDisastersGraphicsSettings_SetupTime = CurTime() 

	local label2 = AddControlLabel( CPanel, "Graphics options: \n\nWind/Temp Type: " )

	local HudW 			= AddComboBox( CPanel, "Hud Wind Display", {"km/h", "mph"}, "gdisasters_hud_windtype")
	local HudT			= AddComboBox( CPanel, "Hud Temperature Display", {"c", "f"}, "gdisasters_hud_temptype")

	local label2 = AddControlLabel( CPanel, "\n\nGP: Ground Particles\n\nWP:Weather Particles\n\nnPass: Number of Passes" )

	local GP = CPanel:NumSlider( "Max GP", "", 0, 1, 1 );
	local WP = CPanel:NumSlider( "Max WP", "", 0, 1, 1 );
	local nPass = CPanel:NumSlider( "Max nPass", "", 0, 20, 1 );

	GP.Scratch.ConVarChanged = function() end 
	GP.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_antilag_ground_particles", tonumber( val))
	end

	WP.Scratch.ConVarChanged = function() end 
	WP.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_antilag_weather_particles", tonumber( val))
	end
	
	nPass.Scratch.ConVarChanged = function() end 
	nPass.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_antilag_number_of_passes", tonumber( val))
	end

	timer.Simple(0.05, function()
		if GP then GP:SetValue(GetConVar(( "gdisasters_antilag_ground_particles" )):GetFloat()) end
		if WP then WP:SetValue(GetConVar(( "gdisasters_antilag_weather_particles" )):GetFloat()) end
		if nPass then nPass:SetValue(GetConVar(( "gdisasters_antilag_number_of_passes" )):GetFloat()) end
	
	end)

end


local function gDisastersAudioSettings( CPanel )
	AddControlLabel( CPanel, "Audio options: " )
	CreateSliderConVariable(CPanel, "Light Wind Volume", 0,1,1, "gdisasters_wind_Light_Wind_sound" );
	CreateSliderConVariable(CPanel, "Moderate Wind Volume", 0,1,1, "gdisasters_wind_Moderate_Wind_sound" );
	CreateSliderConVariable(CPanel, "Heavy Wind Volume", 0,1,1,"gdisasters_wind_Heavy_Wind_sound" );
	AddControlLabel( CPanel, "Hud Audio options: " )
	CreateSliderConVariable(CPanel, "hud Hearth Volume", 0,1,1, "gdisasters_hud_heartbeat_volume" );
	CreateSliderConVariable(CPanel, "hud Warning Volume", 0,1,1, "gdisasters_hud_warning_volume" );
end

local function gDisastersAutospawn( CPanel )
	gDisasters_Autospawn_SetupTime = CurTime() 

	local label = AddControlLabel( CPanel, "Autospawn options: " )
	local AUT = CPanel:NumSlider("Autospawn Time", "", 1, 1000, 0 )
	local AUC = CPanel:NumSlider("Autospawn Chance", "", 0, 1000, 0 )

	AUT.Scratch.ConVarChanged = function() end 
	AUT.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_Autospawn_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_autospawn_timer", tonumber( val))
	end
	
	AUC.Scratch.ConVarChanged = function() end 
	AUC.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_Autospawn_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_autospawn_spawn_chance", tonumber( val))
	end	
	
	timer.Simple(0.05, function()
		if AUT then AUT:SetValue(GetConVar(( "gdisasters_autospawn_timer" )):GetFloat()) end
		if AUC then AUC:SetValue(GetConVar(( "gdisasters_autospawn_spawn_chance" )):GetFloat()) end
	end
	)

	AddControlLabel( CPanel, "Autospawn Box Options: " )

	CreateTickboxConVariable(CPanel, "Autospawn Storm Skybox"  , "gdisasters_autospawn_skybox");
	CreateTickboxConVariable(CPanel, "Autospawn Disable Map Tornadoes"  , "gdisasters_getridmaptor");

	CreateTickboxConVariable(CPanel, "Autospawn Tornados"  , "gdisasters_autospawn");
	CreateTickboxConVariable(CPanel, "Autospawn Disasters"  , "gdisasters_autospawn_disasters");
	CreateTickboxConVariable(CPanel, "Autospawn Weather"  , "gdisasters_autospawn_weather");
	CreateTickboxConVariable(CPanel, "Autospawn Weather/Disasters"  , "gdisasters_autospawn_weatherdisaster");


	
end

local function gDisastersADVGraphicsSettings( CPanel )

	gDisasters_gDisastersADVGraphicsSettings_SetupTime = CurTime() 
			
		
	local label = AddControlLabel( CPanel, "Advanced Graphics options:" )

	local WQ = CPanel:NumSlider(     "Water Quality", "", 1, 3, 0 );
	local FQ = CPanel:NumSlider(     "Fog Quality", "", 1, 8, 0 );

	local dr_ns_label =  AddControlLabel( CPanel, "Section dedicated to Doppler Radar.\nUse with caution." )

	local ScreenRes     = AddComboBox( CPanel, "Resolution", {"4x4","8x8","16x16","32x32","64x64","48x48","128x128"}, "gdisasters_graphics_dr_resolution")
	local Monochromatic = AddComboBox( CPanel, "Monochromatic Mode", {"false", "true"}, "gdisasters_graphics_dr_monochromatic")

	local MaxRD         = CPanel:NumSlider(     "Max Render Distance", "", 1, 600, 0 );
	local RefreshRate   = CPanel:NumSlider(     "Refresh Rate (Hz)", "", 1, 16, 0 );
	local UpdateRate   = CPanel:NumSlider(     "Update  Rate (Hz)", "", 1, 16, 0 );
	
		
	-- on value change, set values 

	
	
	MaxRD.Scratch.ConVarChanged = function() end 
	MaxRD.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersADVGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_graphics_dr_maxrenderdistance", tonumber( val))
	end
	
	UpdateRate.Scratch.ConVarChanged = function() end 
	UpdateRate.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersADVGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_graphics_dr_updaterate", tonumber( val))
	end
	
	RefreshRate.Scratch.ConVarChanged = function() end 
	RefreshRate.OnValueChanged = function( panel, val)
		if (CurTime() - gDisasters_gDisastersADVGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_graphics_dr_refreshrate", tonumber( val))
	end
		
	
	WQ.Scratch.ConVarChanged = function() end
	WQ.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersADVGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_graphics_water_quality", 4 - tonumber( val ) )		
	end

	FQ.Scratch.ConVarChanged = function() end
	FQ.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersADVGraphicsSettings_SetupTime) < 1 then return end 
		RunConsoleCommand( "gdisasters_graphics_fog_quality", 4 - tonumber( val ) )		
	end
	
	-- on panel setup, this will set the values for sliders and buttons to their original stored values 
	
	
	timer.Simple(0.05, function()
	
		if WQ then WQ:SetValue(GetConVar(( "gdisasters_graphics_water_quality" )):GetFloat()) end
		if FQ then FQ:SetValue(GetConVar(( "gdisasters_graphics_fog_quality" )):GetFloat()) end
		
		if MaxRD then MaxRD:SetValue(GetConVar(( "gdisasters_graphics_dr_maxrenderdistance" )):GetFloat()) end 
		if UpdateRate then UpdateRate:SetValue(GetConVar(( "gdisasters_graphics_dr_updaterate" )):GetFloat()) end 
		if RefreshRate then RefreshRate:SetValue(GetConVar(( "gdisasters_graphics_dr_refreshrate" )):GetFloat()) end 
	end)
	
end


hook.Add( "PopulateToolMenu", "gDisasters_PopulateMenu", function()

	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersSVADSettings", "Advanced", "", "", gDisastersSVADVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersSVSettings", "Main", "", "", gDisastersSVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersAutospawn", "Autospawn", "", "", gDisastersAutospawn )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersServerGraphics", "SVGraphics", "", "", gDisastersServerGraphics )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersAudioSettings", "Volume", "", "", gDisastersAudioSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersADVGraphicsSettings", "Advanced Graphics", "", "", gDisastersADVGraphicsSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersGraphicsSettings", "Graphics", "", "", gDisastersGraphicsSettings )

end );
