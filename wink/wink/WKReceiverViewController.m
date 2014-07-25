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
@property (strong, nonatomic) GPUImageView *filteredVideoView;
@end

@implementation WKReceiverViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  

  self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

//  [self.videoCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];

  self.filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
  self.filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self.view addSubview:self.filteredVideoView];
  [self.view sendSubviewToBack:self.filteredVideoView];

  GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];

  GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
  exposureFilter.exposure = 0;

  GPUImageLuminanceThresholdFilter *luminanceFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
  luminanceFilter.threshold = .95;
  
  GPUImageHighPassFilter *highPassFilter = [[GPUImageHighPassFilter alloc] init];
  highPassFilter.filterStrength = 0.5;

  
  AVCaptureConnection *captureConnection = [self.videoCamera videoCaptureConnection];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  captureConnection.videoMinFrameDuration = CMTimeMake(1, 60);
  captureConnection.videoMaxFrameDuration = CMTimeMake(1, 60);
#pragma clang diagnostic pop
  

  
//  AVCaptureDevice *captureDevice = self.videoCamera.inputCamera;
//  [captureDevice lockForConfiguration:nil];
//  captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 60);
//  captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 60);
//  [captureDevice unlockForConfiguration];

//  GPUImageAdaptiveThresholdFilter *luminanceFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];

//  [self.videoCamera addTarget:highPassFilter];
//  [highPassFilter addTarget:filteredVideoView];
//  [self.videoCamera addTarget:luminanceFilter];
//  [luminanceFilter addTarget:openingFilter];
//  [openingFilter addTarget:filteredVideoView];
//  [luminanceFilter addTarget:differenceBlend];
//  [openingFilter addTarget:differenceBlend];
//  [differenceBlend addTarget:filteredVideoView];

//  [self.videoCamera addTarget:self.filter];
//  [self.filter addTarget:filteredVideoView];
  [self.videoCamera startCameraCapture];
  [self _disableFilters];
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
  GPUImageLuminanceThresholdFilter *luminanceFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
  luminanceFilter.threshold = .95;
  
  GPUImageOpeningFilter *openingFilter = [[GPUImageOpeningFilter alloc] initWithRadius:4];
  
  GPUImageDifferenceBlendFilter *differenceBlend = [[GPUImageDifferenceBlendFilter alloc] init];
  
  [self.videoCamera addTarget:luminanceFilter];
  [luminanceFilter addTarget:openingFilter];
  [openingFilter addTarget:self.filteredVideoView];
  
//  [luminanceFilter addTarget:differenceBlend];
//  [openingFilter addTarget:differenceBlend];
//  [differenceBlend addTarget:filteredVideoView];
}

- (void)_disableFilters {
  [self.videoCamera removeAllTargets];
  [self.videoCamera addTarget:self.filteredVideoView];
}

- (IBAction)filterSwitchChanged:(UISwitch *)sender {
  if (sender.on) {
    [self _enableFilters];
  } else {
    [self _disableFilters];
  }
}
@end
