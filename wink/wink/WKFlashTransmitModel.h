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

@interface WKFlashTransmitModel : NSObject
@property (readonly, nonatomic, getter = isTransmitting) BOOL transmitting;

- (void)enqueueMessage:(NSString *)message mode:(WKFlashTransmitModelMode)mode;
- (void)transmitEnqueuedMessage;
@end
