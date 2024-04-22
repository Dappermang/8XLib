attribute vec3 in_Position; // (x, y, z)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec2 in_TextureCoord; // (u, v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
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
