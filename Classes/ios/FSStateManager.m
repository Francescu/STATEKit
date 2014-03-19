//
//  FSStateManager.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSStateManager.h"

NSString* const enterFunction = @"enter";
NSString* const exitFunction = @"exit";

@interface FSStateManager ()

@end
@implementation FSStateManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
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

- (FSStateManager *(^)(NSString *identifier))transitionTo
{
    return ^(NSString *identifier)
    {
        if (self.currentState)
        {
            self.currentState.call(self, exitFunction);
        }
        _currentState = self.state(identifier).call(self, enterFunction);
        
        return self;
    };
}

- (FSStateManager *(^)(NSString *functionName))call
{
    return ^(NSString *functionName)
    {
        if (self.currentState)
        {
            self.currentState.call(self, functionName);
        }
        
        return self;
    };
}


@end
