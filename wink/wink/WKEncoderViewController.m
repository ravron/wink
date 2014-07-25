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
@property (strong, nonatomic) UIScrollView *buttonScrollView;
@property (strong, nonatomic) UILabel *buttonLabel;
@property (strong, nonatomic) UILabel *encodedLabel;
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

  self.buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.transmitButton.frame.size.width, self.transmitButton.frame.size.height)];
  self.buttonLabel.text = @"TRANSMIT";
  self.buttonLabel.textAlignment = NSTextAlignmentCenter;
  self.buttonLabel.textColor = [UIColor whiteColor];
  self.buttonLabel.font = [UIFont systemFontOfSize:16.0];
  self.buttonLabel.lineBreakMode = NSLineBreakByClipping;

  [self.transmitButton addSubview:self.buttonLabel];
  
  self.encodedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.transmitButton.frame.size.width, 0, 6000, self.transmitButton.frame.size.height)];
  self.encodedLabel.layer.borderColor = [[UIColor greenColor] CGColor];
  self.encodedLabel.layer.borderWidth = 2.0f;
  self.encodedLabel.textAlignment = NSTextAlignmentLeft;
  self.encodedLabel.textColor = [UIColor whiteColor];
  self.encodedLabel.font = [UIFont systemFontOfSize:16.0];
  self.encodedLabel.lineBreakMode = NSLineBreakByClipping;
  self.encodedLabel.hidden = YES;
  [self.transmitButton addSubview:self.encodedLabel];
  
//  self.buttonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.transmitButton.frame.size.width, self.transmitButton.frame.size.height)];
//  self.buttonScrollView.userInteractionEnabled = NO;
//  [self.buttonScrollView addSubview:self.buttonLabel];
  
//  [self.transmitButton addSubview:self.buttonScrollView];
}
- (void)_scrollMessageToIndex:(NSUInteger)index {
  NSDictionary *attributes = @{
                               NSForegroundColorAttributeName: [UIColor greenColor],
                               NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                               };
  NSDictionary *regularAttributes = @{
                                      NSForegroundColorAttributeName: [UIColor whiteColor]};

//  [self.attributedMessageString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.attributedMessageString.length)];
//  [self.attributedMessageString addAttributes:attributes range:NSMakeRange(index / 10, 1)];
//  [self.attributedMessageString addAttributes:regularAttributes range:NSMakeRange(0, self.attributedMessageString.length)];

  CGSize textSize = [self.buttonLabel.text sizeWithAttributes:attributes];
  
  self.buttonScrollView.contentSize = CGSizeMake(500, self.buttonScrollView.frame.size.height);
//  [self.messageTextView setAttributedText:self.attributedMessageString];

  [self.buttonScrollView setContentOffset:CGPointMake(200 + index * 10, 0) animated:YES];

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
//  self.buttonLabel.text = @"\t   TRANSMITTING";
  [self.messageTextView resignFirstResponder];

  self.oneLineMessage = [self.messageTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

  [self.transmitModel enqueueMessage:self.oneLineMessage mode:WKFlashTransmitModelModeSerial];
  [self.transmitModel transmitEnqueuedMessage];
  
  NSDictionary *attributes = @{
                               NSForegroundColorAttributeName: [UIColor whiteColor],
                               NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                               };
  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[self.transmitModel messageStringSeparatedBySpaces:YES]];
  [attributedText setAttributes:attributes range:NSMakeRange(0, attributedText.length)];
  self.encodedLabel.attributedText = attributedText;
//  self.encodedLabel.text = self.transmitModel.logString;
//  NSString *buttonText = [NSString stringWithFormat:@"%@\t\t\t\t%@", self.buttonLabel.text, self.transmitModel.logString];

//  self.buttonLabel.text = buttonText;
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
    self.buttonLabel.frame = CGRectMake(-self.buttonLabel.frame.size.width, 0, self.buttonLabel.frame.size.width, self.buttonLabel.frame.size.height);
  } completion:^(BOOL finished) {
    [self _animateLogString];
  }];
}

- (void)_animateLogString {

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
      self.buttonLabel.text = @"TRANSMIT";
      
      self.buttonLabel.frame = CGRectMake(self.transmitButton.frame.size.width, 0, self.buttonLabel.frame.size.width, self.buttonLabel.frame.size.height);
      [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.buttonLabel.frame = CGRectMake(0, 0, self.buttonLabel.frame.size.width, self.buttonLabel.frame.size.height);
        self.encodedLabel.alpha = 0;
//        self.encodedLabel.frame = CGRectMake(-self.encodedLabel.frame.size.width, 0, self.encodedLabel.frame.size.width, self.encodedLabel.frame.size.height);
      } completion:^(BOOL finished) {
        self.encodedLabel.alpha = 1;
        self.encodedLabel.hidden = YES;
        self.encodedLabel.frame = CGRectMake(self.transmitButton.frame.size.width, 0, self.transmitButton.frame.size.width, self.transmitButton.frame.size.height);
      }];//      [self.buttonScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    NSLog(@"index %i", index);

    self.signalView.backgroundColor = on ? [UIColor greenColor] : [UIColor whiteColor];
    

    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 };
    NSDictionary *highlighted = @{
                                 NSForegroundColorAttributeName: [UIColor greenColor],
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 };
    NSMutableAttributedString *text = [self.encodedLabel.attributedText mutableCopy];
    [text removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, text.length)];
    [text addAttributes:highlighted range:NSMakeRange(index, 1)];
    
    self.encodedLabel.attributedText = text;
    
    [UIView animateWithDuration:0.1 animations:^{
      self.encodedLabel.hidden = NO;
      CGFloat xOffset = self.transmitButton.frame.size.width / 2;
      self.encodedLabel.frame = CGRectMake(xOffset - index * 10, 0, self.encodedLabel.frame.size.width, self.encodedLabel.frame.size.height);
    }];
    
  });
}

@end
