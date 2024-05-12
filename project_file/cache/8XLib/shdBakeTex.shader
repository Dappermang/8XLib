attribute vec2 in_TextureCoord; // (u, v)
attribute vec3 in_Position; // (x, y, z)
attribute vec4 in_Colour; // (r, g, b, a)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vCameraPosition;

uniform mat4 u_mMatrix;

void main() {
	vec4 objectWorldPosition = vec4( in_Position, 1.0 );
	
	/* 
		v_vColour <- Vertex Colour
		v_vTexcoord <- UV Coordinate
		v_vCameraPosition <- Camera Position
	*/
	v_vTexcoord = in_TextureCoord;
	v_vColour = in_Colour;
	v_vCameraPosition = u_mMatrix * objectWorldPosition;
	
	// Vertex Position based on the current ( orthographic ) projection.
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * objectWorldPosition;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vCameraPosition;

uniform vec2 u_vTextureSize;
uniform vec2 u_vTargetScale;
uniform sampler2D u_vBaseTexture;
uniform sampler2D u_vOverlayTexture;
uniform mat4 u_mMatrix;

void main() {
	// vec3 uvPosition = vec3( v_vTexcoord, 1.0 );
	// vec4 uvPositionTransformed = v_vCameraPosition * vec4( uvPosition, 1.0 );
	
	
	vec3 screenPosition = 0.5 * ( vec3( 1.0 ) + v_vCameraPosition.xyz / v_vCameraPosition.w );
	vec3 overlayUV = vec3( screenPosition.xy * u_vTargetScale, screenPosition.z );
	float overlayIntensity = texture2D( u_vOverlayTexture, overlayUV.xy ).r;
	
    vec4 overlayTextureSample = texture2D( u_vOverlayTexture, v_vTexcoord );
    vec4 modelTextureSample = texture2D( u_vBaseTexture, v_vTexcoord );
    
    // The final fragment color. Model and Surface samples are mixed by the surface samples alpha.
    vec4 finalColor = mix( modelTextureSample, overlayTextureSample, overlayTextureSample.a );
    
    finalColor *= v_vColour;
    gl_FragColor = finalColor;
    
    // UV DEBUG
    // gl_FragColor = vec4( v_vTexcoord.xy, 0.0, 1.0 );
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

