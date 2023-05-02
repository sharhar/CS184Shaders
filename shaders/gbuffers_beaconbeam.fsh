#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(0.0); //gcolor
}
