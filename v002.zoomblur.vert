varying vec2 texcoord0;
varying vec2 texcoord1;
varying vec2 texcoord2;
varying vec2 texcoord3;
varying vec2 texcoord4;
varying vec2 texcoord5;
varying vec2 texcoord6;
varying vec2 texcoord7;
varying vec2 texcoord8;

uniform float amount;
uniform vec2 origin;
uniform vec2 texdim0;

void main()
{
    // perform standard transform on vertex
    gl_Position = ftransform();

    // transform texcoords
	vec2 texcoord = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
	
	vec2 originNative = origin * texdim0;
	vec2 destination = texcoord - originNative;
	vec2 off = (destination * amount)/(texdim0 * amount); 

	texcoord0 = destination + originNative;
	texcoord1 = ((destination + off * 3. * (amount * 0.2)) + originNative);
	texcoord2 = ((destination - off * 3. * (amount * 0.2)) + originNative);
	texcoord3 = ((destination + off * 6. * (amount * 0.2)) + originNative);
	texcoord4 = ((destination - off * 6. * (amount * 0.2)) + originNative);
	texcoord5 = ((destination + off * 12. * (amount * 0.2)) + originNative);
	texcoord6 = ((destination - off * 12. * (amount * 0.2)) + originNative);
	texcoord7 = ((destination + off * 18. * (amount * 0.2)) + originNative);
	texcoord8 = ((destination - off * 18. * (amount * 0.2)) + originNative);
}