varying vec3 v_Normal;
varying vec2 v_TextureCoord;

uniform sampler2D surfaceTexture; // Texture obtained from the painted draw surface

void main()
{
    vec3 normal = normalize(v_Normal);
    vec4 textureColor = texture2D(surfaceTexture, v_TextureCoord); // Sample from the painted draw surface texture
    
    gl_FragColor = textureColor;
}