#version 120
#define CEL_SHADING //Enables cell shading.
varying vec2 TexCoords;

uniform sampler2D colortex0;

void main() {
   // Sample the color
   vec3 Color = texture2D(colortex0, TexCoords).rgb;

   vec4 Output = vec4(Color, 1.0f);

   #ifdef CEL_SHADING
		// Convert to grayscale
		//Color = vec3(dot(Color, vec3(0.333f)));
   
		// Calculate brightness of pixel
		float colorBrightness = sqrt(dot(Color, Color));

		int levels = 5; // the number of brightness levels
   
		float newBrightness = max(0.04, floor(colorBrightness * levels) / levels);

		Output = vec4(normalize(Color) * newBrightness, 1.0f);
   #endif

   // Output the color
   gl_FragColor = Output;
}
