//
//  WKFlashReceiveModelTest.m
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WKFlashReceiveModel.h"
#import "WKStringProcessing.h"

@interface WKFlashReceiveModel (Test)
@property (readonly, nonatomic) NSInteger samplesPerBit;
@end

@interface WKFlashReceiveModelTest : XCTestCase
@property (strong, nonatomic) WKFlashReceiveModel *model;
@property (strong, nonatomic) WKStringProcessing *processor;
@end

@implementation WKFlashReceiveModelTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.model = [[WKFlashReceiveModel alloc] init];
  self.processor = [[WKStringProcessing alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSignalCalc
{
  self.model.enabled = YES;
  NSString *testString = @"ABCdef";
  // serial data for "A"
  NSArray *data = [self.processor compressAndSerializeMessage:testString];
  for (NSNumber *bit in data) {
    for (NSInteger i = 0; i < self.model.samplesPerBit; i++) {
      [self.model signalCalculated:![bit boolValue]];
    }
  }
  self.model.enabled = NO;
  XCTAssert([self.model.currentMessage isEqualToString:testString], @"Failed to calculate correct string");
}

@end
