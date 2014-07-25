//
//  WKFlashModel.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKFlashTransmitModel.h"

#import "WKReceiverViewController.h"
#import "WKStringProcessing.h"

static CGFloat torchTogglePeriod = 0;
static const CGFloat samplesPerBit = 6.0;
static CMTime framePeriod;

@interface WKFlashTransmitModel ()
@property (readonly, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) dispatch_source_t timer;

// queue of bits to send, populated by methods matching enqueue*
@property (copy, nonatomic) NSArray /* of NSNumber BOOLs */ *bitQueue;
@property (assign, nonatomic) NSInteger transmissionIndex;

@property (assign, nonatomic) WKFlashTransmitModelMode mode;

@property (assign, nonatomic, getter = isTransmitting) BOOL transmitting;

@property (assign, nonatomic) CGFloat torchTogglePeriod;
@property (readonly, nonatomic) WKStringProcessing *stringProcessor;
@end

@implementation WKFlashTransmitModel

+ (CGFloat)torchTogglePeriod {
  if (torchTogglePeriod == 0) {
    framePeriod = [WKReceiverViewController configureCameraForHighestFrameRate:[self captureDevice]];
    torchTogglePeriod = CMTimeGetSeconds(framePeriod) * samplesPerBit;
  }
  return torchTogglePeriod;
}

+ (NSInteger)samplesPerBit {
  return (NSInteger)round(samplesPerBit);
}

+ (AVCaptureDevice *)captureDevice {
  return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (instancetype)init {
  if (self = [super init]) {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_source_set_event_handler(self.timer, ^{
      [self _transmitBit];
    });
    _captureDevice = [[self class] captureDevice];
    _stringProcessor = [[WKStringProcessing alloc] init];
  }
  return self;
}

- (void)dealloc {
  
}

#pragma mark Public

- (void)transmitEnqueuedMessage {
  if (self.bitQueue.count > 0) {
    self.transmitting = YES;
  }
}

- (void)enqueueMessage:(NSString *)message mode:(WKFlashTransmitModelMode)mode {
  message = [self _stripNonAscii:message];
  
  switch (mode) {
    case WKFlashTransmitModelModeSerial:
      [self _enqueueSerialMessage:message];
      break;
      
    case WKFlashTransmitModelModeMorse:
      [NSException raise:@"NoMorseException" format:@"Morse isn't implemented yet!"];
      break;
    default:
      break;
  }
}

#pragma mark - Private

#pragma mark Enqueueing


/* 
 Enqueue the message in serial format, like so:
 
 | NO | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | YES |
 
 Where the initial NO is the start bit, the numerals are the bits of a character, 
 little-endian, and YES is the stop bit.
 */
- (void)_enqueueSerialMessage:(NSString *)message {
  self.bitQueue = [self.stringProcessor compressAndSerializeMessage:message];
  self.mode = WKFlashTransmitModelModeSerial;
  
  [self _logSerialMessage];
}

- (void)_logSerialMessage {
  NSMutableString *logString = [NSMutableString string];
  for (NSInteger i = 0; i < self.bitQueue.count; i++) {
    if (i != 0 && (i % 10) == 0) {
      if (i % 40 == 0) {
        NSLog(@"%@", logString);
      } else {
        [logString appendString:@" "];
      }
    }
    [logString appendString:([self.bitQueue[i] boolValue] ? @"1" : @"0")];
  }
  NSLog(@"%@", logString);
}

#pragma mark Transmission

- (void)_transmitBit {
  if (self.transmissionIndex >= self.bitQueue.count) {
    self.transmitting = NO;
    return;
  }
  
  [self _setTorch:![self.bitQueue[self.transmissionIndex] boolValue]];
  
  
  id<WKFlashTransmitModelDelegate> delegate = self.delegate;
  [delegate torchDidUpdate:![self.bitQueue[self.transmissionIndex] boolValue]];
  
  self.transmissionIndex++;
}

- (void)setTransmitting:(BOOL)transmitting {
  if (transmitting == _transmitting) return;
  _transmitting = transmitting;
  
  if (_transmitting) {
    [self _warmTorch];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, [[self class] torchTogglePeriod] * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
      dispatch_resume(self.timer);
    });
  } else {
    dispatch_suspend(self.timer);
    self.transmissionIndex = 0;
  }
}

#pragma mark String cleaning

- (NSString *)_stripNonAscii:(NSString *)dirty {
  NSMutableString *asciiChars = [NSMutableString string];
  for (unsigned char i = 32; i < 127; i++) {
    [asciiChars appendFormat:@"%c", i];
  }
  
  NSCharacterSet *nonAsciiCharSet = [[NSCharacterSet characterSetWithCharactersInString:asciiChars] invertedSet];
  return [[dirty componentsSeparatedByCharactersInSet:nonAsciiCharSet] componentsJoinedByString:@""];
}

#pragma mark Torch

- (void)_warmTorch {
  if ([self.captureDevice isTorchModeSupported:AVCaptureTorchModeOn] && [self.captureDevice isTorchAvailable]) {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchModeOnWithLevel:0.01 error:nil];
    [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
    [self.captureDevice unlockForConfiguration];
  }
}

- (void)_toggleTorch {
  [self _setTorch:![self _torchOn]];
}

- (void)_setTorch:(BOOL)on {
  if ([self.captureDevice isTorchModeSupported:AVCaptureTorchModeOn] && [self.captureDevice isTorchAvailable]) {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode:(on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff)];
    [self.captureDevice unlockForConfiguration];
  }
}

- (BOOL)_torchOn {
  return [self.captureDevice isTorchActive];
}

@end
