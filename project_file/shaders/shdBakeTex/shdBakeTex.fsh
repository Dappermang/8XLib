varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float targetScale;
uniform sampler2D baseTexture;
uniform sampler2D overlayTexture;

varying vec2 v_vUVPosition;
varying vec4 v_vCameraPosition;

void main() {
	vec3 screenPosition = 0.5 * ( vec3( 1.0, 1.0, 1.0 ) + v_vCameraPosition.xyz / v_vCameraPosition.w );
	vec3 overlayUV = vec3( screenPosition.xy * targetScale, screenPosition.y );
	
	float overlayIntensity = texture2D( overlayTexture, overlayUV.xy ).r;
	
	vec4 meshColour = texture2D( baseTexture, v_vUVPosition );
	vec3 diffuseColour = mix( meshColour.rgb, meshColour.rgb * overlayIntensity, overlayIntensity );
	
	gl_FragColor = vec4( diffuseColour, 1.0 );
}