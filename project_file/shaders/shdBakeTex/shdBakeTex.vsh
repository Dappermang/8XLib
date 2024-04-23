attribute vec3 in_Position; // (x, y, z)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec2 in_TextureCoord; // (u, v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec2 v_vUVPosition;
varying vec4 v_vCameraPosition;

void main() {
	vec4 objectWorldPosition = vec4( in_Position, 1.0 );
	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
	
	v_vCameraPosition = gm_Matrices[MATRIX_VIEW] * objectWorldPosition;
	v_vUVPosition = in_TextureCoord.xy;
	
	gl_Position = gm_Matrices[MATRIX_PROJECTION] * v_vCameraPosition;
}