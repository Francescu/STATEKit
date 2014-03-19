//
//  FSRequestManager.h
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSRequest.h"
#import "FSResult.h"

@interface FSRequestManager : NSObject
@property (nonatomic, strong, readonly) FSRequest *request;

- (instancetype)initWithRequest:(FSRequest *)request;
- (void)startRequestWithCompletion:(void (^)(FSResult* result, NSError *error))completion;

@end
