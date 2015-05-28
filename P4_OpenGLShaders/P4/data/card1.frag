//card1.frag: fragment shader for the swiss cheese card.

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_LIGHT_SHADER

// These values come from the vertex shader
varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertTexCoord;

void main()
{ 
	vec4 diffuse_color = vec4 (0.0, 1.0, 1.0, 1.0);
	float diffuse = clamp(dot(vertNormal, vertLightDir), 0.0, 1.0);

	for (int x = 0; x < 3; ++x)
	{
		for (int y = 0; y < 3; ++y)
		{
			if (length((vertTexCoord.xy - vec2(0.2 + 0.3 * x, 0.2 + 0.3 * y))) < 0.1)
			{
				gl_FragColor = vec4(diffuse * diffuse_color.rgb, 0.0);
				return;
			}
		}
	}

	gl_FragColor = vec4(diffuse * diffuse_color.rgb, 0.8);
}
