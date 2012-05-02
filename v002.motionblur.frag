varying vec2 texcoord0;
varying vec2 texcoord1;
varying vec2 texcoord2;
varying vec2 texcoord3;
varying vec2 texcoord4;
varying vec2 texcoord5;
varying vec2 texcoord6;
varying vec2 texcoord7;
varying vec2 texcoord8;

// define our rectangular texture samplers 
uniform sampler2DRect tex0;

void main (void) 
{ 
	// sample our textures
	vec4 sample0 = texture2DRect(tex0, texcoord0);
	vec4 sample1 = texture2DRect(tex0, texcoord1);
	vec4 sample2 = texture2DRect(tex0, texcoord2);
	vec4 sample3 = texture2DRect(tex0, texcoord3);
	vec4 sample4 = texture2DRect(tex0, texcoord4);
	vec4 sample5 = texture2DRect(tex0, texcoord5);
	vec4 sample6 = texture2DRect(tex0, texcoord6);
	vec4 sample7 = texture2DRect(tex0, texcoord7);
	vec4 sample8 = texture2DRect(tex0, texcoord8);

	// quasi gaussian distro
/*	vec4 result = sample0 * .25;
	result += (sample4 + sample5) * 0.2;
	result += (sample3 + sample6) * 0.1;
	result += (sample2 + sample7) * 0.05;
	result += (sample1 + sample8) * 0.025;
	gl_FragColor = result;
*/
	//straight averaging	
	gl_FragColor = (sample0 + sample1 + sample2 + sample3 + sample4 + sample5 + sample6 + sample7 + sample8) / 9.0;

} 

