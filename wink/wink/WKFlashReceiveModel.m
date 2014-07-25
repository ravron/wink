//
//  WKFlashReceiveModel.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKFlashReceiveModel.h"

typedef NS_ENUM(NSUInteger, WKFlashReceiveState) {
  WKFlashReceiveStateIdle,
  WKFlashReceiveStateStart,
  WKFlashReceiveStateData,
  WKFlashReceiveStateStop,
};

@interface WKFlashReceiveModel ()
@property (assign, nonatomic) WKFlashReceiveState state;
@property (assign, nonatomic) WKFlashTransmitModelMode mode;

@property (strong, nonatomic) NSDate *lastDeltaDate;
@end

@implementation WKFlashReceiveModel

- (instancetype)init {
  return [self initWithMode:WKFlashTransmitModelModeSerial];
}

- (instancetype)initWithMode:(WKFlashTransmitModelMode)mode {
  if (self = [super init]) {
    _mode = mode;
  }
  return self;
}

- (void)signalCalculated:(BOOL)on delta:(CMTime)delta {
  BOOL bit = !on;
  switch (self.state) {
    case WKFlashReceiveStateIdle:
      
      break;
      
    case WKFlashReceiveStateStart:
      break;
      
    case WKFlashReceiveStateData:
      break;
    
    case WKFlashReceiveStateStop:
      break;
  }
}

@end
