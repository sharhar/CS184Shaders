#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[3] = vec4(0.0); //gcolor
}
