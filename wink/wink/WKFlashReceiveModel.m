//
//  WKFlashReceiveModel.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKFlashReceiveModel.h"

typedef NS_ENUM(NSUInteger, WKFlashReceiveState) {
  WKFlashReceiveStateDisabled,
  WKFlashReceiveStateIdle,
  WKFlashReceiveStateStart,
  WKFlashReceiveStateData,
  WKFlashReceiveStateStop,
};

static const NSInteger kDataBitsPerFrame = 8;

@interface WKFlashReceiveModel ()
@property (assign, nonatomic) WKFlashReceiveState state;
@property (assign, nonatomic) WKFlashTransmitModelMode mode;

@property (strong, nonatomic) NSDate *lastDeltaDate;

@property (readonly, nonatomic) NSInteger samplesPerBit;
@property (assign, nonatomic) NSInteger samplesThisBit;

@property (strong, nonatomic) NSMutableString *incomingMessage;
@property (strong, nonatomic) NSMutableArray *incomingBits;
@end

@implementation WKFlashReceiveModel

- (instancetype)init {
  return [self initWithMode:WKFlashTransmitModelModeSerial];
}

- (instancetype)initWithMode:(WKFlashTransmitModelMode)mode {
  if (self = [super init]) {
    _mode = mode;
    _samplesPerBit = (NSInteger)round(kTorchTogglePeriod / (1.0 / 30.0));
    _state = WKFlashReceiveStateDisabled;
  }
  return self;
}

- (NSString *)currentMessage {
  return [self.incomingMessage copy];
}

- (void)setEnabled:(BOOL)enabled {
  if (!enabled) {
    self.state = WKFlashReceiveStateDisabled;
  } else {
    self.state = WKFlashReceiveStateIdle;
    self.incomingMessage = [NSMutableString string];
  }
}

- (BOOL)isEnabled {
  return !(self.state == WKFlashReceiveStateDisabled);
}

- (void)signalCalculated:(BOOL)on {
  if (self.state == WKFlashReceiveStateDisabled) return;
  BOOL bit = !on;
  switch (self.state) {
    case WKFlashReceiveStateDisabled:
      return;
      break;
      
    case WKFlashReceiveStateIdle:
      if (bit == YES) {
        return;
      } else {
        self.samplesThisBit = 1;
        self.state = WKFlashReceiveStateStart;
      }
      break;
      
    case WKFlashReceiveStateStart:
      self.samplesThisBit++;
      if (bit == YES) self.state = WKFlashReceiveStateIdle;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        self.state = WKFlashReceiveStateData;
        self.incomingBits = [NSMutableArray arrayWithCapacity:8];
      }
      break;
      
    case WKFlashReceiveStateData:
      self.samplesThisBit++;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        if (self.incomingBits.count > 0 && self.incomingBits.count % kDataBitsPerFrame == 0) {
          self.state = WKFlashReceiveStateStop;
        }
      } else if (self.samplesThisBit == self.samplesPerBit / 2) {
        [self.incomingBits addObject:[NSNumber numberWithBool:bit]];
      }
      break;
    
    case WKFlashReceiveStateStop:
      self.samplesThisBit++;
      if (bit == NO) self.state = WKFlashReceiveStateIdle;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        self.state = WKFlashReceiveStateIdle;
        [self _parseBitArray];
      }
      break;
  }
}

- (void)_parseBitArray {
  unsigned char c = 0;
  if (self.incomingBits.count != kDataBitsPerFrame) {
    [NSException raise:@"Wrong number of bits:" format:@"%d", self.incomingBits.count];
  }
  
  for (NSInteger i = 0; i < self.incomingBits.count; i++) {
    NSNumber *bit = self.incomingBits[i];
    unsigned char mask = [bit boolValue] ? 128 : 0;
    c |= mask;
    if (i < self.incomingBits.count - 1) {
      c = c >> 1;
    }
  }

  [self.incomingMessage appendFormat:@"%c", c];
}

@end






