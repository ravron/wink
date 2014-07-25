//
//  WKStringCompression.m
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKStringCompression.h"
#include "smaz.h"

@implementation WKStringCompression

- (NSData *)compressMessage:(NSString *)message {
  char *cMessage = (char *)[message cStringUsingEncoding:NSUTF8StringEncoding];
  int cLength = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  
  char *compressed = malloc(sizeof(char) * (cLength + 1));
  
  int compressedLength = smaz_compress(cMessage, cLength, compressed, cLength);
  
  NSData *compressedData = [[NSData alloc] initWithBytes:compressed length:compressedLength];
  
  free(compressed);
  return compressedData;
}

- (NSString *)decompressMessage:(NSData *)compressed {
  char *compressedMessage = (char *)[compressed bytes];
  int compressedLength = [compressed length];
  
  char *message = malloc(sizeof(char) * (compressedLength * 8));
  
  int messageLength = smaz_decompress(compressedMessage, compressedLength, message, compressedLength * 8);
  
  NSString *messageString = [[NSString alloc] initWithBytes:message length:messageLength encoding:NSUTF8StringEncoding];
  
  free(message);
  return messageString;
}

@end
