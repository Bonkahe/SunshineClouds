shader_type spatial;
render_mode skip_vertex_transform, cull_disabled;
render_mode unshaded;

global uniform vec3 SunshineClouds_SunDirection;
global uniform vec2 SunshineClouds_WindDirection;
global uniform float SunshineClouds_WindSpeed;

global uniform float SunshineClouds_CloudsGlobalScale;
global uniform float SunshineClouds_CloudsBaseNoiseScale;
global uniform float SunshineClouds_CloudsDetailNoiseScale;
global uniform float SunshineClouds_CloudsDetailNoisePower;
global uniform float SunshineClouds_CloudsLargeScaleNoiseScale;
global uniform float SunshineClouds_CloudsLargeScaleNoisePower;

global uniform float SunshineClouds_CloudsFloor;
global uniform float SunshineClouds_CloudsCeiling;

global uniform float SunshineClouds_CloudsCutoff;

global uniform bool SunshineClouds_UseFog;
global uniform vec4 SunshineClouds_FogColor;
global uniform vec4 SunshineClouds_SunColor;
global uniform vec4 SunshineClouds_AmbientColor;

global uniform sampler3D SunshineClouds_BaseNoiseTexture;
global uniform sampler3D SunshineClouds_DetailNoiseTexture;
global uniform sampler3D SunshineClouds_LargeScaleNoiseTexture;

global uniform sampler2D SunshineClouds_HeightWeightGradient;

group_uniforms SmoothingControls;
// Offsets the origin depth by a dither matrix multiplied by this and the step distance, prevents banding.
uniform float StartingPointNoisePower: hint_range(0,40) = 15;
uniform float ditherspeed: hint_range(0,1000) = 100.0;
uniform float StepDepthBlendRange = 50.0;

group_uniforms DensityControls;
uniform float cloudSoftness: hint_range(0,1) = 0.215;

// basic controls for density and cutoff, cloud density may impact fake shadows later on.
uniform float CloudDensity = 1.0;
uniform float DensityCutoff = 1.3;
uniform float CloudMaxDistance = 12000;
uniform float CloudMaxDistanceFalloff = 5000;


group_uniforms FogControls;
// Driven mostly by clouds controller script, but can be left on manual for specific look.
uniform float CloudFogMaxDistance = 14000;



group_uniforms QualityControls;
//Blends between step distance close and step distance far to create higher detail closer and longer range clouds functionality.
uniform float StepDistanceClose = 20.0;
uniform float StepDistanceFar = 150.0;
uniform int StepCount = 100;
// be aware as you step up the lighting cloud count, you will need to step down the distance, as the total shadows and divided by the step count.
uniform float LightingStepDistance = 20.0;
uniform int LightingStepCount = 25;


group_uniforms Textures;
uniform sampler2D depth_texture : source_color, hint_depth_texture;

const mat4 dither_matrix = mat4(
  vec4(0.0625, 0.5625, 0.1875,  0.6875),
  vec4(0.8125, 0.3125, 0.9375,  0.4375),
  vec4(0.25, 0.75, 0.125, 0.625),
  vec4(1.0, 0.5, 0.875,  0.375)
);

void vertex() {
	//time = TIME;
	//POSITION = vec4(VERTEX + vec3(0,0,-10), 1.0);
	VERTEX = (PROJECTION_MATRIX * vec4(VERTEX , 1.0)).xyz;
}

float samplecloudmap(vec3 pos, float time) {
	//if (abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y) > 0.0){return 0.0;}
	float heightScale = (pos.y - SunshineClouds_CloudsFloor) / (SunshineClouds_CloudsCeiling - SunshineClouds_CloudsFloor);
	float posCutoff = smoothstep(0.0, 0.001, heightScale) - smoothstep(1.0, 1.001, heightScale);
	posCutoff = smoothstep(0.0, 0.001, posCutoff);
	//float posCutoff = abs(clamp(distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y), 0.0, 1.0) - 1.0);
	//if (distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y) > 0.0){posCutoff = 1.0;}
	pos /= SunshineClouds_CloudsGlobalScale;
	
	float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 4.0), 0.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	//largeScaleNoise += 1.0 - posCutoff;
	if (posCutoff <= 0.0){return 0.0;}
	//float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;
	
	//if (largeScaleNoise > 1.0){return 0.0;}
	
	heightScale = texture(SunshineClouds_HeightWeightGradient, vec2(heightScale, 0.0)).r;
	
	float noise = textureLod(SunshineClouds_BaseNoiseTexture, pos * (SunshineClouds_CloudsBaseNoiseScale) + vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed, 0.0).r 
	+ textureLod(SunshineClouds_DetailNoiseTexture, pos * (SunshineClouds_CloudsDetailNoiseScale) - (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 3.0), 0.0).r * SunshineClouds_CloudsDetailNoisePower;
	
	
	noise *= heightScale;
	noise -= largeScaleNoise;
	//noise = posCutoff;
	noise = smoothstep(SunshineClouds_CloudsCutoff, SunshineClouds_CloudsCutoff + cloudSoftness, noise);
	//noise = clamp(noise, 0.0, posCutoff);
	//noise -= posCutoff;f
	//noise = clamp(noise, 0.0, abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y));
	//noise -= distance(pos.y, clamp(pos.y, CloudFloor, CloudCeiling));
	//noise *= posCutoff;
	return noise;
}


