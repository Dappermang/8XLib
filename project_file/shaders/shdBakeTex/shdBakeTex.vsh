attribute vec3 in_Position; // (x, y, z)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec2 in_TextureCoord; // (u, v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vCameraPosition;

uniform mat4 u_vMatrix;

void main() {
	vec4 objectWorldPosition = vec4( in_Position, 1.0 );
	
	/* 
		v_vCameraPosition <- Camera Position
		v_vColour <- Vertex Colour
		v_vTexcoord <- UV Coordinate
	*/
	v_vCameraPosition = u_vMatrix * objectWorldPosition;
	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
	
	// Vertex Position based on the current ( orthographic ) projection.
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4( in_Position, 1.0 );
}