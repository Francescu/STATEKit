//
//  FSWordDefinition.m
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSWordDefinition.h"
#import "TBXML.h"

@implementation FSWordDefinition

- (NSString *)description
{
    return [NSString stringWithFormat:@"Word: %@\nTrad: %@\nDef: %@\nSyn: %@",self.word,self.translation,self.definition,self.synonymes];
}

@end
