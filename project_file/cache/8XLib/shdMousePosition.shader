attribute vec2 in_Position;
attribute vec2 in_TextureCoord;
varying vec2 v_TextureCoord;

void main() {
    gl_Position = vec4( in_Position, 0.0, 1.0 );
    v_TextureCoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
precision mediump float;
varying vec2 v_TextureCoord;
uniform vec2 u_MousePosition;
uniform mat3 u_TextureTransform;

void main() {
    // Convert mouse position to texture space
    vec3 mousePos = vec3( 
    	u_MousePosition, 1.0 
    );
    
    mousePos = u_TextureTransform * mousePos;
    vec2 mouseTexCoord = mousePos.xy / mousePos.z;
    
    // UV Coordinates
    gl_FragColor = vec4( 
    	mouseTexCoord, 
    	0.0, 
    	1.0 
    );
}

