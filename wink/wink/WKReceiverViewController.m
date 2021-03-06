//
//  WKReceiverViewController.m
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKReceiverViewController.h"

#import "GPUImage.h"

@interface WKReceiverViewController ()
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (strong, nonatomic) GPUImageView *rawVideoView;
@property (strong, nonatomic) GPUImageView *filteredVideoView;
@property (assign, nonatomic) CGRect zoomRect;
@property (strong, nonatomic) WKFlashReceiveModel *receiveModel;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (assign, nonatomic) BOOL lastSignal;
@end

@implementation WKReceiverViewController

+ (CMTime)configureCameraForHighestFrameRate:(AVCaptureDevice *)device {
  AVCaptureDeviceFormat *bestFormat = nil;
  AVFrameRateRange *bestFrameRateRange = nil;
  for ( AVCaptureDeviceFormat *format in [device formats] ) {
    for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
      if ( range.maxFrameRate >= bestFrameRateRange.maxFrameRate ) {
        bestFormat = format;
        bestFrameRateRange = range;
      }
    }
  }
  if ( bestFormat ) {
    if ( [device lockForConfiguration:nil] == YES ) {
      device.activeFormat = bestFormat;
      device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
      device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
      [device unlockForConfiguration];
    }
  }
  return bestFrameRateRange.minFrameDuration;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.filterButton.layer.cornerRadius = 4.f;
  self.startButton.layer.cornerRadius = 4.f;
  
  self.zoomRect = CGRectMake(0.4, 0.4, 0.2, 0.2);
  self.messageTextView.hidden = YES;
  self.messageTextView.textContainerInset = UIEdgeInsetsMake(20, 10, 10, 10);
  self.receiveModel = [[WKFlashReceiveModel alloc] init];
  self.receiveModel.delegate = self;

  self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

//  [self.videoCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
  
  CGRect filteredRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2);
  CGRect rawRect = CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2);
  
  self.filteredVideoView = [[GPUImageView alloc] initWithFrame:filteredRect];
  self.filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self.view addSubview:self.filteredVideoView];
  [self.view sendSubviewToBack:self.filteredVideoView];
  
  self.rawVideoView = [[GPUImageView alloc] initWithFrame:rawRect];
  self.rawVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self.view addSubview:self.rawVideoView];
  [self.view sendSubviewToBack:self.rawVideoView];
  
  CGRect targetRect = CGRectMake(rawRect.origin.x + (self.zoomRect.origin.x * rawRect.size.width),
                                 rawRect.origin.y + (self.zoomRect.origin.y * rawRect.size.height),
                                 rawRect.size.width * self.zoomRect.size.width,
                                 rawRect.size.height * self.zoomRect.size.height);
  
  UIView *targetView = [[UIView alloc] initWithFrame:targetRect];
  targetView.backgroundColor = [UIColor clearColor];
  targetView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
  targetView.layer.borderWidth = 1.0f;
  
  [self.view addSubview:targetView];
  
//  AVCaptureConnection *captureConnection = [self.videoCamera videoCaptureConnection];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//  captureConnection.videoMinFrameDuration = CMTimeMake(1, 60);
//  captureConnection.videoMaxFrameDuration = CMTimeMake(1, 60);
//#pragma clang diagnostic pop

  
  [[self class] configureCameraForHighestFrameRate:self.videoCamera.inputCamera];

  [self.videoCamera addTarget:self.rawVideoView];
  [self _disableFilters];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.videoCamera startCameraCapture];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self.videoCamera stopCameraCapture];
  NSLog(@"%@", self.receiveModel.currentMessage);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"adjustingExposure"]) {
    BOOL adjustingExposure = (BOOL)[change objectForKey:NSKeyValueChangeNewKey];
    if (!adjustingExposure) {
      [self.videoCamera.inputCamera lockForConfiguration:nil];
      self.videoCamera.inputCamera.exposureMode = AVCaptureExposureModeLocked;
      [self.videoCamera.inputCamera unlockForConfiguration];
      NSLog(@"Camera exposure locked");
    }
  }
}

- (void)_enableFilters {
  [self.videoCamera removeAllTargets];
  [self.videoCamera addTarget:self.rawVideoView];
  GPUImageLuminanceThresholdFilter *luminanceFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
  luminanceFilter.threshold = .99;
  
//  GPUImageOpeningFilter *openingFilter = [[GPUImageOpeningFilter alloc] initWithRadius:4];
  
  GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:self.zoomRect];
  
//  GPUImageDifferenceBlendFilter *differenceBlend = [[GPUImageDifferenceBlendFilter alloc] init];
  
  [self.videoCamera addTarget:cropFilter];
  [cropFilter addTarget:luminanceFilter];
  [luminanceFilter addTarget:self.filteredVideoView];
  
//  [luminanceFilter addTarget:differenceBlend];
//  [openingFilter addTarget:differenceBlend];
//  [differenceBlend addTarget:filteredVideoView];
  
  GPUImageLuminosity *luminosity = [[GPUImageLuminosity alloc] init];
  [luminanceFilter addTarget:luminosity];
  
  [luminosity setLuminosityProcessingFinishedBlock:^(CGFloat luminosity, CMTime frameTime) {
    if (luminosity > 0.03) {
      if (!self.lastSignal) {
        NSLog(@"YES");
      }
      self.lastSignal = YES;
      [self.receiveModel signalCalculated:YES];
    } else {
      if (self.lastSignal) {
        NSLog(@"NO");
      }
      self.lastSignal = NO;
      [self.receiveModel signalCalculated:NO];
    }
  }];
}

- (void)_disableFilters {
  [self.videoCamera removeAllTargets];
  GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:self.zoomRect];
  
  [self.videoCamera addTarget:cropFilter];
  [cropFilter addTarget:self.filteredVideoView];
  [self.videoCamera addTarget:self.rawVideoView];
}

- (IBAction)filterButtonPressed:(UIButton *)sender {
  if (sender.isSelected) {
    sender.selected = NO;
    [sender setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.4]];
    [self _disableFilters];
  } else {
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [self _enableFilters];
  }
}

- (IBAction)startButtonPressed:(UIButton *)sender {
  if (sender.isSelected) {
    sender.selected = NO;
    [sender setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.4]];
    self.receiveModel.enabled = NO;
  } else {
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    self.receiveModel.enabled = YES;
  }
}


- (IBAction)filterSwitchChanged:(UISwitch *)sender {
  if (sender.on) {
    [self _enableFilters];
  } else {
    [self _disableFilters];
  }
}

#pragma mark WKFlashReceiveModelDelegate

- (void)didReceiveMessage:(NSString *)message {
  self.messageTextView.hidden = NO;
  self.messageTextView.text = message;
}

@end
