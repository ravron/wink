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
@end

@implementation WKReceiverViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionBack];
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

  [self.videoCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];

  GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
  filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self.view addSubview:filteredVideoView];

  GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];

  GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
  exposureFilter.exposure = 0;

  GPUImageLuminanceThresholdFilter *luminanceFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
  luminanceFilter.threshold = 0.8;

//  GPUImageAdaptiveThresholdFilter *luminanceFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];

  [self.videoCamera addTarget:grayscaleFilter];
  [grayscaleFilter addTarget:exposureFilter];
  [exposureFilter addTarget:luminanceFilter];
  [luminanceFilter addTarget:filteredVideoView];
//  [grayscaleFilter addTarget:exposureFilter];
//  [exposureFilter addTarget:filteredVideoView];

//  [self.videoCamera addTarget:self.filter];
//  [self.filter addTarget:filteredVideoView];
  [self.videoCamera startCameraCapture];
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

@end
