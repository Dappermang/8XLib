attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    v_normal = normalize((gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Normal, 0)).xyz);
    v_uv = in_TextureCoord;
}