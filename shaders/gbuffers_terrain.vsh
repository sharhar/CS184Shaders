#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

varying vec2 lightmapCoords;

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;

void main() {
	vec4 pos = gl_Vertex;//ftransform();

	vec4 newpos = pos;
	
	pos += vec4(cameraPosition, 0.0);

	if(mc_Entity.x == 18.0) {
		newpos.x += sin(2.5*frameTimeCounter + 38 + pos.y)/120 + cos(1.5*frameTimeCounter + 39 + pos.z)/80;
		newpos.y += sin(3*frameTimeCounter + 20 + pos.z)/120 + cos(1*frameTimeCounter + 34 + pos.x)/80;
		newpos.z += sin(3.5*frameTimeCounter + 29 + pos.x)/120 + cos(0.5*frameTimeCounter + 29 + pos.y)/80;
	}

	pos = newpos;

	lightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;

	lightmapCoords = lightmapCoords * (33.05f / 32.0f) - (1.05f / 32.0f);

	gl_Position = gl_ModelViewProjectionMatrix * pos;
	texcoord = gl_MultiTexCoord0.st;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	Normal = gl_NormalMatrix * gl_Normal;
}
