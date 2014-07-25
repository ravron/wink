//
//  WKFlashModel.h
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WKFlashTransmitModelMode) {
  WKFlashTransmitModelModeSerial,
  WKFlashTransmitModelModeMorse,
};

static const CGFloat kDebugSlowdownFactor = 3;
static const CGFloat kTorchTogglePeriod = (1.0/15.0) * kDebugSlowdownFactor;

@interface WKFlashTransmitModel : NSObject
@property (readonly, nonatomic, getter = isTransmitting) BOOL transmitting;

- (void)enqueueMessage:(NSString *)message mode:(WKFlashTransmitModelMode)mode;
- (void)transmitEnqueuedMessage;
@end
