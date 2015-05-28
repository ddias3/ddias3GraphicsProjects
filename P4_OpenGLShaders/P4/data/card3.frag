//card3.frag fragment shader for the duck card

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXLIGHT_SHADER

// Set in Processing
uniform sampler2D texture;

// These values come from the vertex shader
varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertTexCoord;


void main()
{ 
	vec4 diffuse_color = texture2D(texture, vertTexCoord.xy);
	float diffuse = clamp(dot(vertNormal, vertLightDir), 0.0, 1.0);
	  
	float greyScaleIntensity = 0.2989 * diffuse_color.r + 0.5870 * diffuse_color.g + 0.1140 * diffuse_color.b;

	vec4 pixelUp    = texture2D(texture, vec2(vertTexCoord.x, vertTexCoord.y - 0.01));
	vec4 pixelLeft  = texture2D(texture, vec2(vertTexCoord.x - 0.01, vertTexCoord.y));
	vec4 pixelRight = texture2D(texture, vec2(vertTexCoord.x + 0.01, vertTexCoord.y));
	vec4 pixelDown  = texture2D(texture, vec2(vertTexCoord.x, vertTexCoord.y + 0.01));

	float pixelUpGreyScale    = 0.2989 * pixelUp.r + 0.5870 * pixelUp.g + 0.1140 * pixelUp.b;
	float pixelLeftGreyScale  = 0.2989 * pixelLeft.r + 0.5870 * pixelLeft.g + 0.1140 * pixelLeft.b;
	float pixelRightGreyScale = 0.2989 * pixelRight.r + 0.5870 * pixelRight.g + 0.1140 * pixelRight.b;
	float pixelDownGreyScale  = 0.2989 * pixelDown.r + 0.5870 * pixelDown.g + 0.1140 * pixelDown.b;

	float finalColorIntensity = clamp(1.2 * (pixelUpGreyScale + pixelLeftGreyScale + pixelRightGreyScale + pixelDownGreyScale - 4 * greyScaleIntensity), 0.0, 1.0);

	gl_FragColor = vec4(diffuse * vec3(finalColorIntensity, finalColorIntensity, finalColorIntensity), 1.0);
}