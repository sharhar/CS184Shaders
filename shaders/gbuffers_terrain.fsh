#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

varying vec2 lightmapCoords;

uniform vec3 sunPosition;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	/* DRAWBUFFERS:012 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(lightmapCoords, 0.0f, 1.0f);
}
