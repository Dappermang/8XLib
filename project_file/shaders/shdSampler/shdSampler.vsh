attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec3 v_Normal;
varying vec2 v_TextureCoord;

uniform mat4 MVP;
uniform mat4 Model;

void main()
{
    gl_Position = MVP * vec4(in_Position, 1.0);
    v_Normal = mat3(Model) * in_Normal;
    v_TextureCoord = in_TextureCoord;
}