float ease_out_quad(float start, float end, float value){
	end -= start;
	return -end * value * (value - 2.0) + start;
}

float CheckOutOfBounds(vec3 position, vec3 vector){
	return  1.0 - max(clamp(max(position.y - SunshineClouds_CloudsFloor, vector.y), 0.0, 1.0), 1.0 - clamp(min(position.y - SunshineClouds_CloudsCeiling,vector.y), 0.0, 1.0));
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//// Get the camera position
	vec3 camera = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	//
	//// Raymarching direction
	vec3 dir = normalize(world - camera);
	
	vec3 view_dir = normalize(dir);
	
	vec3 origin = world.xyz;
	float time = TIME;
	
	float dither = dither_matrix[int(FRAGCOORD.x + time * ditherspeed) % 4][int(FRAGCOORD.y + time  * ditherspeed) % 4];
	
	dither = (dither * StepDistanceClose * StartingPointNoisePower);
	//dither -= (StepDistanceClose * StartingPointNoisePower) / 2.0;
	origin += view_dir * dither;
	
	vec3 cur_pos = origin;
	vec3 lighting_pos = cur_pos;
	float cur_distance = 0.0;
	float currentDensity = 0.0;
	float thisDensity = 0.0;
	vec3 currentColor = vec3(0.5);
	float cutoffvalue = 0.0;
	float shadow = 0.0;
	
	if (cur_pos.y < SunshineClouds_CloudsFloor && view_dir.y < 0.0 || cur_pos.y > SunshineClouds_CloudsCeiling && view_dir.y > 0.0){discard;}
	
	for (int i = 0; i < StepCount; i++) {
		cur_distance += mix(StepDistanceClose, StepDistanceFar, ease_out_quad(0.0,1.0,float(i) / float(StepCount)));
		cur_pos = origin + view_dir * cur_distance;
		
		thisDensity = samplecloudmap(cur_pos, time) * CloudDensity;
		currentColor = mix(currentColor, SunshineClouds_SunColor.rgb, thisDensity);
		currentDensity += thisDensity * smoothstep(linear_depth, linear_depth - StepDepthBlendRange, cur_distance);
		//cutoffvalue = CheckOutOfBounds(cur_pos, view_dir);
		cutoffvalue = max(max(cur_distance - linear_depth, currentDensity - DensityCutoff), CheckOutOfBounds(cur_pos, view_dir));
		if (cutoffvalue > 0.0){break;}
		lighting_pos = cur_pos + SunshineClouds_SunDirection * dither;
		for (int j = 0; j < LightingStepCount; j++) {
			shadow += (samplecloudmap(lighting_pos, time) * CloudDensity);
			
			lighting_pos += SunshineClouds_SunDirection * LightingStepDistance;
		}
		shadow /= float(LightingStepCount);
	}
	

	
	//currentDensity = mix(clamp(currentDensity, 0.0, 1.0), 0.0, clamp(((cur_distance - CloudMaxDistance) / CloudMaxDistanceFalloff) + 1.0, 0.0, 1.0));
	currentDensity = clamp(currentDensity, 0.0, 1.0);
	//if (currentDensity < 0.001){
		//discard;
	//} 
	vec3 color = mix(SunshineClouds_AmbientColor.rgb, SunshineClouds_SunColor.rgb, clamp(1.0 - shadow, 0.0, 1.0));
	//float fogStrength = mix(0.0, 1.0, clamp(cur_distance / CloudFogMaxDistance, 0.0, 1.0));
	//color = mix(color, CloudFogColor, fogStrength);
	if (SunshineClouds_UseFog){
		float fogStrength = mix(0.0, 1.0, clamp(cur_distance / CloudFogMaxDistance, 0.0, 1.0));
		color = mix(color, SunshineClouds_FogColor.rgb, fogStrength);
	}
	

	vec4 newColor = vec4(color, currentDensity);
	
	
	ALBEDO = newColor.xyz;
	ALPHA = newColor.a;
}
