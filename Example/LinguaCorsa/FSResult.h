//
//  FSResult.h
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FSRequest;
@interface FSResult : NSObject
@property (nonatomic, strong) FSRequest *request;
@property (nonatomic, copy) NSArray *words; //<FSWordDefinition>
@end
