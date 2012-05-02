//
//  v002BlurPlugIn.h
//  v002Blur
//
//  Created by vade on 7/10/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002ZoomBlurPlugIn : v002MasterPluginInterface
{
}

@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) double inputAmount;
@property (assign) double inputOriginX;
@property (assign) double inputOriginY;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;

@end

@interface v002ZoomBlurPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx width:(NSUInteger)pixelsWide height:(NSUInteger)pixelsHigh bounds:(NSRect)bounds texture:(GLuint)texture amount:(double)amount originx:(double)originX originy:(double) originY;
@end

