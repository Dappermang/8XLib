varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseTexture;
uniform sampler2D overlayTexture;

void main() {
	// Getting the base texture samples.
    vec4 baseColor = texture2D( baseTexture, v_vTexcoord );
    vec4 overlayColor = texture2D( overlayTexture, v_vTexcoord );
    
    // Mixing the two samples using the overlay Alpha.
    vec4 finalColor = mix( baseColor, overlayColor, overlayColor.a );
    
    // Final color multiplied by the input RGBA
    finalColor *= v_vColour;
    
    // Fragment color set to final
    gl_FragColor = finalColor;
}