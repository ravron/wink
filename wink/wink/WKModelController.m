//
//  WKModelController.m
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKModelController.h"

#import "WKDataViewController.h"
#import "WKEncoderViewController.h"
#import "WKReceiverViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface WKModelController()
@property (strong, nonatomic) WKEncoderViewController *encoderViewController;
@property (strong, nonatomic) WKReceiverViewController *receiverViewController;
@property (strong, nonatomic) NSArray *pageData;
@end

@implementation WKModelController

- (id)init
{
  self = [super init];
  if (self) {
    // Create the data model.
    _pageData = [NSArray arrayWithObjects:[NSNumber numberWithInt:MKPageReceiver], [NSNumber numberWithInt:MKPageEncoder], nil];
  }
  return self;
}

- (WKDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
  // Return the data view controller for the given index.
  if ((self.pageData.count == 0) || (index >= self.pageData.count)) {
    return nil;
  }

  if ((MKPageType)index == MKPageEncoder) {
    return [self encoderViewControllerInStoryboard:storyboard];
  }
  return [self receiverViewControllerInStoryboard:storyboard];
}

- (WKEncoderViewController *)encoderViewControllerInStoryboard:(UIStoryboard *)storyboard {
  if (!_encoderViewController) {
    _encoderViewController = [storyboard instantiateViewControllerWithIdentifier:@"WKEncoderViewController"];
    _encoderViewController.pageType = MKPageEncoder;
  }
  return _encoderViewController;
}

- (WKReceiverViewController *)receiverViewControllerInStoryboard:(UIStoryboard *)storyboard {
  if (!_receiverViewController) {
    _receiverViewController = [storyboard instantiateViewControllerWithIdentifier:@"WKReceiverViewController"];
    _receiverViewController.pageType = MKPageReceiver;
  }
  return _receiverViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSUInteger index = ((WKDataViewController *)viewController).pageType;
  if ((index == 0) || (index == NSNotFound)) {
    return nil;
  }

  index--;
  return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSUInteger index = ((WKDataViewController *)viewController).pageType;
  if (index == NSNotFound) {
    return nil;
  }

  index++;
  if (index == [self.pageData count]) {
    return nil;
  }
  return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
