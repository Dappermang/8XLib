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