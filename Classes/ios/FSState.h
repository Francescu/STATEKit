//
//  FSState.h
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStateContainer.h"

@class FSStateManager;

typedef void (^FSFunctionBlock)(FSStateManager *manager);

@interface FSState : FSStateContainer

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSDictionary *functions;

@property (nonatomic, weak) FSState *parent;

- (FSState *(^)(FSStateManager *manager, NSString *functionName))call;
- (FSState *(^)(NSDictionary *setup))setup;

- (FSState *(^)(NSString *identifier, FSFunctionBlock function))addFunction;
- (BOOL (^)(NSString *functionName))respondsToCall;

+ (instancetype)stateWithIdentifier:(NSString *)identifier parent:(FSState *)parent;

@end
