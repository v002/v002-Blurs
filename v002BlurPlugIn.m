//
//  v002FBOGLSLTemplatePlugIn.m
//  v002FBOGLSLTemplate
//
//  Created by vade on 6/30/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002BlurPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Blur: Gaussian Blur"
#define	kQCPlugIn_Description		@"Massive Blur Massively fast"


#pragma mark -
#pragma mark Static Functions


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}

@implementation v002BlurPlugIn

@dynamic inputImage;
@dynamic inputAmount;
@dynamic outputImage;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	if([key isEqualToString:@"inputImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
	}
	
	if([key isEqualToString:@"inputAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Amount", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:5.0], QCPortAttributeMaximumValueKey,
				nil];
	}
		
	if([key isEqualToString:@"outputImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
	}
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage", @"inputAmount", nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init])
	{
		self.pluginShaderName = @"v002.blur";
		madeDisplayList = FALSE;
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end

@implementation v002BlurPlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{	
	CGLContextObj cgl_ctx = [context CGLContextObj];
		
	id<QCPlugInInputImageSource>   image = self.inputImage;
	NSUInteger width = [image imageBounds].size.width;
	NSUInteger height = [image imageBounds].size.height;
	NSRect bounds = [image imageBounds];
	
	GLfloat amt = self.inputAmount;
	GLfloat normalizedAmount = self.inputAmount / 5.0;
	
	CGColorSpaceRef cspace = ([image shouldColorMatch]) ? [context colorSpace] : [image imageColorSpace];
	if(image && [image lockTextureRepresentationWithColorSpace:cspace forBounds:[image imageBounds]])
	{	
		[image bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:NO];
		
		// save/restore state once
		glPushAttrib(GL_ALL_ATTRIB_BITS);
		glPushClientAttrib(GL_CLIENT_VERTEX_ARRAY_BIT);
	
        // set up clear color and blending once
		glDisable(GL_BLEND);
		
		// this must be called before any other FBO stuff can happen for 10.6
		[pluginFBO pushFBO:cgl_ctx];
		
		GLuint finalOutput;
		if(self.inputAmount <= 0.1)
		{		
			GLuint tex1 = [self renderToFBO:cgl_ctx width:[image imageBounds].size.width height:[image imageBounds].size.height bounds:[image imageBounds] texture:[image textureName] amountx:amt amounty:0.0];
			finalOutput = [self renderToFBO:cgl_ctx width:[image imageBounds].size.width height:[image imageBounds].size.height bounds:[image imageBounds] texture:tex1 amountx:0.0 amounty:amt];
			glDeleteTextures(1, &tex1);
		}
		else
		{
			GLuint texture[9];		
			
			// pass calculations
			GLfloat passRatio = 0.2;
			GLfloat passAmount = passRatio / normalizedAmount;
			passAmount = (passAmount >  1.0) ? 1.0 : passAmount; // make sure to not balloon size.
			NSUInteger newWidth = passAmount * width;
			NSUInteger newHeight = passAmount * height;
			NSRect newBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, newWidth, newHeight);
			texture[0] = [self renderToFBO:cgl_ctx width:width height:height bounds:newBounds texture:[image textureName] amountx:amt amounty:0.0];
		
			texture[1] = [self renderToFBO:cgl_ctx width:newBounds.size.width height:newBounds.size.height bounds:newBounds texture:texture[0] amountx:0.0 amounty:amt];			

			// pass calculations
			NSUInteger oldWidth = newWidth;
			NSUInteger oldHeight = newHeight;
			
			passRatio = 0.3;
			passAmount = passRatio / normalizedAmount;
			passAmount = (passAmount >  1.0) ? 1.0 : passAmount; // make sure to not balloon size.
			newWidth = passAmount * width;
			newHeight = passAmount * height;
			newBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, newWidth, newHeight);
			texture[2] = [self renderToFBO:cgl_ctx width:oldWidth height:oldHeight bounds:newBounds texture:texture[1] amountx:amt * 1.5 amounty:0.0];
			
			texture[3] = [self renderToFBO:cgl_ctx width:newBounds.size.width height:newBounds.size.height bounds:newBounds texture:texture[2] amountx:0.0 amounty:amt * 1.5];
			
			// pass calculations
			oldWidth = newWidth;
			oldHeight = newHeight;
			
			passRatio = 0.5;
			passAmount = passRatio / normalizedAmount;
			passAmount = (passAmount >  1.0) ? 1.0 : passAmount; // make sure to not balloon size.
			newWidth = passAmount * width;
			newHeight = passAmount * height;
			newBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, newWidth, newHeight);
			texture[4] = [self renderToFBO:cgl_ctx width:oldWidth height:oldHeight bounds:newBounds texture:texture[3] amountx:amt * 1.5 amounty:0.0];
			
			texture[5] = [self renderToFBO:cgl_ctx width:newBounds.size.width height:newBounds.size.height bounds:newBounds texture:texture[4] amountx:0.0 amounty:amt * 1.5];
			
			// pass calculations
			oldWidth = newWidth;
			oldHeight = newHeight;
			
			passRatio = 0.8;
			passAmount = passRatio / normalizedAmount;
			passAmount = (passAmount >  1.0) ? 1.0 : passAmount; // make sure to not balloon size.
			newWidth = passAmount * width;
			newHeight = passAmount * height;
			newBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, newWidth, newHeight);
			texture[6] = [self renderToFBO:cgl_ctx width:oldWidth height:oldHeight bounds:newBounds texture:texture[5] amountx:amt * 2.0 amounty:0.0];
			
			texture[7] = [self renderToFBO:cgl_ctx width:newBounds.size.width height:newBounds.size.height bounds:newBounds texture:texture[6] amountx:0.0 amounty:amt * 2.0];

			// pass calculations
			oldWidth = newWidth;
			oldHeight = newHeight;
			
		//	passRatio = 1.0;
		//	passAmount = passRatio / normalizedAmount;
		//	(passAmount >  1.0) ? 1.0 : passAmount; // make sure to not balloon size.
		//	newWidth = passAmount * width;
		//	newHeight = passAmount * height;
		//	newBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, newWidth, newHeight);
			texture[8] = [self renderToFBO:cgl_ctx width:oldWidth height:oldHeight bounds:[image imageBounds] texture:texture[7] amountx:amt amounty:0.0];

			finalOutput = [self renderToFBO:cgl_ctx width:[image imageBounds].size.width height:[image imageBounds].size.height bounds:[image imageBounds] texture:texture[8] amountx:0.0 amounty:amt];

			glDeleteTextures(9, texture);
		}

		[pluginFBO popFBO:cgl_ctx];

		glPopClientAttrib();
		glPopAttrib();
		
		id provider = nil;	

		if(finalOutput != 0)
		{
			
#if __BIG_ENDIAN__
#define v002QCPluginPixelFormat QCPlugInPixelFormatARGB8
#else
#define v002QCPluginPixelFormat QCPlugInPixelFormatBGRA8			
#endif
			// we have to use a 4 channel output format, I8 does not support alpha at fucking all, so if we want text with alpha, we need to use this and waste space. Ugh.
			provider = [context outputImageProviderFromTextureWithPixelFormat:v002QCPluginPixelFormat pixelsWide:[image imageBounds].size.width pixelsHigh:[image imageBounds].size.height name:finalOutput flipped:[image textureFlipped] releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[image shouldColorMatch]];
					
			self.outputImage = provider;
		
		}
		
		[image unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
		[image unlockTextureRepresentation];
		
	}	
	else
		self.outputImage = nil;
	
	return YES;
}

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx width:(NSUInteger)pixelsWide height:(NSUInteger)pixelsHigh bounds:(NSRect)bounds texture:(GLuint)texture amountx:(double)amountx amounty:(double)amounty
{
	GLsizei width = bounds.size.width,	height = bounds.size.height;

    // new texture
    GLuint fboTex = 0;
    glGenTextures(1, &fboTex);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, fboTex);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    [pluginFBO attachFBO:cgl_ctx withTexture:fboTex width:width height:height];
    
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture);
	
	// bind our shader program
	glUseProgramObjectARB([pluginShader programObject]);
	
	// set program vars
	glUniform1iARB([pluginShader getUniformLocation:"tex0"], 0); 
	glUniform2fARB([pluginShader getUniformLocation:"amount"], amountx, amounty); 
	
	// move to VA for rendering
	GLfloat tex_coords[] = 
	{
		pixelsWide,pixelsHigh,
		0.0,pixelsHigh,
		0.0,0.0,
		pixelsWide,0.0
	};
	
	GLfloat verts[] = 
	{
		width,height,
		0.0,height,
		0.0,0.0,
		width,0.0
	};
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
	glEnableClientState(GL_VERTEX_ARRAY);		
	glVertexPointer(2, GL_FLOAT, 0, verts );
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );	// TODO: GL_QUADS or GL_TRIANGLE_FAN?

	// disable shader program
	glUseProgramObjectARB(NULL);
	
    [pluginFBO detachFBO:cgl_ctx]; // pops out and resets cached FBO state from above.

	return fboTex;
}
@end