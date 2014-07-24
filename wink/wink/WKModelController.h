//
//  WKModelController.h
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKDataViewController;

@interface WKModelController : NSObject <UIPageViewControllerDataSource>

- (WKDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;

@end
