//
//  WKFlashReceiveModelTest.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WKFlashReceiveModel.h"

@interface WKFlashReceiveModelTest : XCTestCase
@property (strong, nonatomic) WKFlashReceiveModel *model;
@end

@implementation WKFlashReceiveModelTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.model = [[WKFlashReceiveModel alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSignalCalc
{
  self.model.enabled = YES;
  NSArray *data = @[
                    @(YES), @(NO), @(YES), @(YES), @(YES), @(YES), @(YES), @(NO), @(YES), @(NO),
                    ];
  for (NSNumber *bit in data) {
    [self.model signalCalculated:[bit boolValue]];
    [self.model signalCalculated:[bit boolValue]];
  }
  XCTAssert([self.model.currentMessage isEqualToString:@"A"], @"Not equal to A!");
}

@end
