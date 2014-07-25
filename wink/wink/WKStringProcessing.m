//
//  WKStringCompression.m
//  wink
//
//  Created by Riley Avron on 7/25/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import "WKStringProcessing.h"
#include "smaz.h"

@implementation WKStringProcessing

- (NSArray *)compressAndSerializeMessage:(NSString *)message {
  return [self serializeData:[self compressMessage:message]];
}

// this is not an opposite of the above function; this one expects data with no start/stop bits
- (NSString *)deserializeAndDecompressData:(NSArray *)data {
  return [self decompressMessage:[self deserializeData:data]];
}

- (NSData *)compressMessage:(NSString *)message {
  char *cMessage = (char *)[message cStringUsingEncoding:NSUTF8StringEncoding];
  int cLength = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  
  char *compressed = malloc(sizeof(char) * (cLength * 8));
  
  int compressedLength = smaz_compress(cMessage, cLength, compressed, cLength * 8);
  
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

- (NSArray *)serializeData:(NSData *)messageData {
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[messageData length] * 10];
  const char *bytes = messageData.bytes;
  
  for (NSInteger i = 0; i < messageData.length; i++) {
    [arr addObject:[NSNumber numberWithBool:NO]];
    
    unsigned char c = bytes[i];
    for (unsigned char mask = 1; mask > 0; mask = mask << 1) {
      unsigned char bit = c & mask;
      [arr addObject:[NSNumber numberWithBool:(bit ? YES : NO)]];
    }
    
    [arr addObject:[NSNumber numberWithBool:YES]];
  }
  return [arr copy];
}

// takes in NSNumber char data, no start/stop bits
- (NSData *)deserializeData:(NSArray *)serialData {
  unsigned char c = 0;
  char *buff = malloc(sizeof(char) * (serialData.count / 8));
  
  for (NSInteger i = 0; i < serialData.count; i += 8) {
    c = 0;
    for (NSInteger j = 0; j < 8; j++) {
      NSNumber *bit = serialData[i + j];
      unsigned char mask = [bit boolValue] ? 128 : 0;
      c |= mask;
      if (j < 7) {
        c = c >> 1;
      }
    }
    buff[i / 8] = c;
  }
  
  NSData *data = [[NSData alloc] initWithBytes:buff length:(serialData.count / 8)];
  free(buff);
  return data;
}

@end
