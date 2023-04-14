#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;

uniform vec3 sunPosition;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	float NdotL = max(dot(Normal, normalize(sunPosition)), 0.0f);

	color *= (NdotL + 0.1f);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}
