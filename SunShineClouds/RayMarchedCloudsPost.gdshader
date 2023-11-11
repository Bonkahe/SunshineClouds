shader_type spatial;
render_mode skip_vertex_transform, cull_disabled;
render_mode unshaded;

// Offsets the origin depth by a dither matrix multiplied by this and the step distance, prevents banding.
uniform float StartingPointNoisePower = 5.0;

// Needs to be pushed to global shader variables to handle weather and time of day.
uniform vec3 SunDirection;
uniform vec2 WindDirection = vec2(1,0);
uniform float WindSpeed = 0.003;

// Also needs to be pushed to global shader variables, when paired with noise texture will allow fake shadows on terrain.
uniform float noise_scale = 0.27;
uniform float large_scale_noise_scale = 0.115;
uniform float large_scale_noise_power: hint_range(0,5) = 1.199;
uniform float detail_noise_scale = 1.025;
uniform float detail_noise_power: hint_range(0,1) = 0.209;

uniform float cloudCutoff = 0.256;
uniform float cloudSoftness = 0.036;

// Driven mostly by clouds controller script, but can be left on manual for specific look.
uniform bool UseFog = true;
uniform float CloudFogMaxDistance = 10000;
uniform vec3 CloudFogColor: source_color = vec3(0.494, 0.573, 0.655);
uniform vec3 CloudBaseColor: source_color = vec3(1.0,1.0,1.0);
uniform vec3 CloudShadowColor: source_color = vec3(0.173, 0.2, 0.255);

// Used to create the clouds deck, with all clouds occuring between these parameters in world space.
uniform float CloudFloor = 80.0;
uniform float CloudCeiling = 2000.0;

//Blends between step distance close and step distance far to create higher detail closer and longer range clouds functionality.
uniform float StepDistanceClose = 20.0;
uniform float StepDistanceFar = 200.0;
uniform int StepCount = 400;

// be aware as you step up the lighting cloud count, you will need to step down the distance, as the total shadows and divided by the step count.
uniform float LightingStepDistance = 10.0;
uniform int LightingStepCount = 40;

// basic controls for density and cutoff, cloud density may impact fake shadows later on.
uniform float CloudDensity = 0.95;
uniform float DensityCutoff = 1.0;
uniform float CloudMaxDistance = 10000;
uniform float CloudMaxDistanceFalloff = 3000;

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
	VERTEX = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float samplecloudmap(vec3 pos, float time) {
	if (clamp(pos.y, CloudFloor, CloudCeiling) != pos.y){return 0.0;}
	
	float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale / 10000.0) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;
	
	if (largeScaleNoise > 1.0){return 0.0;}

	float heightScale = (pos.y - CloudFloor) / (CloudCeiling - CloudFloor);
	heightScale = texture(HeightWeightGradient, vec2(heightScale, 0.0)).r;
	
	float noise = texture(NoiseTexture, pos * (noise_scale / 10000.0) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed).r 
	- largeScaleNoise 
	- texture(DetailNoiseTexture, pos * (detail_noise_scale / 10000.0) - (vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0)).r * detail_noise_power;
	noise *= heightScale;
	return smoothstep(cloudCutoff, cloudCutoff + cloudSoftness, noise);
}


float ease_out_quad(float start, float end, float value){
	end -= start;
	return -end * value * (value - 2.0) + start;
}

vec4 iterateClouds(vec3 origin, vec3 direction, float currentDepth, float time){
	vec3 cur_pos = origin;
	float cur_distance;
	float currentDensity;
	float thisDensity;
	vec3 currentColor = vec3(0.5);
	float fogStrength;
	for (int i = 0; i < StepCount; i++) {
		cur_distance += mix(StepDistanceClose, StepDistanceFar, ease_out_quad(0.0,1.0,float(i) / float(StepCount)));
		cur_pos = origin + direction * cur_distance;
		
		if (cur_pos.y > CloudFloor && cur_pos.y < CloudCeiling){
			thisDensity = samplecloudmap(cur_pos, time);
			currentColor = mix(currentColor, CloudBaseColor, thisDensity);
			currentDensity += thisDensity;
		}

		if ((cur_pos.y < CloudFloor && direction.y < 0.0) || (cur_pos.y > CloudCeiling && direction.y > 0.0) || (cur_distance > CloudMaxDistance || cur_distance > currentDepth || currentDensity > DensityCutoff)){break;}
	}
	vec3 lighting_pos = cur_pos;
	float shadow;
	for (int j = 0; j < LightingStepCount; j++) {
		shadow += (samplecloudmap(lighting_pos, time) * CloudDensity);
		
		lighting_pos += SunDirection * LightingStepDistance;
	}
	shadow /= float(LightingStepCount);
	
	currentDensity = mix(clamp(currentDensity, 0.0, 1.0), 0.0, clamp(((cur_distance - CloudMaxDistance) / CloudMaxDistanceFalloff) + 1.0, 0.0, 1.0));

	vec3 color = mix(CloudShadowColor, CloudBaseColor, clamp(1.0 - shadow, 0.0, 1.0));
	if (UseFog){
		float fogStrength = mix(0.0, 1.0, clamp(cur_distance / CloudFogMaxDistance, 0.0, 1.0));
		color = mix(color, CloudFogColor, fogStrength);
	}
	
	return vec4(color, currentDensity);
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
	
	vec3 cur_pos = world.xyz;
	float time = TIME;
	vec2 fragCoord = vec2(FRAGCOORD.x + sin(time * 5.0) * 1000.0, FRAGCOORD.y + (sin(time * 5.0) * 1000.0));
	float dither_strength = mix(0.0, 1.0,depth);
	float dither = dither_matrix[int(fragCoord.x) % 4][int(fragCoord.y) % 4];
	
	
	cur_pos += view_dir * (dither * StepDistanceClose * StartingPointNoisePower);
	
	vec4 newColor = iterateClouds(cur_pos, view_dir, linear_depth, time);
	
	
	ALBEDO = newColor.xyz;
	ALPHA = newColor.a;
}
