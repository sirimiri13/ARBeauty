#include <stdio.h>

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface NailsDeeplabModel : NSObject
- (unsigned char *)process:(CVPixelBufferRef) pixelBuffer;
- (BOOL)loadModel;
@end
