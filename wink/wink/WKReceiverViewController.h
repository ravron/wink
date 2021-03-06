//
//  WKReceiverViewController.h
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKDataViewController.h"
#import "WKFlashReceiveModel.h"

@interface WKReceiverViewController : WKDataViewController <WKFlashReceiveModelDelegate>
+ (CMTime)configureCameraForHighestFrameRate:(AVCaptureDevice *)device;
- (IBAction)filterSwitchChanged:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;

@end
