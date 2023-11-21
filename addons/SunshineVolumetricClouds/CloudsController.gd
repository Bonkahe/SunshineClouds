@tool
@icon("res://addons/SunshineVolumetricClouds/SunshineIcon.svg")
extends Node
class_name CloudsController;

@export var updateConstantly = false;
@export var sunLight : DirectionalLight3D;
@export var worldEnvironment : WorldEnvironment;

@export_group("Textures")
@export var gradientControlTexture : GradientTexture1D;
@export var baseNoiseTexture : NoiseTexture3D;
@export var detailNoiseTexture : NoiseTexture3D;
@export var largeScaleNoiseTexture : NoiseTexture3D;

@export_group("Weather Controls")
@export var windDirection : Vector2 = Vector2(1, 0);
@export var windSpeed : float = 0.003;

@export_range(0,2) var cloudsCutoff : float = 0.213;
@export var cloudsFloor : float = 80.0;
@export var cloudsCeiling : float = 2000.0;

@export var globalCloudScale : float = 10000;
@export var baseNoiseScale : float = 1.761;
@export var detailNoiseScale : float = 5.921;
@export var detailNoisePower : float = 1.048;
@export var largeScaleNoiseScale : float = 0.216;
@export var largeScaleNoisePower : float = 3.435;

@export_subgroup("Enviroment and Light Driven Controls")
@export var sunColorDefault : Color = Color(1, 1, 1);
@export var overrideAmbientLight : bool = false;
@export var ambientColorDefault : Color = Color(0, 0, 0);
@export var useFogDefault : bool = true;
@export var fogColorDefault : Color = Color(1, 1, 1);

func _ready():
	if (!Engine.is_editor_hint()):
		AddShaderVariables();
		UpdateGlobalVariableTextures();
		UpdateGlobalVariables();

func AddShaderVariables():
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

func _process(delta):
	if (Engine.is_editor_hint() || updateConstantly):
		UpdateGlobalVariableTextures();
		UpdateGlobalVariables();

func UpdateGlobalVariableTextures():
	if (gradientControlTexture == null):
		gradientControlTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/HeightWeightGradient.tres");
	
	if (baseNoiseTexture == null):
		baseNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseTexture.tres");
	
	if (detailNoiseTexture == null):
		detailNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseDetailTexture.tres");
	
	if (largeScaleNoiseTexture == null):
		largeScaleNoiseTexture = ResourceLoader.load("res://addons/SunshineVolumetricClouds/BaseNoiseLargeScaleTexture.tres");
	

func UpdateGlobalVariables():
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsCutoff", cloudsCutoff);
	
	RenderingServer.global_shader_parameter_set("SunshineClouds_WindDirection", windDirection);
	RenderingServer.global_shader_parameter_set("SunshineClouds_WindSpeed", windSpeed);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsFloor", cloudsFloor);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsCeiling", cloudsCeiling);
	
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsGlobalScale", globalCloudScale);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsBaseNoiseScale", baseNoiseScale);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsDetailNoiseScale", detailNoiseScale);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsDetailNoisePower", detailNoisePower);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsLargeScaleNoiseScale", largeScaleNoiseScale);
	RenderingServer.global_shader_parameter_set("SunshineClouds_CloudsLargeScaleNoisePower", largeScaleNoisePower);
	
	if (sunLight != null):
		RenderingServer.global_shader_parameter_set("SunshineClouds_SunDirection", sunLight.global_transform.basis.z);
		sunColorDefault = sunLight.light_color * sunLight.light_energy;
	
	if (worldEnvironment != null && worldEnvironment.environment != null):
		useFogDefault = worldEnvironment.environment.fog_enabled;
		fogColorDefault = worldEnvironment.environment.fog_light_color * worldEnvironment.environment.fog_light_energy;
		
		if (!overrideAmbientLight && worldEnvironment.environment.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR):
			ambientColorDefault = worldEnvironment.environment.ambient_light_color * worldEnvironment.environment.ambient_light_energy;
	
	RenderingServer.global_shader_parameter_set("SunshineClouds_SunColor", sunColorDefault);
	RenderingServer.global_shader_parameter_set("SunshineClouds_UseFog", useFogDefault);
	RenderingServer.global_shader_parameter_set("SunshineClouds_FogColor", fogColorDefault);
	RenderingServer.global_shader_parameter_set("SunshineClouds_AmbientColor", ambientColorDefault);
