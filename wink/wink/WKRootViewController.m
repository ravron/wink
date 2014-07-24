//
//  WKRootViewController.m
//  wink
//
//  Created by Sabrina Ren on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKRootViewController.h"

#import "WKModelController.h"

#import "WKDataViewController.h"

@interface WKRootViewController ()
@property (readonly, strong, nonatomic) WKModelController *modelController;
@end

@implementation WKRootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  // Configure the page view controller and add it as a child view controller.
  self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  self.pageViewController.delegate = self;

  WKDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
  NSArray *viewControllers = @[startingViewController];
  [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

  self.pageViewController.dataSource = self.modelController;

  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];

  // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
  CGRect pageViewRect = self.view.bounds;
  self.pageViewController.view.frame = pageViewRect;

  [self.pageViewController didMoveToParentViewController:self];

  // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
  self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (WKModelController *)modelController
{
  // Return the model controller object, creating it if necessary.
  // In more complex implementations, the model controller may be passed to the view controller.
  if (!_modelController) {
    _modelController = [[WKModelController alloc] init];
  }
  return _modelController;
}

#pragma mark - UIPageViewController delegate methods

 - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
 {
   UIViewController *currentController = self.pageViewController.viewControllers[0];
   NSArray *viewControllers = @[currentController];
   [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
   self.pageViewController.doubleSided = NO;
 }

@end
