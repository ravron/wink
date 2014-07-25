//
//  WKEncoderViewController.m
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKEncoderViewController.h"


@interface WKEncoderViewController ()
@property (strong, nonatomic) WKFlashTransmitModel *transmitModel;
@end

@implementation WKEncoderViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.messageTextView.delegate = self;
//  [self.messageTextView setContentInset:UIEdgeInsetsMake(10, 10, 10, 10)];
  
  self.doneButton.alpha  = 0.0;
  self.transmitButton.layer.cornerRadius = 3.0f;
  self.transmitButton.layer.borderColor = [UIColor whiteColor].CGColor;
  self.transmitButton.layer.borderWidth = 1.0f;
  
  self.transmitModel = [[WKFlashTransmitModel alloc] init];
  self.transmitModel.delegate = self;
}

#pragma mark - Private

- (void)_showDoneButton:(BOOL)show {
  [UIView animateWithDuration:0.3 animations:^{
    self.doneButton.alpha  = (show ? 1.0 : 0.0);
  }];
}

#pragma mark IBActions

- (IBAction)doneButtonTouched:(id)sender {
  [self.messageTextView resignFirstResponder];
}

- (IBAction)transmitButtonTouched:(id)sender {
  [self.messageTextView resignFirstResponder];
  
  [self.transmitModel enqueueMessage:self.messageTextView.text mode:WKFlashTransmitModelModeSerial];
  [self.transmitModel transmitEnqueuedMessage];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [self _showDoneButton:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self _showDoneButton:NO];
}

#pragma mark WKFlashTransmitModelDelegate

- (void)torchDidUpdate:(BOOL)on {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.signalView.backgroundColor = on ? [UIColor greenColor] : [UIColor whiteColor];
  });
}

@end
