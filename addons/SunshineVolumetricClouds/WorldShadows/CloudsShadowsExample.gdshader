shader_type spatial;

uniform vec3 ObjectColor: source_color = vec3(0.494, 0.573, 0.655);


//global uniform vec3 SunshineClouds_SunDirection;
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

global uniform vec3 SunshineClouds_SunDirection;
global uniform sampler3D SunshineClouds_BaseNoiseTexture;
global uniform sampler3D SunshineClouds_DetailNoiseTexture;
global uniform sampler3D SunshineClouds_LargeScaleNoiseTexture;

global uniform sampler2D SunshineClouds_HeightWeightGradient;

group_uniforms DensityControls;
uniform float CloudDitherPower = 200.0;
uniform float CloudCutoffAdjust = -0.795;
uniform float CloudDensity = 1.49;
uniform float CloudOpacity: hint_range(0,1) = 1.0;
uniform float cloudSoftness = 0.85;

varying vec3 fragment_worldpos;
const mat4 dither_matrix = mat4(
  vec4(0.0625, 0.5625, 0.1875,  0.6875),
  vec4(0.8125, 0.3125, 0.9375,  0.4375),
  vec4(0.25, 0.75, 0.125, 0.625),
  vec4(1.0, 0.5, 0.875,  0.375)
);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ALBEDO = ObjectColor;
}

float samplecloudmap(vec3 pos, float time) {
	float heightSample = smoothstep(SunshineClouds_CloudsCeiling,SunshineClouds_CloudsCeiling - 100.0, pos.y);
	float heightScale = (pos.y - SunshineClouds_CloudsFloor) / (SunshineClouds_CloudsCeiling - SunshineClouds_CloudsFloor);
	//pos.y = clamp(pos.y, SunshineClouds_CloudsFloor, SunshineClouds_CloudsCeiling);
	pos /= SunshineClouds_CloudsGlobalScale;
	
	float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 4.0), 1.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	//float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;
	
	//if (largeScaleNoise > 1.0){return 0.0;}
	heightScale = texture(SunshineClouds_HeightWeightGradient, vec2(heightScale, 0.0)).r;
	
	float noise = textureLod(SunshineClouds_BaseNoiseTexture, pos * (SunshineClouds_CloudsBaseNoiseScale) + vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed, 1.0).r 
	+ textureLod(SunshineClouds_DetailNoiseTexture, pos * (SunshineClouds_CloudsDetailNoiseScale) - (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 3.0), 1.0).r * SunshineClouds_CloudsDetailNoisePower;
	
	noise -= largeScaleNoise;
	//noise = posCutoff;
	noise = smoothstep(SunshineClouds_CloudsCutoff + CloudCutoffAdjust, SunshineClouds_CloudsCutoff + cloudSoftness, noise);
	noise *= heightScale;
	noise *= heightSample;
	
	//noise = clamp(noise, 0.0, posCutoff);
	//noise -= posCutoff;f
	//noise = clamp(noise, 0.0, abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y));
	//noise -= distance(pos.y, clamp(pos.y, CloudFloor, CloudCeiling));
	//noise *= posCutoff;
	return noise;
}

void light()
{
	if (LIGHT_IS_DIRECTIONAL){
		const float CLOUD_SHADOW_STRENGTH = 0.5;
		float cast_shadow = ATTENUATION;//clamp(ATTENUATION * 2.0 - 1.0, 0, 1.5);
		//float upDot = (dot(SunshineClouds_SunDirection, vec3(0.0, 1.0, 0.0)) + 1.0) / 2.0;
		
		float dither = dither_matrix[int(FRAGCOORD.x + TIME * 100.0) % 4][int(FRAGCOORD.y + TIME * 100.0) % 4];
		
		dither = (dither * CloudDitherPower) - CloudDitherPower / 2.0;
		vec3 origin = fragment_worldpos;
		float angleUpward = clamp(2.0 - ((dot(SunshineClouds_SunDirection, vec3(0.0, 1.0, 0.0)) + 1.0)) * 180.0, 0.0, 180.0);
		origin += SunshineClouds_SunDirection * dither;
		
		if (origin.y < SunshineClouds_CloudsFloor){
			float lengthToTravel = (SunshineClouds_CloudsFloor + 200.0) - origin.y / sin(90.0 - angleUpward);
			
			//origin += SunshineClouds_SunDirection * dither;
			origin += SunshineClouds_SunDirection * lengthToTravel;
		}
		else
		{
			origin += SunshineClouds_SunDirection * 200.0;
		}
		//origin.y = max(origin.y, SunshineClouds_CloudsFloor + 200.0);
		float cloud_shadow = (1.0 - clamp(samplecloudmap(origin, TIME) * CloudDensity, 0.0, 1.0));
		float shadow = mix(ATTENUATION, cast_shadow * (clamp(cloud_shadow * 3.0 - 1.0, 0.0, 1.0) * CLOUD_SHADOW_STRENGTH), CloudOpacity);
		DIFFUSE_LIGHT +=  clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * shadow * LIGHT_COLOR;
	}
	else{
		DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
	}
}
