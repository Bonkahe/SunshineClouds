@tool
extends Node
class_name CloudsController;

@export var SunLight : DirectionalLight3D;
@export var SkyMaterial : ShaderMaterial;
@export var OptionalWorldEnvironment : Environment;
@export var DefaultAmbientLightColor : Color;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if (SunLight == null || SkyMaterial == null):
		return;
	SkyMaterial.set_shader_parameter("SunDirection", SunLight.global_transform.basis.z);
	SkyMaterial.set_shader_parameter("CloudBaseColor", SunLight.light_color * SunLight.light_energy);
	
	if (OptionalWorldEnvironment != null):
		SkyMaterial.set_shader_parameter("UseFog", OptionalWorldEnvironment.fog_enabled);
		SkyMaterial.set_shader_parameter("CloudFogColor", OptionalWorldEnvironment.fog_light_color * OptionalWorldEnvironment.fog_light_energy);
		
		match OptionalWorldEnvironment.ambient_light_source:
			Environment.AMBIENT_SOURCE_COLOR:
				SkyMaterial.set_shader_parameter("CloudShadowColor", OptionalWorldEnvironment.ambient_light_color * OptionalWorldEnvironment.ambient_light_energy);
			#Environment.AMBIENT_SOURCE_SKY:
				#SkyMaterial.set_shader_parameter("CloudShadowColor", OptionalWorldEnvironment. * OptionalWorldEnvironment.ambient_light_energy);
			#Environment.AMBIENT_SOURCE_BG:
				#
	else:
		SkyMaterial.set_shader_parameter("CloudShadowColor", DefaultAmbientLightColor);
