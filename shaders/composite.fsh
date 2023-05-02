#version 120

#include "lib/Uniforms.inc"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform sampler2D noisetex;

uniform vec3 skyColor;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform int worldTime;

#include "distort.glsl"

/*
const int colortex0Format = RGBA16;
const int colortex1Format = RGBA16;
*/

const int shadowMapResolution = 1024;
const int noiseTextureResolution = 128; // Default value is 64

#define SHADOW_SAMPLES 2
const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;

uniform vec3 sunPosition;

varying vec2 texcoord;

float lightmapTorch(in float torch){
	const float K = 2.0f;
	const float P = 5.0f;
	return K * pow(torch, P);
}

float lightmapSky(in float sky){
	return pow(sky, 4.0f);
}

void adjustLightmap(in vec2 lightmap){
	lightmap.x = lightmapTorch(lightmap.x);
	lightmap.y = lightmapSky(lightmap.y);
}

vec3 getLightmapColor(in vec2 lightmap){
	const vec3 torchColor = vec3(TORCH_R, TORCH_G, TORCH_B);

	return lightmap.x * torchColor + lightmap.y * (skyColor + vec3(0.0f, 0.0f, 0.0f));
}

float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
	return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 sampleCoords){
	float shadowVisibility0 = Visibility(shadowtex0, sampleCoords);
	float shadowVisibility1 = Visibility(shadowtex1, sampleCoords);
	vec4 shadowColor0 = texture2D(shadowcolor0, sampleCoords.xy);
	vec3 transmittedColor = shadowColor0.rgb * (1.0f - shadowColor0.a); // Perform a blend operation with the sun color
	return mix(transmittedColor * shadowVisibility1, vec3(1.0f), shadowVisibility0);
}

vec4 depth2WorldPos(float depth) {
	vec3 ClipSpace = vec3(texcoord, depth) * 2.0f - 1.0f;
	vec4 ViewW = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
	vec3 View = ViewW.xyz / ViewW.w;
	return gbufferModelViewInverse * vec4(View, 1.0f);
}

vec4 getWorldPos() {
	float depth = texture2D(depthtex0, texcoord).r;
	
	// handle sky case
	if(depth == 1.0f) {
		return vec4(0.0, 0.0, 0.0, 2.0); 
	}

	return depth2WorldPos(depth);
}

vec4 getOpaqueWorldPos() {
	float depth = texture2D(depthtex1, texcoord).r;
	
	// handle sky case
	if(depth == 1.0f) {
		return vec4(0.0, 0.0, 0.0, 2.0); 
	}

	return depth2WorldPos(depth);
}

vec3 getShadow(vec4 worldPos) {
	vec4 ShadowSpace = shadowProjection * shadowModelView * worldPos;
	ShadowSpace.xy = DistortPosition(ShadowSpace.xy);
	vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;

	vec3 ShadowAccum = vec3(0.0f);
	float RandomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
	float cosTheta = cos(RandomAngle);
	float sinTheta = sin(RandomAngle);
	mat2 Rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
	for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
	for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
	    vec2 Offset = Rotation * vec2(x, y);
	    vec3 CurrentSampleCoordinate = vec3(SampleCoords.xy + Offset, SampleCoords.z);
	    ShadowAccum += TransparentShadow(CurrentSampleCoordinate);
	}
	}
	ShadowAccum /= totalSamples;
	return ShadowAccum;
}

void main() {
	
	//Albedo color
	vec3 color = texture2D(colortex0, texcoord).rgb;

	//Lightmap calculation
	vec2 lightmap = texture2D(colortex2, texcoord).rg;

	adjustLightmap(lightmap);

	vec3 lightmapColor = getLightmapColor(lightmap);

	vec4 worldPos = getWorldPos();
	if(worldPos.w == 2.0f){
		gl_FragData[0] = vec4(color, 1.0f);
		return;
	}

	vec4 colorWater = texture2D(colortex3, texcoord);
	vec4 isWater = texture2D(colortex4, texcoord);

	if(colorWater.a > 0.1 && isWater.r > 0.5) {
		vec4 opaquePos = getOpaqueWorldPos();
		float opaqueDist = distance(worldPos.xyz, opaquePos.xyz);

		float alpha = (1 - isWater.g) * pow(0.95, 2*opaqueDist);
		alpha = 1 - alpha;

		color = (1.0 - alpha) * color + alpha * colorWater.xyz;
	}

	//Shadow calculation
	vec3 shadow = getShadow(worldPos);
	
	//Direct illumination calculation
	vec3 normal = normalize(texture2D(colortex1, texcoord).rgb * 2.0f - 1.0f);

	float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);
	
	if(worldTime >= 13000) {
		NdotL = 0.0f;
	}

	vec3 totalLighting = lightmapColor + shadow * NdotL + BRIGHTNESS;
	float totalLightIntensity = length(totalLighting);
	vec3 totalLightColor = normalize(totalLighting);

	//Final output color
	color *= totalLightColor;
	color *= min(totalLightIntensity, 3.0)*0.75;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0f);
}
