attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(in_Position, 1.0);
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 sample = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = v_vColour*vec4(sample.rgb, 1.0);
    gl_FragColor.rgb *= gl_FragColor.a;
}

