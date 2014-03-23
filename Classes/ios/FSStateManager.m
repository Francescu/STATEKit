//
//  FSStateManager.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSStateManager.h"
#import <objc/runtime.h>
#import "FSCallStack.h"

UNSTRING(enterFunction)
UNSTRING(exitFunction)

UNSTRING(textfieldWillEdit)
UNSTRING(textfieldWillReturn)
UNSTRING(textfieldWillChangeText)

UNSTRING(kSTkTextFieldParamsKeyRange)
UNSTRING(kSTkTextFieldParamsKeyReplacementString)

UNSTRING(kSTkSPECIAL_KEYWORD_TRANSITION_FUNC_NAME)

@implementation UITextField (STATEKit)

static char stk_params_key;

- (void)setLastParams:(NSDictionary *)params forEvent:(NSString* const)eventName
{
    NSDictionary *globalParams = [self getLastParams];
    if (globalParams == nil)
    {
        globalParams = @{};
    }
    
    NSMutableDictionary *mutableParams = [globalParams mutableCopy];
    mutableParams[eventName] = params;
    
    objc_setAssociatedObject(self, &stk_params_key, mutableParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)getLastParams
{
    return objc_getAssociatedObject(self, &stk_params_key);
}

- (NSDictionary *(^)(NSString* const eventName))last
{
    return ^(NSString* const eventName)
    {
        return [self getLastParams][eventName];
    };
}

@end
@interface FSStateManager ()

//Retain elements
@property (nonatomic, strong) id currentElement;
@property (nonatomic, strong) NSMutableSet *elements;
@property (nonatomic, strong) FSCallStack *stack;

@end

@implementation FSStateManager


#pragma mark - Setup
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.elements = [NSMutableSet set];
        self.stack = FSCallStack.new;
    }
    return self;
}

- (FSStateManager *(^)(NSDictionary *setup))setup
{
    return ^(NSDictionary *setup)
    {
        for (NSString *identifier in setup)
        {
            id obj = setup[identifier];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                self.add(identifier).setup(obj);
            }
        }
        
        return self;
    };
}

#pragma mark - Event Listeners

- (FSStateManager *(^)(id element))listen
{
    return ^(id element){
        
        self.currentElement = element;
        
        if ([self.elements containsObject:element])
        {
            return self;
        }
        
        //Retain
        [self.elements addObject:element];
        [self setForwards:@{} forElement:element];
        
        if ([element isKindOfClass:[UITextField class]])
        {
            self.listenTextField(element);
        }
        return self;
    };
}

- (FSStateManager *(^)(id element))mute
{
    return ^(id element){
        if (element)
        {
            self.currentElement = element;
            [self setForwards:@{} forElement:element];
        }
        
        return self;
    };
}

- (FSStateManager *(^)(NSString *eventName, NSString *functionName))forward
{
    return ^(NSString *eventName, NSString *functionName){

        id element = self.currentElement;
        if (element)
        {
            if (!functionName)
            {
                [self setForwardedCall:nil ForElement:element eventName:eventName];
            }
            else
            {
#if kSTkConfig_STATIC_FORWARDING
                FSState *currentState = self.stack.currentState;
                if (currentState)
                {
                    FSFunctionCall *call = currentState.functionCall(functionName);
                    if (call)
                    {
                        [self setForwardedCall:call ForElement:element eventName:eventName];
                        return self;
                    }
                }
#else
                FSFunctionCall *call = [[FSFunctionCall alloc] init];
                call.functionName = functionName;
                [self setForwardedCall:call ForElement:element eventName:eventName];
#endif
            }
        }
        return self;
    };
}

- (FSStateManager *(^)(NSString *eventName, NSString *path))forwardToTransition
{
    return ^(NSString *eventName, NSString *path)
    {
        id element = self.currentElement;
        if (element && path)
        {
            FSFunctionCall *call = [[FSFunctionCall alloc] init];
            call.state = self.stack.currentState;
            call.functionName = kSTkSPECIAL_KEYWORD_TRANSITION_FUNC_NAME;
            
            __weak __typeof__(self) weakSelf = self;
            
            call.functionBlock = ^BOOL()
            {
                __typeof__(weakSelf) strongSelf = weakSelf;
                strongSelf.transitionTo([path copy]);
                return YES;
            };
            
            [self setForwardedCall:call ForElement:element eventName:eventName];
        }
        return self;
    };
}

- (FSStateManager *(^)(NSString *eventName))unforward
{
    return ^(NSString *eventName){
        return self.forward(eventName, nil);
    };
}

- (FSStateManager *(^)(UITextField *textfield))listenTextField
{
    return ^(UITextField *textfield){
        
        if (textfield.delegate)
        {
            STkL(@"WARNING: Delegate was set");
        }
        
        [textfield setDelegate:self];
        
        return self;
    };
}

#pragma mark Listener Helpers


static char forwards_key;
- (NSDictionary *)forwardsForElement:(id)element
{
    return objc_getAssociatedObject(element, &forwards_key);
}


