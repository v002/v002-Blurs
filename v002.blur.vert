varying vec2 texcoord0;
varying vec2 texcoord1;
varying vec2 texcoord2;
//varying vec2 texcoord3;
//varying vec2 texcoord4;
//varying vec2 texcoord5;
//varying vec2 texcoord6;
//varying vec2 texcoord7;
//varying vec2 texcoord8;

uniform vec2 amount;

void main()
{
    // perform standard transform on vertex
    gl_Position = ftransform();

    // transform texcoords
    texcoord0 = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
	
	/*
	
		1	2	3
		4	0	5
		6	7	8
	
	*/
	
	// we use a two pass separable blur kernel, so we go verical/horizontal seperately.
	texcoord1 = texcoord0 + vec2(-amount);
    texcoord2 = texcoord0 + vec2(amount);
    
	
/*  texcoord1 = texcoord0 + vec2(-amount, -amount);
    texcoord2 = texcoord0 + vec2(0, amount);
    texcoord3 = texcoord0 + vec2(amount, amount);
    texcoord4 = texcoord0 + vec2(-amount, 0);
    texcoord5 = texcoord0 + vec2(amount, 0);
    texcoord6 = texcoord0 + vec2(-amount, amount);
    texcoord7 = texcoord0 + vec2(0, -amount);
	texcoord8 = texcoord0 + vec2(amount, -amount);
*/
}