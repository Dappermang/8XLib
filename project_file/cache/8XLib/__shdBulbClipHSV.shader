attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec3 sample = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
    gl_FragColor = vec4(v_vColour.rgb, v_vColour.a*(1.0 - max(sample.r, max(sample.g, sample.b))));
}

