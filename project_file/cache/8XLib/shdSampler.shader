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

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec3 v_Normal;
varying vec2 v_TextureCoord;

uniform sampler2D surfaceTexture; // Texture obtained from the painted draw surface

void main()
{
    vec3 normal = normalize(v_Normal);
    vec4 textureColor = texture2D(surfaceTexture, v_TextureCoord); // Sample from the painted draw surface texture
    
    gl_FragColor = textureColor;
}

