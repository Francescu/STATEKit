//
//  FSFunctionCall.h
//  STATEKit
//
//  Created by Francescu SANTONI on 20/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STATEKitConstants.h"
@class FSState;

@interface FSFunctionCall : NSObject
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, strong) FSFunctionBlock functionBlock;
@property (nonatomic, strong) FSState *state;
@end