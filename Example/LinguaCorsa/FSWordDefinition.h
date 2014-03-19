//
//  FSWordDefinition.h
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface FSWordDefinition : NSObject
@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSString *translation;
@property (nonatomic, copy) NSString *definition;
@property (nonatomic, copy) NSString *synonymes;
@end
