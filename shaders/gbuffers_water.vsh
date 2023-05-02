#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;
varying float isWater;
varying vec4 wPos;

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;

void main() {
	vec4 pos = gl_Vertex;//ftransform();
	wPos = pos + vec4(cameraPosition.xyz, 0.0);

	if(mc_Entity.x != 102.0 && mc_Entity.x != 95.0 && mc_Entity.x != 160) {
		pos.y += sin(4.5*frameTimeCounter + 10*wPos.x)/30 + cos(5*frameTimeCounter + 10*wPos.z)/30;
		
		wPos.x += cos(0.6 * frameTimeCounter + wPos.x) / 16 + sin(frameTimeCounter + wPos.z) / 16;
		
		isWater = 1.0f;
	} else {
		isWater = 0.0f;
	}

	gl_Position = gl_ModelViewProjectionMatrix * pos;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	Normal = gl_NormalMatrix * gl_Normal;
}
