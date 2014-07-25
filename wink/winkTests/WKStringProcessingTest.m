//
//  WKStringCompressionTest.m
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WKStringProcessing.h"

@interface WKStringProcessingTest : XCTestCase
@property (strong, nonatomic) WKStringProcessing *compressor;
@end

@implementation WKStringProcessingTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.compressor = [[WKStringProcessing alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCompress {
  NSString *message = @"hello there";
  NSData *compressed = [self.compressor compressMessage:message];
  NSString *decompressed = [self.compressor decompressMessage:compressed];
  XCTAssert([message isEqualToString:decompressed], @"Messages not equal: '%@' '%@'", message, decompressed);
}

- (void)testSerializeData {
  NSData *data = [[NSData alloc] initWithBytes:"A" length:1];
  NSArray *serialData = [self.compressor serializeData:data];
  
  // serial data for "A"
  NSArray *expectedData = @[
                            @(NO), @(YES), @(NO), @(NO), @(NO), @(NO), @(NO), @(YES), @(NO), @(YES),
                            ];
  XCTAssert([serialData isEqualToArray:expectedData], @"Serial data does not match expected data");
}

- (void)testDeserializeData {
  NSArray *serialData = @[
                          @(YES), @(NO), @(NO), @(NO), @(NO), @(NO), @(YES), @(NO)
                          ];
  NSData *data = [self.compressor deserializeData:serialData];
  NSData *expectedData = [[NSData alloc] initWithBytes:"A" length:1];
  XCTAssert([expectedData isEqualToData:data], @"Expected data does not match received data");
}

@end
