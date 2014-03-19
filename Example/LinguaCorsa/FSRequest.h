//
//  FSRequest.h
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, FSRequestLanguage)
{
    FSRequestLanguageCorsican = 0,
    FSRequestLanguageFrench = 1
};

typedef NS_ENUM(int, FSRequestSearchMode)
{
    FSRequestSearchOptionEqualsTo = 1,
    FSRequestSearchOptionBeginsWith = 2,
    FSRequestSearchOptionContains = 3,
    FSRequestSearchOptionEndsWith = 4
};

@interface FSRequest : NSObject
@property (nonatomic, assign) FSRequestLanguage searchLanguage;
@property (nonatomic, assign) FSRequestSearchMode searchMode;
@property (nonatomic, copy) NSString *request;

- (NSURL *)requestURL;
@end
