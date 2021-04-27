#include <stdio.h>

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface DeeplabModel : NSObject
- (unsigned char *)process:(CVPixelBufferRef)pixelBuffer additionalColor:(unsigned int)additionalColor;
- (BOOL)loadModel:(NSString *)modelName;
@end
