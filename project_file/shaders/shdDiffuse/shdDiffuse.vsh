// attribute vec3 in_Position;
// attribute vec3 in_Normal;
// attribute vec2 in_TextureCoord;
// attribute vec4 in_Colour;

// varying vec2 v_uv;
// varying vec3 v_normal;

// void main() {
//     gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
//     // v_normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0)).xyz);
//     v_normal = normalize((gm_Matrices[MATRIX_PROJECTION] * vec4(in_Normal, 0)).xyz);
//     v_uv = in_TextureCoord;
// }


attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_frag_to_cam; // Added varying variable to store fragment-to-camera direction

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    // Compute the direction from the fragment to the camera
    v_frag_to_cam = normalize(-vec3(gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0)));
    v_normal = normalize((gm_Matrices[MATRIX_PROJECTION] * vec4(in_Normal, 0)).xyz);
    v_uv = in_TextureCoord;
}