#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D noisetex;
uniform float frameTimeCounter;

varying float isWater;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 Normal;
varying vec4 wPos;

const int noiseTextureResolution = 128; // Default value is 64

void main() {
	vec4 color = vec4(0.0);
	vec4 color3 = vec4(0.0);
	float opac = 0.0;

	if(isWater > 0.5) {
		vec2 inBlockOffset = mod(texcoord, vec2(1.0/64.0));
		vec2 inMapOffset = texcoord - inBlockOffset;
		//inBlockOffset += texture2D(noisetex, wPos.xz/16.0).rg / 1600;
		
		

		inBlockOffset += vec2(cos(2*frameTimeCounter + wPos.x*18)/2 + sin(3*frameTimeCounter + wPos.z*17)/4, cos(2.35*frameTimeCounter + wPos.x*13)/2 + sin(4.2*frameTimeCounter + wPos.x*27)/4) / 1600;
		inBlockOffset  = mod(inBlockOffset, vec2(1.0/64.0));
		
		color = texture2D(texture, inMapOffset + inBlockOffset);
		color3 = color;
		opac = color.a / 2;
		vec3 specular = pow(color.xyz*1.1, vec3(4.0));//min(pow(color.xyz, 4.0), 1.0);
		color3 = vec4(glcolor.xyz * specular, 1.0);
		color = vec4(1.0, 1.0, 1.0, 0.1);
	} else {
		color = texture2D(texture, texcoord);
		color *= glcolor;
		color3 = color;
		opac = color.a;
	}

/* DRAWBUFFERS:01234 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[3] = color3;
	gl_FragData[4] = vec4(isWater, opac, isWater, 1.0);
}
