//
//  v002BlurPlugIn.h
//  v002Blur
//
//  Created by vade on 7/10/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002MotionBlurPlugIn : v002MasterPluginInterface
{
	const GLcharARB    *fragmentShaderSource;				// the GLSL source for our fragment Shader
	const GLcharARB    *vertexShaderSource;					// the GLSL source for our vertex Shader
	GLhandleARB		    glslProgramObject;					// the program object
	
	GLuint frameBuffer;
	GLint previousFBO;

	id<QCPlugInContext> pluginContext;	
}

@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) double inputAmount;
@property (assign) double inputAngle;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;


@end

@interface v002MotionBlurPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx width:(NSUInteger)pixelsWide height:(NSUInteger)pixelsHigh bounds:(NSRect)bounds texture:(GLuint)texture amount:(double)amount angle:(double)angle;
@end
