//
//  WKStringCompressionTest.m
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WKStringCompression.h"

@interface WKStringCompressionTest : XCTestCase
@property (strong, nonatomic) WKStringCompression *compressor;
@end

@implementation WKStringCompressionTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.compressor = [[WKStringCompression alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCompress
{
  NSString *message = @"hello there";
  NSString *compressed = [self.compressor compressMessage:message];
  NSString *decompressed = [self.compressor decompressMessage:compressed];
  XCTAssert([message isEqualToString:decompressed], @"Messages not equal: '%@' '%@'", message, decompressed);
}

@end
