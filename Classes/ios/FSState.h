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

typedef BOOL (^FSFunctionBlock)();
//typedef BOOL (^FSFunctionListenerBlock)(FSStateManager *manager, id context);

@interface FSState : FSStateContainer

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *globalIdentifier;

@property (nonatomic, copy) NSDictionary *functions;

@property (nonatomic, weak) FSState *parent;

- (FSState *(^)(NSString *functionName))call;
- (BOOL (^)(NSString *functionName, BOOL defaultValue))event;

- (FSState *(^)(NSDictionary *setup))setup;

- (FSState *(^)(NSString *identifier, FSFunctionBlock function))addFunction;
- (BOOL (^)(NSString *functionName))respondsToCall;

+ (instancetype)stateWithIdentifier:(NSString *)identifier parent:(FSState *)parent;

- (BOOL (^)(FSState *state))isDescendantOf;
- (BOOL (^)(FSState *state))isAncestorOf;

- (id (^)(NSString *functionName))function;
@end
