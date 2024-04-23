varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat4 v_vMatrix;

uniform sampler2D baseTexture;
uniform sampler2D overlayTexture;
uniform float mouseCoordinatesX;
uniform float mouseCoordinatesY;


void main() {
    // Convert mouse coordinates to view space
    vec2 mouseCoordinates = vec2( mouseCoordinatesX, mouseCoordinatesY );
    vec4 mouseCoordinatesMatrix = v_vMatrix * vec4( mouseCoordinates, 0.0, 1.0 );
    
    // vec4 surfaceTextureSample = texture2D( overlayTexture, mouseCoordinatesMatrix.xy );
    // vec4 modelTextureSample = texture2D( baseTexture, v_vTexcoord );
    
    // // The final fragment color. Model and Surface samples are mixed by the surface samples alpha.
    // vec4 finalColor = mix( modelTextureSample, surfaceTextureSample, surfaceTextureSample.a );
  
    // finalColor *= v_vColour;
    // gl_FragColor = finalColor;
    gl_FragColor = vec4( mouseCoordinatesMatrix.xy, 0.0, 1.0 );
}