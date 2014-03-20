//
//  FSState.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSState.h"
#import "FSStateManager.h"
#import "FSFunctionCall.h"

@interface FSState ()
@end

@implementation FSState

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.children = @{};
        self.functions = @{};
    }
    return self;
}

- (FSFunctionCall* (^)(NSString *functionName))functionCall
{
    return ^(NSString *functionName)
    {
        id function = self.functions[functionName];
        
        FSFunctionCall *functionCall = nil;
        
        if (!function)
        {
            if (self.parent)
            {
                return self.parent.functionCall(functionName);
            }
            else
            {
                STkL(@"WARNING : No function '%@'!",functionName);
                return functionCall;
            }
        }
        functionCall = [[FSFunctionCall alloc] init];
        
        functionCall.functionName = functionName;
        functionCall.functionBlock = function;
        functionCall.state = self;
        
        return functionCall;
        
    };
}

- (BOOL (^)(NSString *functionName))respondsToCall
{
    return ^(NSString *functionName){return (BOOL)(self.functions[functionName] != nil);};
}


+ (instancetype)stateWithIdentifier:(NSString *)identifier parent:(FSState *)parent
{
    FSState *state = [[FSState alloc] init];
    state->_identifier = identifier;
    state.parent = parent;
    return state;
}

- (FSState *(^)(NSDictionary *setup))setup
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
            else
            {
                //We trust inputs for now
                self.addFunction(identifier, obj);
            }
        }
        return self;
    };
}

- (FSState *(^)(NSString *identifier, FSFunctionBlock function))addFunction
{
    return ^(NSString *identifier, FSFunctionBlock function)
    {
        // put a lock here
        NSMutableDictionary *functionsTemps = [self.functions mutableCopy];
        functionsTemps[identifier] = function;
        self.functions = functionsTemps;
        return self;
    };
}

- (NSString *)globalIdentifier
{
    if (self.parent)
    {
        return [NSString stringWithFormat:@"%@.%@",self.parent.globalIdentifier,self.identifier];
    }
    return self.identifier;
}

- (BOOL (^)(FSState *state))isDescendantOf
{
    return ^(FSState *state){
        
        if (self.parent)
        {
            if (self.parent == state)
            {
                return YES;
            }
            else
            {
                return  self.parent.isDescendantOf(state);
            }
        }
        
        return NO;
    };

}

- (BOOL (^)(FSState *state))isAncestorOf
{
    return ^(FSState *state){
        return state.isDescendantOf(self);
    };
}
@end
