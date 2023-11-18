shader_type spatial;
render_mode skip_vertex_transform, cull_disabled;
render_mode unshaded;

group_uniforms WorldControls;
// Needs to be pushed to global shader variables to handle weather and time of day.
uniform vec3 SunDirection;
uniform vec2 WindDirection = vec2(1,0);
uniform float WindSpeed = 0.003;

group_uniforms SmoothingControls;
// Offsets the origin depth by a dither matrix multiplied by this and the step distance, prevents banding.
uniform float StartingPointNoisePower: hint_range(0,40) = 25.0;
uniform float ditherspeed: hint_range(0,1000) = 1000.0;
uniform float StepDepthBlendRange = 60.0;

group_uniforms NoiseControls;
// Also needs to be pushed to global shader variables, when paired with noise texture will allow fake shadows on terrain.
uniform float cloudsGlobalScale =  10000.0;
uniform float noise_scale: hint_range(0,5) = 1.761;
uniform float large_scale_noise_scale: hint_range(0,1) = 0.216;
uniform float large_scale_noise_power: hint_range(0,5) = 2.32;
uniform float detail_noise_scale: hint_range(0,10) = 5.921;
uniform float detail_noise_power: hint_range(-1,1) = 0.788;

group_uniforms DensityControls;
uniform float cloudCutoff: hint_range(0,1) = 0.788;
uniform float cloudSoftness: hint_range(0,1) = 0.215;

// Used to create the clouds deck, with all clouds occuring between these parameters in world space.
uniform float CloudFloor = 80.0;
uniform float CloudCeiling = 2000.0;

// basic controls for density and cutoff, cloud density may impact fake shadows later on.
uniform float CloudDensity = 1.0;
uniform float DensityCutoff = 1.3;
uniform float CloudMaxDistance = 15000;
uniform float CloudMaxDistanceFalloff = 5000;


group_uniforms FogControls;
// Driven mostly by clouds controller script, but can be left on manual for specific look.
uniform bool UseFog = true;
uniform float CloudFogMaxDistance = 14000;
group_uniforms ColorControls;
uniform vec3 CloudFogColor: source_color = vec3(0.494, 0.573, 0.655);
uniform vec3 CloudBaseColor: source_color = vec3(1.0,1.0,1.0);
uniform vec3 CloudShadowColor: source_color = vec3(0.173, 0.2, 0.255);


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
// used to create a ramp than controls the vertical axis on the clouds, lets you author clouds a little more detailed, to blend between different types lerp this using c# or gdscript to another gradient.
uniform sampler2D HeightWeightGradient;

uniform sampler3D NoiseTexture;
uniform sampler3D LargeShapeNoiseTexture;
// a note with detail, I recommend using a texture that is twice 
// as tall as it is wide, to make the details vertically squashed
uniform sampler3D DetailNoiseTexture;

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
	float heightScale = (pos.y - CloudFloor) / (CloudCeiling - CloudFloor);
	float posCutoff = smoothstep(0.0, 0.001, heightScale) - smoothstep(1.0, 1.001, heightScale);
	posCutoff = smoothstep(0.0, 0.001, posCutoff);
	//float posCutoff = abs(clamp(distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y), 0.0, 1.0) - 1.0);
	//if (distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y) > 0.0){posCutoff = 1.0;}
	pos /= cloudsGlobalScale;
	
	float largeScaleNoise = textureLod(LargeShapeNoiseTexture, pos * (large_scale_noise_scale) + (vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 4.0), 0.0).r * large_scale_noise_power;
	//largeScaleNoise += 1.0 - posCutoff;
	if (posCutoff <= 0.0){return 0.0;}
	//float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;
	
	//if (largeScaleNoise > 1.0){return 0.0;}
	
	heightScale = texture(HeightWeightGradient, vec2(heightScale, 0.0)).r;
	
	float noise = textureLod(NoiseTexture, pos * (noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed, 0.0).r 
	+ textureLod(DetailNoiseTexture, pos * (detail_noise_scale) - (vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0), 0.0).r * detail_noise_power;
	
	
	noise *= heightScale;
	noise -= largeScaleNoise;
	//noise = posCutoff;
	noise = smoothstep(cloudCutoff, cloudCutoff + cloudSoftness, noise);
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
	return  1.0 - max(clamp(max(position.y - CloudFloor, vector.y), 0.0, 1.0), 1.0 - clamp(min(position.y - CloudCeiling,vector.y), 0.0, 1.0));
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
	dither -= (StepDistanceClose * StartingPointNoisePower) / 2.0;
	origin += view_dir * dither;
	
	vec3 cur_pos = origin;
	float cur_distance = 0.0;
	float currentDensity = 0.0;
	float thisDensity = 0.0;
	vec3 currentColor = vec3(0.5);
	float cutoffvalue = 0.0;
	
	if (cur_pos.y < CloudFloor && view_dir.y < 0.0 || cur_pos.y > CloudCeiling && view_dir.y > 0.0){discard;}
	
	for (int i = 0; i < StepCount; i++) {
		cur_distance += mix(StepDistanceClose, StepDistanceFar, ease_out_quad(0.0,1.0,float(i) / float(StepCount)));
		cur_pos = origin + view_dir * cur_distance;
		
		thisDensity = samplecloudmap(cur_pos, time)  * CloudDensity;
		currentColor = mix(currentColor, CloudBaseColor, thisDensity);
		currentDensity += thisDensity * smoothstep(linear_depth, linear_depth - StepDepthBlendRange, cur_distance);
		//cutoffvalue = CheckOutOfBounds(cur_pos, view_dir);
		cutoffvalue = max(max(cur_distance - linear_depth, currentDensity - DensityCutoff), CheckOutOfBounds(cur_pos, view_dir));
		if (cutoffvalue > 0.1){break;}
	}
	float shadow = 0.0;
	for (int j = 0; j < LightingStepCount; j++) {
		shadow += (samplecloudmap(cur_pos, time) * CloudDensity);
		
		cur_pos += SunDirection * LightingStepDistance;
	}
	shadow /= float(LightingStepCount);
	
	currentDensity = mix(clamp(currentDensity, 0.0, 1.0), 0.0, clamp(((cur_distance - CloudMaxDistance) / CloudMaxDistanceFalloff) + 1.0, 0.0, 1.0));
	
	//if (currentDensity < 0.001){
		//discard;
	//} 
	vec3 color = mix(CloudShadowColor, CloudBaseColor, clamp(1.0 - shadow, 0.0, 1.0));
	//float fogStrength = mix(0.0, 1.0, clamp(cur_distance / CloudFogMaxDistance, 0.0, 1.0));
	//color = mix(color, CloudFogColor, fogStrength);
	if (UseFog){
		float fogStrength = mix(0.0, 1.0, clamp(cur_distance / CloudFogMaxDistance, 0.0, 1.0));
		color = mix(color, CloudFogColor, fogStrength);
	}
	

	vec4 newColor = vec4(color, currentDensity);
	
	
	ALBEDO = newColor.xyz;
	ALPHA = newColor.a;
}
