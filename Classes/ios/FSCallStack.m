//
//  FSCallStack.m
//  STATEKit
//
//  Created by Francescu SANTONI on 20/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSCallStack.h"

#import "FSState.h"
#import "FSStateManager.h"

@interface FSCallStack ()
@property (nonatomic, strong) NSMutableArray *stack;
@end

@implementation FSCallStack

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.stack = [[NSMutableArray alloc] init];
    }
    return self;
}
- (FSFunctionCall *)currentCall
{
    return [self.stack lastObject];
}

- (FSState *)currentState
{
    return self.currentCall.state;
}

- (NSString *)currentFunctionName
{
    return self.currentCall.functionName;
}

- (void)pushCall:(FSFunctionCall *)call
{
    [self.stack addObject:call];
}

- (void)pop
{
    if ([self.stack count] > 0)
    {
        [self.stack removeLastObject];
    }
    else
    {
        STkExceptionDebug(@"FSCallStackPopEmpty");
    }
}

@end
