#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

uniform float frameTimeCounter;

void main() {
	vec4 pos = gl_Vertex;//ftransform();

	vec4 newpos = pos;

	newpos.x += sin(1.5*frameTimeCounter +   pos.y)/100 + cos(6*frameTimeCounter + pos.z)/300;
	newpos.y += sin(   2*frameTimeCounter + 7*pos.x)/30 + cos(5*frameTimeCounter + 9*pos.z)/30;
	newpos.z += sin(0.5*frameTimeCounter +   pos.x)/100 + cos(4*frameTimeCounter  + pos.y)/300;

	pos = newpos;

	gl_Position = gl_ModelViewProjectionMatrix * pos;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	Normal = gl_NormalMatrix * gl_Normal;
}