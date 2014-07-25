//
//  WKEncoderViewController.h
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKDataViewController.h"

#import "WKFlashTransmitModel.h"

@interface WKEncoderViewController : WKDataViewController <UITextViewDelegate, WKFlashTransmitModelDelegate>
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *transmitButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *signalView;

- (IBAction)doneButtonTouched:(id)sender;
- (IBAction)transmitButtonTouched:(id)sender;

@end
