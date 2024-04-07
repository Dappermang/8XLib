varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    vec4 starting_color = texture2D(gm_BaseTexture, v_uv);
    // Reduced ambient color intensity
    vec3 ambient_color = vec3(0.2, 0.2, 0.2);
    vec3 light_color = vec3(1);
    
    vec3 L = normalize(vec3(-0.5));
    float NdotL = max(0.0, -dot(v_normal, L));
    // Reduced diffuse lighting intensity
    vec3 diffuse_color = NdotL * light_color * 0.5;
    
    vec3 final_color = starting_color.rgb * (ambient_color + diffuse_color);
    gl_FragColor = vec4(final_color, starting_color.a);
}
