@tool
extends EditorPlugin

func _enter_tree():
	var HeightWeightGradient = ResourceLoader.load("res://addons/SunshineVolumetricClouds/HeightWeightGradient.tres");
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_HeightWeightGradient", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER2D, HeightWeightGradient);
	
	var BaseNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseTexture.tres");
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_BaseNoiseTexture", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER3D, BaseNoiseTexture);
	
	var DetailNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseDetailTexture.tres");
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_DetailNoiseTexture", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER3D, DetailNoiseTexture);
	
	var LargeScaleNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseLargeScaleTexture.tres");
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_LargeScaleNoiseTexture", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER3D, LargeScaleNoiseTexture);
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_SunDirection", RenderingServer.GLOBAL_VAR_TYPE_VEC3, Vector3.UP);
	RenderingServer.global_shader_parameter_add("SunshineClouds_SunColor", RenderingServer.GLOBAL_VAR_TYPE_COLOR, Color(1, 1, 1));
	RenderingServer.global_shader_parameter_add("SunshineClouds_FogColor", RenderingServer.GLOBAL_VAR_TYPE_COLOR, Color(1, 1, 1));
	RenderingServer.global_shader_parameter_add("SunshineClouds_AmbientColor", RenderingServer.GLOBAL_VAR_TYPE_COLOR, Color(0, 0, 0));
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_UseFog", RenderingServer.GLOBAL_VAR_TYPE_BOOL, true);
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_WindDirection", RenderingServer.GLOBAL_VAR_TYPE_VEC2, Vector2.ZERO);
	RenderingServer.global_shader_parameter_add("SunshineClouds_WindSpeed", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.003);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsGlobalScale", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 10000.0);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsDetailNoiseScale", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 5.921);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsDetailNoisePower", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 1.048);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsLargeScaleNoiseScale", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.216);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsLargeScaleNoisePower", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 3.435);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsBaseNoiseScale", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 1.761);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsCutoff", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.213);
	
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsFloor", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 80.0);
	RenderingServer.global_shader_parameter_add("SunshineClouds_CloudsCeiling", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 2000.0);

func _exit_tree():
	print_rich("[b]Sunshine Clouds[/b] removal beginning...");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_HeightWeightGradient");
	print_rich("[b]SunshineClouds_HeightWeightGradient:[/b] Removed.");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_BaseNoiseTexture");
	print_rich("[b]SunshineClouds_BaseNoiseTexture:[/b] Removed.");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_DetailNoiseTexture");
	print_rich("[b]SunshineClouds_DetailNoiseTexture:[/b] Removed.");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_LargeScaleNoiseTexture");
	print_rich("[b]SunshineClouds_LargeScaleNoiseTexture:[/b] Removed.");
	
	RenderingServer.global_shader_parameter_remove("SunshineClouds_SunDirection");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_SunColor");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_FogColor");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_AmbientColor");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_UseFog");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_WindDirection");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_WindSpeed");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsGlobalScale");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsDetailNoiseScale");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsDetailNoisePower");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsLargeScaleNoiseScale");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsLargeScaleNoisePower");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsBaseNoiseScale");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsFloor");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsCeiling");
	RenderingServer.global_shader_parameter_remove("SunshineClouds_CloudsCutoff");
	print_rich("[b]Noise Settings:[/b] Removed.");
