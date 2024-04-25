varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vCameraPosition;

uniform sampler2D u_vBaseTexture;
uniform sampler2D u_vOverlayTexture;
uniform mat4 u_vMatrix;

void main() {
	vec3 uvPos = vec3( v_vTexcoord, 1.0 );
	vec4 uvTransformed = u_vMatrix * vec4( uvPos, 1.0 );
	vec2 uvUsable = uvTransformed.xy / uvTransformed.z;
	
	vec3 screenPosition = 0.5 * ( vec3( 1.0, 1.0, 1.0 ) + v_vCameraPosition.xyz / v_vCameraPosition.w );
	vec3 overlayUV = vec3( screenPosition.xy * vec2( 1.0, 1.0 ), screenPosition.z );
	float overlayIntensity = texture2D( u_vOverlayTexture, overlayUV.xy ).r;
	
    vec4 overlayTextureSample = texture2D( u_vOverlayTexture, uvUsable );
    vec4 modelTextureSample = texture2D( u_vBaseTexture, v_vTexcoord );
    
    // The final fragment color. Model and Surface samples are mixed by the surface samples alpha.
    vec4 finalColor = mix( modelTextureSample, overlayTextureSample, overlayTextureSample.a );
    
    // finalColor *= v_vColour;
    // gl_FragColor = finalColor;
    
    // UV DEBUG
    gl_FragColor = vec4( v_vTexcoord.xy, 0.0, 1.0 );
}

//PAINT
// uniform sampler2D meshTexture;
// uniform sampler2D paintTexture;
// uniform vec4 brushColor;
// uniform vec2 targetScale;
// in vec2 meshUv;
// in vec4 cameraPos;
// void main() {
//     // convert the UV position to the camera's screen 
//     // position so we can do the texture lookup
//     vec3 screenPos = 0.5 * (vec3(1,1,1) + cameraPos.xyz / cameraPos.w);
//     vec3 paintUv = vec3(screenPos.xy * targetScale, screenPos.z);    // get paint intensity from screen coordinates
//     float paintIntensity = texture2D(paintTexture, paintUv.xy).r;    // we overwrite the mesh texture every time, so the final 
//     // color is a blend of what was already there and what has 
//     // been painted
//     vec4 meshColor = texture2D(meshTexture, meshUv);
//     vec3 diffuseColor = mix(meshColor.rgb, brushColor.rgb, paintIntensity);    
    
//     gl_FragColor = vec4(diffuseColor, 1);
// }
// //===