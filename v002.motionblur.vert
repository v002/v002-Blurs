varying vec2 texcoord0;
varying vec2 texcoord1;
varying vec2 texcoord2;
varying vec2 texcoord3;
varying vec2 texcoord4;
varying vec2 texcoord5;
varying vec2 texcoord6;
varying vec2 texcoord7;
varying vec2 texcoord8;

uniform vec2 texdim0;
uniform float amount;
uniform float angle;

void main()
{
	// if this call is below/after gl_Position = ftransform(); , things break.
	float theta = radians(angle); 

	// perform standard transform on vertex
    gl_Position = ftransform();
	
	// transform texcoords
	texcoord0 = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);

	// our offsets, where we sample
	vec2 amount1,amount2,amount3,amount4,amount5,amount6,amount7,amount8; 

	amount1 = vec2(cos(theta), sin(theta)) * amount;
	amount2 = amount1 *3.0;
	amount3 = amount1 *6.0;
	amount4 = amount1 *9.0;

	amount5 = -amount1;
	amount6 = amount5 * 3.0;
	amount7 = amount5 * 6.0;
	amount8 = amount5 * 9.0;
	
	texcoord1 = texcoord0 + amount1;
	texcoord2 = texcoord0 + amount2;
	texcoord3 = texcoord0 + amount3;
	texcoord4 = texcoord0 + amount4;
	texcoord5 = texcoord0 + amount5;
	texcoord6 = texcoord0 + amount6;
	texcoord7 = texcoord0 + amount7;
	texcoord8 = texcoord0 + amount8;	
}