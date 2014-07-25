//
//  WKFlashReceiveModel.h
//  wink
//
//  Created by Riley Avron on 7/24/14.
//  Copyright (c) 2014 wink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WKFlashTransmitModel.h"
#import <AVFoundation/AVFoundation.h>

@protocol WKFlashReceiveModelDelegate <NSObject>
- (void)didReceiveMessage:(NSString *)message;
@end

@interface WKFlashReceiveModel : NSObject

@property (assign, nonatomic, getter = isEnabled) BOOL enabled;
@property (readonly, nonatomic) NSString *currentMessage;
@property (weak, nonatomic) id<WKFlashReceiveModelDelegate> delegate;

- (void)signalCalculated:(BOOL)on;

@end
