//card4.vert: vertex shader for the mountain card

// Our shader uses both processing's texture and light variables
#define PROCESSING_TEXLIGHT_SHADER

// Set automatically by Processing
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;
uniform mat4 texMatrix;
uniform sampler2D texture;


// Come from the geometry/material of the object
attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

// These values will be sent to the fragment shader
varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertTexCoord;
varying vec4 vertTexCoordR;
varying vec4 vertTexCoordL;

void main()
{
    vertColor = color;
    vertNormal = normalize(normalMatrix * normal);
    vec4 vert = vertex;
    
    vertLightDir = normalize(-lightNormal);
    vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
	
	vec4 vertColor = texture2D(texture, vertTexCoord.xy);
	float greyScaleIntensity = 0.2989 * vertColor.r + 0.5870 * vertColor.g + 0.1140 * vertColor.b;

	vert = vert + vec4(75 * vertNormal * greyScaleIntensity, 0);

		// This changes the vertex's location in the Z-Buffer
	//vec4 newPosition = vec4(transform * vert);
	//newPosition.z = newPosition.z + 100 * greyScaleIntensity;

	vec4 newPosition = vec4(transform * vert);

	gl_Position = newPosition;
}