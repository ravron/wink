//
//  WKStringCompression.h
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKStringProcessing : NSObject

- (NSArray *)compressAndSerializeMessage:(NSString *)message;
- (NSString *)deserializeAndDecompressData:(NSArray *)data;

- (NSData *)compressMessage:(NSString *)message;
- (NSString *)decompressMessage:(NSData *)compressed;
- (NSArray *)serializeData:(NSData *)messageData;
- (NSData *)deserializeData:(NSArray *)serialData;
@end
