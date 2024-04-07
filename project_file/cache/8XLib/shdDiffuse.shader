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

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    vec4 texColour = texture2D( gm_BaseTexture, v_uv );
    
    // R, G, B
    vec3 ambientColour = vec3( 0.4, 0.4, 0.4 );
    vec3 lightColour = vec3( 1 );
    
    vec3 light = normalize( vec3( -0.5 ) );
    float normalDotLight = max( 0.0, -dot( v_normal, light ) );

    vec3 diffuseColour = normalDotLight * lightColour;
    
    vec3 shadowColour = texColour.rgb * ( ambientColour + diffuseColour );
    gl_FragColor = vec4( shadowColour, texColour.a );
}

