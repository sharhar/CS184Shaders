#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

varying vec2 lightmapCoords;

attribute vec4 mc_Entity;

uniform float frameTimeCounter;

void main() {
	vec4 pos = gl_Vertex;//ftransform();

	if(mc_Entity.x == 18.0) {
		pos.x += sin(4.5*frameTimeCounter + 38 + pos.y)/80 + cos(3.5*frameTimeCounter + 39 + pos.z)/80;
		pos.y += sin(5*frameTimeCounter + 20 + pos.x)/80 + cos(3*frameTimeCounter + 34 + pos.y)/80;
		pos.z += sin(5.5*frameTimeCounter + 29 + pos.x)/80 + cos(2.5*frameTimeCounter + 29 + pos.y)/80;
	}	

	lightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;

	lightmapCoords = lightmapCoords * (33.05f / 32.0f) - (1.05f / 32.0f);

	gl_Position = gl_ModelViewProjectionMatrix * pos;
	texcoord = gl_MultiTexCoord0.st;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	Normal = gl_NormalMatrix * gl_Normal;
}
