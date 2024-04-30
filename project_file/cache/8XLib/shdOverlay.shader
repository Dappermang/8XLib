attribute vec3 in_Position; // (x, y, z)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec2 in_TextureCoord; // (u, v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat4 v_vMatrix;

void main() {
	vec4 objectWorldPosition = vec4( in_Position, 1.0 );
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * objectWorldPosition;

	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
	// This Matrix is set to the models current Transform Matrix.
	v_vMatrix = gm_Matrices[MATRIX_WORLD];
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat4 v_vMatrix;

uniform sampler2D u_vBaseTexture;
uniform sampler2D u_vOverlayTexture;
// uniform float mouseCoordinatesX;
// uniform float mouseCoordinatesY;


void main() {
    // Convert mouse coordinates to view space
    // vec2 mousePixelPosition = vec2( mouseCoordinatesX, mouseCoordinatesY ) / v_vTexcoord;
    // vec4 mouseCoordinatesMatrix = v_vMatrix * vec4( mousePixelPosition, 0.0, 1.0 );
    
    vec4 surfaceTextureSample = texture2D( u_vOverlayTexture, v_vTexcoord );
    vec4 modelTextureSample = texture2D( u_vBaseTexture, v_vTexcoord );
    
    // // The final fragment color. Model and Surface samples are mixed by the surface samples alpha.
    vec4 finalColor = mix( modelTextureSample, surfaceTextureSample, surfaceTextureSample.a );
  
    finalColor *= v_vColour;
    gl_FragColor = finalColor;
    // gl_FragColor = vec4( mouseCoordinatesMatrix.xy, 0.0, 1.0 );
}

