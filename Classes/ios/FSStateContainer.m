//
//  FSStateContainer.m
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSStateContainer.h"
#import "FSState.h"

@interface FSStateContainer ()

@end
@implementation FSStateContainer

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.children = @{};
    }
    return self;
}


- (FSState *(^)(NSString *identifier))add
{
    return ^(NSString *identifier)
    {
        FSState *parent = ([self isKindOfClass:[FSState class]]) ? (FSState *)self : nil;
            
        FSState *state = [FSState stateWithIdentifier:identifier parent:parent];
        NSMutableDictionary *states = [self.children mutableCopy];
        states[identifier] = state;
        self.children = states;
        return state;
    };
}

- (FSState *(^)(NSString *identifier))state
{
    return ^(NSString *identifier)
    {
        if (!self.children[identifier])
        {
            STkL(@"WARNING : Failed to find state '%@' from '%@' !",identifier, self.description);
        }
        
        return self.children[identifier];
    };
}

@end
