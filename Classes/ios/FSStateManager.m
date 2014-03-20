//
//  FSStateManager.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSStateManager.h"
#import <objc/runtime.h>


UNSTRING(enterFunction)
UNSTRING(exitFunction)

UNSTRING(textfieldWillEdit)
UNSTRING(textfieldWillReturn)

@interface FSStateManager ()

//Retain elements
@property (nonatomic, strong) id currentElement;
@property (nonatomic, strong) NSMutableSet *elements;
@end

@implementation FSStateManager

static char associate_key;
- (NSDictionary *)forwardsForElement:(id)element
{
    return objc_getAssociatedObject(element, &associate_key);
}


- (void)setForwards:(NSDictionary *)forwards forElement:(id)element
{
    objc_setAssociatedObject(element, &associate_key, forwards, OBJC_ASSOCIATION_COPY);
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.elements = [NSMutableSet set];
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

- (FSStateManager *(^)(id element))listen
{
    return ^(id element){
        
        self.currentElement = element;
        
        if ([self.elements containsObject:element])
        {
            return self;
        }
        
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
            NSDictionary *forwards = [self forwardsForElement:element];
            NSMutableDictionary *mutableForwards = [forwards mutableCopy];
            mutableForwards[eventName] = functionName;
            
            [self setForwards:mutableForwards forElement:element];
        }
        
        return self;
    };
}

- (FSStateManager *(^)(NSString *eventName))unforward
{
    return ^(NSString *eventName){
        id element = self.currentElement;
        if (element)
        {
            NSDictionary *forwards = [self forwardsForElement:element];
            
            if (forwards[eventName])
            {
                NSMutableDictionary *mutableForwards = [forwards mutableCopy];
                [mutableForwards removeObjectForKey:eventName];
                
                [self setForwards:mutableForwards forElement:element];
            }
        }
        
        return self;
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

- (FSStateManager *(^)(NSString *identifier))transitionTo
{
    return ^(NSString *identifier)
    {
        if (self.currentState)
        {
            self.currentState.call(exitFunction);
        }
        _currentState = self.state(identifier).call(enterFunction);
        
        return self;
    };
}

- (FSStateManager *(^)(NSString *functionName))call
{
    return ^(NSString *functionName)
    {
        if (self.currentState)
        {
            self.currentState.call(functionName);
        }
        
        return self;
    };
}

- (BOOL (^)(NSString *eventName, id element, BOOL defaultValue))event
{
    return ^(NSString *eventName, id element, BOOL defaultValue)
    {
        if (self.currentState)
        {
            NSDictionary *forwards = [self forwardsForElement:element];
            if (forwards)
            {
                NSString *function = forwards[eventName];
                if (function)
                {
                    return self.currentState.event(function, defaultValue);
                }
            }
        }
        
        return defaultValue;
    };
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.event(textfieldWillEdit, textField, YES);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return self.event(textfieldWillReturn, textField, YES);
}
@end
