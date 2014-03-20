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

#define UNSTRING(s) NSString* const s = @#s;
#define STkExtern(s) extern NSString* const s;

STkExtern(enterFunction)
STkExtern(exitFunction)

STkExtern(textfieldWillEdit)
STkExtern(textfieldWillReturn)

#ifdef DEBUG
#   define STkL(...) NSLog(__VA_ARGS__)
#else
#   define STkL(...)
#endif

@interface FSStateManager : FSStateContainer <UITextFieldDelegate>

@property (nonatomic, strong, readonly) FSState *currentState;

/* Public Use */

- (FSStateManager *(^)(NSString *identifier))transitionTo;

- (FSStateManager *(^)(NSString *functionName))call;

- (FSStateManager *(^)(NSDictionary *setup))setup;

- (FSStateManager *(^)(id element))listen;
- (FSStateManager *(^)(id element))mute;

- (FSStateManager *(^)(NSString *eventName, NSString *functionName))forward;
- (FSStateManager *(^)(NSString *eventName))unforward;

/* Internal Use */

- (FSStateManager *(^)(UITextField *textfield))listenTextField;
- (BOOL (^)(NSString *functionName, id context, BOOL defaultValue))event;

@end
