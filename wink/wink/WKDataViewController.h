//
//  WKDataViewController.h
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKPageType) {
  MKPageReceiver,
  MKPageEncoder
};

@interface WKDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) MKPageType pageType;

@end
