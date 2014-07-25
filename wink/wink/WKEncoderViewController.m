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
@property (strong, nonatomic) IBOutlet UITextView *messageStatusTextView;
@property (strong, nonatomic) UITextView *buttonTextView;
@property (strong, nonatomic) NSString *oneLineMessage;
@property (strong, nonatomic) NSMutableAttributedString *attributedMessageString;
@end

@implementation WKEncoderViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.messageTextView.delegate = self;

  self.doneButton.alpha  = 0.0;
  self.transmitButton.layer.cornerRadius = 4.f;
  self.transmitButton.layer.borderColor = [UIColor whiteColor].CGColor;
  self.transmitButton.layer.borderWidth = 1.0f;

  self.transmitModel = [[WKFlashTransmitModel alloc] init];
  self.transmitModel.delegate = self;
  
  self.buttonTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.transmitButton.frame.size.width, self.transmitButton.frame.size.height)];
  self.buttonTextView.text = @"TRANSMIT";
  self.buttonTextView.textAlignment = NSTextAlignmentCenter;
  self.buttonTextView.font = [UIFont systemFontOfSize:16.0];
  self.buttonTextView.backgroundColor = [UIColor clearColor];
  self.buttonTextView.textColor = [UIColor whiteColor];
  self.buttonTextView.editable = NO;
  self.buttonTextView.userInteractionEnabled = NO;
  [self.transmitButton addSubview:self.buttonTextView];
}

- (void)_displayBoldCharacterAtIndex:(NSUInteger)index {
  NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor greenColor]};

  [self.attributedMessageString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.attributedMessageString.length)];
  [self.attributedMessageString addAttributes:attributes range:NSMakeRange(index / 10, 1)];
  [self.attributedMessageString addAttributes:attributes range:NSMakeRange(self.oneLineMessage.length + index, 1)];

  [self.messageTextView setAttributedText:self.attributedMessageString];
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

- (IBAction)transmitButtonTouched:(UIButton *)sender {
  self.buttonTextView.text = @"TRANSMITTING";
  [self.messageTextView resignFirstResponder];

  self.oneLineMessage = [self.messageTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

  [self.transmitModel enqueueMessage:self.oneLineMessage mode:WKFlashTransmitModelModeSerial];
  [self.transmitModel transmitEnqueuedMessage];
  
  self.attributedMessageString = [[NSMutableAttributedString alloc] initWithString:self.transmitModel.logString];
  [self _displayBoldCharacterAtIndex:0];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [self _showDoneButton:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self _showDoneButton:NO];
}

#pragma mark WKFlashTransmitModelDelegate

- (void)torchDidUpdate:(BOOL)on atIndex:(NSUInteger)index {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.transmitButton.selected = on;
    if (self.oneLineMessage.length * 10 - 1 == index) {
      self.buttonTextView.text = @"TRANSMIT";
    }
//    [self _displayBoldCharacterAtIndex:index];
    self.signalView.backgroundColor = on ? [UIColor greenColor] : [UIColor whiteColor];
  });
}

@end
