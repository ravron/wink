//
//  WKFlashModel.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKFlashModel.h"

#import <AVFoundation/AVFoundation.h>

static const CGFloat kTorchTogglePeriod = 0.05;

@interface WKFlashModel ()
@property (readonly, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) dispatch_source_t timer;
@end

@implementation WKFlashModel

- (instancetype)init {
  if (self = [super init]) {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, kTorchTogglePeriod * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
      [self _toggleTorch];
    });
  }
  return self;
}

- (void)dealloc {
  
}

#pragma mark Public

- (void)setEnabled:(BOOL)enabled {
  if (enabled == _enabled) return;
  _enabled = enabled;
  
  if (_enabled) {
    dispatch_resume(self.timer);
  } else {
    dispatch_suspend(self.timer);
  }
}

#pragma mark Private

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

- (AVCaptureDevice *)captureDevice {
  return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

@end
