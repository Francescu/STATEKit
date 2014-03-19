//
//  FSRequest.m
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSRequest.h"

@implementation FSRequest

- (NSURL *)requestURL
{
    if (!self.searchMode || !self.request)
    {
        return nil;
    }
    
    NSString *root = @"http://www.adecec.net/infcor/xmlreq.php?";
   
    NSString *URLString = [root stringByAppendingFormat:@"l=%d",self.searchLanguage];
    URLString = [URLString stringByAppendingFormat:@"&sc=%d",self.searchMode];
    URLString = [URLString stringByAppendingFormat:@"&c=%@",[self.request stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return [NSURL URLWithString:URLString];
}

@end
