#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex1;

/*
const int colortex0Format = RGBA16;
const int colortex1Format = RGBA16;
*/

uniform vec3 sunPosition;

varying vec2 texcoord;

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;
	
	vec3 normal = normalize(texture2D(colortex1, texcoord).rgb * 2.0f - 1.0f);

	float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);

	//color *= (NdotL + 0.1f);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
