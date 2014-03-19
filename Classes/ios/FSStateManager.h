//
//  FSStateManager.h
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStateContainer.h"
#import "FSState.h"

extern NSString* const enterFunction;
extern NSString* const exitFunction;

@interface FSStateManager : FSStateContainer

@property (nonatomic, strong, readonly) FSState *currentState;

- (FSStateManager *(^)(NSString *identifier))transitionTo;
- (FSStateManager *(^)(NSString *functionName))call;
- (FSStateManager *(^)(NSDictionary *setup))setup;
@end
