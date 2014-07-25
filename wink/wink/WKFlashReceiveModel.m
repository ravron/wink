//
//  WKFlashReceiveModel.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKFlashReceiveModel.h"

#import "WKStringProcessing.h"

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
@property (assign, nonatomic) NSInteger dataBitsThisFrame;

@property (strong, nonatomic) NSMutableArray *incomingBits;
@property (strong, nonatomic) NSMutableArray *bitHistory;

@property (readonly, nonatomic) WKStringProcessing *stringProcessor;
@property (strong, nonatomic) NSString *currentMessage;
@end

@implementation WKFlashReceiveModel

- (instancetype)init {
  return [self initWithMode:WKFlashTransmitModelModeSerial];
}

- (instancetype)initWithMode:(WKFlashTransmitModelMode)mode {
  if (self = [super init]) {
    _mode = mode;
    _samplesPerBit = [WKFlashTransmitModel samplesPerBit];
    _state = WKFlashReceiveStateDisabled;
    _bitHistory = [NSMutableArray array];
    _stringProcessor = [[WKStringProcessing alloc] init];
  }
  return self;
}

- (void)setEnabled:(BOOL)enabled {
  if (!enabled) {
    self.state = WKFlashReceiveStateDisabled;
    self.currentMessage = [self.stringProcessor deserializeAndDecompressData:self.incomingBits];
    if (self.currentMessage) {
      id<WKFlashReceiveModelDelegate> delegate = self.delegate;
      [delegate didReceiveMessage:self.currentMessage];
    }
  } else {
    self.state = WKFlashReceiveStateIdle;
    self.incomingBits = [NSMutableArray array];
  }
}

- (BOOL)isEnabled {
  return !(self.state == WKFlashReceiveStateDisabled);
}

- (void)signalCalculated:(BOOL)on {
  if (self.state == WKFlashReceiveStateDisabled) return;
  BOOL bit = !on;
  if (self.state != WKFlashReceiveStateIdle) {
    [self.bitHistory addObject:[NSNumber numberWithBool:bit]];
  }
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
        [self.bitHistory addObject:@"Start"];
        NSLog(@"Start");
      }
      break;
      
    case WKFlashReceiveStateStart:
      self.samplesThisBit++;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        self.state = WKFlashReceiveStateData;
        self.dataBitsThisFrame = 0;
        [self.bitHistory addObject:@"Data"];
        NSLog(@"Data");
      } else if (self.samplesThisBit == self.samplesPerBit / 2) {
        if (bit == YES) {
          self.state = WKFlashReceiveStateIdle;
          NSLog(@"Error Idle from start!");
        }
      }
      break;
      
    case WKFlashReceiveStateData:
      self.samplesThisBit++;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        if (self.dataBitsThisFrame == kDataBitsPerFrame) {
          self.state = WKFlashReceiveStateStop;
          [self.bitHistory addObject:@"Stop"];
          NSLog(@"Stop");
        }
      } else if (self.samplesThisBit == self.samplesPerBit / 2) {
        [self.incomingBits addObject:[NSNumber numberWithBool:bit]];
        self.dataBitsThisFrame++;
        NSLog(@"Bit");
        [self.bitHistory addObject:@"Bit"];
      }
      break;
    
    case WKFlashReceiveStateStop:
      self.samplesThisBit++;
      if (self.samplesThisBit >= self.samplesPerBit) {
        self.samplesThisBit = 0;
        self.state = WKFlashReceiveStateIdle;
        [self.bitHistory addObject:@"Idle"];
      } else if (self.samplesThisBit == self.samplesPerBit / 2) {
        if (bit == NO) {
          self.state = WKFlashReceiveStateIdle;
          NSLog(@"Error Idle!");
        }
      }
      break;
  }
}

@end






