#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	//color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:0123 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[3] = vec4(0.0); //gcolor
}
