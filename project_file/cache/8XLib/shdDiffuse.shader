attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    v_normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0)).xyz);
    v_uv = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_uv;
varying vec3 v_normal;

void main() {
    vec4 starting_color = texture2D(gm_BaseTexture, v_uv);
    vec3 ambient_color = vec3(0.1, 0.1, 0.1);
    vec3 light_color = vec3(1);
    
    vec3 L = normalize(vec3(-0.5));
    float NdotL = max(0.0, -dot(v_normal, L));
    vec3 diffuse_color = NdotL * light_color;
    
    vec3 final_color = starting_color.rgb * (ambient_color + diffuse_color);
    gl_FragColor = vec4(final_color, starting_color.a);
}

