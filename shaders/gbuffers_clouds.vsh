#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	Normal = gl_NormalMatrix * gl_Normal;
}