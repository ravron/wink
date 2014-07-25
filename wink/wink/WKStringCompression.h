//
//  WKStringCompression.h
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKStringCompression : NSObject

- (NSData *)compressMessage:(NSString *)message;
- (NSString *)decompressMessage:(NSData *)compressed;

@end