- (void)setForwards:(NSDictionary *)forwards forElement:(id)element
{
    objc_setAssociatedObject(element, &forwards_key, forwards, OBJC_ASSOCIATION_COPY);
}

- (FSFunctionCall *)forwardedCallForElement:(id)element eventName:(NSString *)eventName
{
    NSDictionary *forwards = [self forwardsForElement:element];
    if (forwards)
    {
        return forwards[eventName];
    }
    return nil;
}

- (void)setForwardedCall:(FSFunctionCall *)forwardedCall ForElement:(id)element eventName:(NSString *)eventName
{
    NSDictionary *forwards = [self forwardsForElement:element];
    NSMutableDictionary *mutableForwards = [forwards mutableCopy];
    if (forwardedCall)
    {
        mutableForwards[eventName] = forwardedCall;
    }
    else
    {
        [mutableForwards removeObjectForKey:eventName];
    }
    
    [self setForwards:mutableForwards forElement:element];
}

#pragma mark - States Changes

- (FSStateManager *(^)(NSString *identifier))transitionTo
{
    return ^(NSString *identifier)
    {
        FSState *previousState = self.currentState;
        NSMutableArray *previousPath = [[NSMutableArray alloc] initWithArray:previousState.path];
        
        FSState *nextState = self.globalState(identifier);
        NSMutableArray *nextPath = [[NSMutableArray alloc] initWithArray:nextState.path];
        
        BOOL stop = NO;
        while ([previousPath count] > 0 && [nextPath count] > 0 && !stop)
        {
            if ([previousPath firstObject] == [nextPath firstObject])
            {
                [previousPath removeObjectAtIndex:0];
                [nextPath removeObjectAtIndex:0];
            }
            else
            {
                stop = YES;
            }
        }
        
        for (FSState *state in [previousPath reverseObjectEnumerator])
        {
            FSFunctionBlock block = state.functions[exitFunction];
            if (block)
            {
                FSFunctionCall *func = [[FSFunctionCall alloc] init];
                func.functionBlock = block;
                func.state = state;
                func.functionName = exitFunction;
                
                [self doFunctionCall:func];
            }
        }
        
        for (FSState *state in nextPath)
        {
            FSFunctionBlock block = state.functions[enterFunction];
            if (block)
            {
                FSFunctionCall *func = [[FSFunctionCall alloc] init];
                func.functionBlock = block;
                func.state = state;
                func.functionName = enterFunction;
                
                [self doFunctionCall:func];
            }
        }
        
        
        _currentState = nextState;
        return self;
    };
}

- (FSState *(^)(NSString *path))globalState
{
    return ^(NSString *path)
    {
        NSArray *states = [path componentsSeparatedByString:kSTkConfig_STATE_DELIMITER];
        
        FSState *state = nil;
        
        for (NSString *identifier in states)
        {
            if (!state)
            {
                state = self.state(identifier);
            }
            else
            {
                state = state.state(identifier);
            }
            
            if (state == nil)
            {
                return state;
            }
            
        }
        
        return state;
    };
}
#pragma mark - Call functions

- (FSStateManager *(^)(NSString *functionName))call
{
    return ^(NSString *functionName)
    {
        if (self.currentState)
        {
            FSFunctionCall *func = self.currentState.functionCall(functionName);
            [self doFunctionCall:func];
        }
        
        return self;
    };
}

- (BOOL)doFunctionCall:(FSFunctionCall *)func
{
    BOOL value = 3;
    
    if (func)
    {
        [self.stack pushCall:func];
        value = func.functionBlock();
        [self.stack pop];
    }
    
    return value;
}

- (BOOL (^)(NSString *eventName, id element, BOOL defaultValue))event
{
    return ^(NSString *eventName, id element, BOOL defaultValue)
    {
        FSFunctionCall *call = [self forwardedCallForElement:element eventName:eventName];
        if (call)
        {
#if kSTkConfig_STATIC_FORWARDING
            BOOL returnValue = [self doFunctionCall:call];
            if (returnValue == YES || returnValue == NO)
            {
                return returnValue;
            }
#else
            if ([call.functionName isEqualToString:kSTkSPECIAL_KEYWORD_TRANSITION_FUNC_NAME])
            {
                return [self doFunctionCall:call];
            }
            
            if (self.currentState)
            {
                FSFunctionCall *func = self.currentState.functionCall(call.functionName);
                BOOL returnValue = [self doFunctionCall:func];
                if (returnValue == YES || returnValue == NO)
                {
                    return returnValue;
                }
            }
#endif
        }
        return defaultValue;
    };
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.event(textfieldWillEdit, textField, YES);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return self.event(textfieldWillReturn, textField, YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (string)
    {
        params[kSTkTextFieldParamsKeyReplacementString] = string;
    }
    params[kSTkTextFieldParamsKeyRange] = [NSValue valueWithRange:range];
    
    [textField setLastParams:params forEvent:textfieldWillChangeText];
    return self.event(textfieldWillChangeText, textField, YES);
}
@end
