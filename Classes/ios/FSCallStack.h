//
//  FSCallStack.h
//  STATEKit
//
//  Created by Francescu SANTONI on 20/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFunctionCall.h"
@class FSState;
@interface FSCallStack : NSObject

- (FSFunctionCall *)currentCall;
- (FSState *)currentState;
- (NSString *)currentFunctionName;

- (void)pushCall:(FSFunctionCall *)call;
- (void)pop;
@end
