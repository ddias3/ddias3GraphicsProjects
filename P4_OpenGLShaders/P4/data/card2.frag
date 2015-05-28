//card2.frag: fragment shader for the mandelbrot card

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
	vec4 diffuse_color = vec4 (1.0, 0.0, 0.0, 1.0);
	float diffuse = clamp(dot(vertNormal, vertLightDir),0.0,1.0);

	vec2 complexNumberC = vec2(3 * vertTexCoord.x - 2.1, -3 * vertTexCoord.y + 1.5);

	vec2 current = vec2(0, 0);
	for (int n = 1; n <= 20; ++n)
	{
		vec2 previous = current;
		current = vec2(previous.x * previous.x - previous.y * previous.y, 2 * previous.x * previous.y) + complexNumberC;
	}

	if (length(current) < 2)
	{
		gl_FragColor = vec4(diffuse * vec3(1.0, 1.0, 1.0), 1.0);
	}
	else
	{
		gl_FragColor = vec4(diffuse * diffuse_color.rgb, 1.0);
	}
}