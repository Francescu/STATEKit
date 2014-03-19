//
//  FSState.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSState.h"
#import "FSStateManager.h"

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

- (FSState *(^)(FSStateManager *manager, NSString *functionName))call
{
    return ^(FSStateManager *manager, NSString *functionName)
    {
        FSFunctionBlock function = self.functions[functionName];

        if (!function)
        {
            if (self.parent)
            {
                self.parent.call(manager, functionName);
            }
            else
            {
                //fail ?
            }
        }
        else
        {
            function(manager);
        }
        
        return self;
    };
}

- (BOOL (^)(NSString *functionName))respondsToCall
{
    return ^(NSString *functionName){return (BOOL)(self.functions[functionName] != nil);};
}


+ (instancetype)stateWithIdentifier:(NSString *)identifier parent:(FSState *)parent
{
    FSState *state = [[FSState alloc] init];
    state.identifier = identifier;
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


@end
