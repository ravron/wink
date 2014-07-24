//
//  WKDataViewController.m
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKDataViewController.h"

#import "WKFlashTransmitModel.h"

@interface WKDataViewController ()
@property (strong, nonatomic) WKFlashTransmitModel *flashModel;
@end

@implementation WKDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.dataLabel.text = [self.dataObject description];
  
  self.flashModel = [[WKFlashTransmitModel alloc] init];
  
  [self.flashModel enqueueMessage:@"a" mode:WKFlashTransmitModelModeSerial];
  [self.flashModel transmitEnqueuedMessage];
}

@end
