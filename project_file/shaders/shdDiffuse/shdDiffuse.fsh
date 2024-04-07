varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    vec4 texColour = texture2D( gm_BaseTexture, v_uv );
    
    // R, G, B
    vec3 ambientColour = vec3( 0.4, 0.4, 0.4 );
    vec3 lightColour = vec3( 1 );
    
    vec3 L = normalize( vec3( -0.5 ) );
    float NdotL = max( 0.0, -dot( v_normal, L ) );

    vec3 diffuseColour = NdotL * lightColour;
    
    vec3 shadowColour = texColour.rgb * ( ambientColour + diffuseColour );
    gl_FragColor = vec4( shadowColour, texColour.a );
}
