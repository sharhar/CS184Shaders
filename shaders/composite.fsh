#version 120

#include "lib/Uniforms.inc"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;

uniform vec3 skyColor;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

/*
const int colortex0Format = RGBA16;
const int colortex1Format = RGBA16;
const int shadowMapResolution = 1024;
*/

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
	//const vec3 skyColor = vec3(0.13f, 0.18f, 0.51f);

	return lightmap.x * torchColor + lightmap.y * (skyColor + vec3(0.0f, 0.0f, 0.0f));
}

float getShadow(in float depth){
	vec3 clipSpace = vec3(texcoord, depth) * 2.0f - 1.0f;
	vec4 viewWorld = gbufferProjectionInverse * vec4(clipSpace, 1.0f);
	vec3 view = viewWorld.xyz/viewWorld.w;
	vec4 world = gbufferModelViewInverse * vec4(view, 1.0f);
	vec4 shadowSpace = shadowProjection * shadowModelView * world;
	vec3 sampleCoords = shadowSpace.xyz * 0.5 + 0.5;
	return step(sampleCoords.z - 0.0001f, texture2D(shadowtex0, sampleCoords.xy).r);
}

void main() {
	
	//Albedo color
	vec3 color = texture2D(colortex0, texcoord).rgb;

	//Lightmap calculation
	vec2 lightmap = texture2D(colortex2, texcoord).rg;

	adjustLightmap(lightmap);

	vec3 lightmapColor = getLightmapColor(lightmap);

	//Handling Sky illumination
	float depth = texture2D(depthtex0, texcoord).r;

	if(depth == 1.0f){
		gl_FragData[0] = vec4(color, 1.0f);
		return;
	}

	//Shadow calculation
	float shadow = getShadow(depth);
	
	//Direct illumination calculation
	vec3 normal = normalize(texture2D(colortex1, texcoord).rgb * 2.0f - 1.0f);

	float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);

	//Final output color
	color *= (lightmapColor + shadow * NdotL + BRIGHTNESS);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0f);
	//gl_FragData[0] = vec4(, 1.0f);
}
