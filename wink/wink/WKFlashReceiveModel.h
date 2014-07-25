//
//  WKFlashReceiveModel.h
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WKFlashTransmitModel.h"
#import <AVFoundation/AVFoundation.h>

@interface WKFlashReceiveModel : NSObject

- (void)signalCalculated:(BOOL)on delta:(CMTime)delta;

@end
