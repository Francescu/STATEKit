//
//  FSRequestManager.m
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSRequestManager.h"
#import "FSRequest.h"

#import "FSResult.h"
#import "FSWordDefinition.h"
#import "TBXML.h"

@implementation FSRequestManager

- (instancetype)initWithRequest:(FSRequest *)request
{
    self = [super init];
    if (self)
    {
        _request = request;
    }
    
    return self;
}

- (void)startRequestWithCompletion:(void (^)(FSResult* result, NSError *error))completion
{
    NSAssert(self.request, @"You need a request to perform a request (it makes sense, right?)");
    
    NSURL *URL = [self.request requestURL];
    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];

    [NSURLConnection sendAsynchronousRequest:URLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError)
        {
            if (completion)
            {
                completion(nil, connectionError);
                return;
            }
        }
        
        if (!data)
        {
            return;
        }
        
        TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:nil];
        TBXMLElement *root = tbxml.rootXMLElement;
        
        FSResult *result = [FSRequestManager resultWithRequest:self.request rootElement:root];
        completion(result, nil);
    }];
}


+ (FSResult *)resultWithRequest:(FSRequest *)request rootElement:(TBXMLElement *)root
{
    FSResult *result = [[FSResult alloc] init];
    result.request = request;
    
    TBXMLElement *element = [TBXML childElementNamed:@"resultat" parentElement:root];
    
    NSMutableArray *array = [NSMutableArray array];
    
    while (element)
    {
        FSWordDefinition *word = [FSRequestManager wordDefinitionWithRootElement:element];
        if (word)
        {
            [array addObject:word];
        }
        
        element = element->nextSibling;
    }
    
    result.words = array;
    
    return result;
}

+ (FSWordDefinition *)wordDefinitionWithRootElement:(TBXMLElement *)root
{
    FSWordDefinition *entity = [[FSWordDefinition alloc] init];
    
    TBXMLElement *motElement = [TBXML childElementNamed:@"mot" parentElement:root];
    entity.word = [TBXML textForElement:motElement];
    
    TBXMLElement *traductionElement = [TBXML childElementNamed:@"traduction" parentElement:root];
    entity.translation = [TBXML textForElement:traductionElement];
    
    TBXMLElement *definitionElement = [TBXML childElementNamed:@"definition" parentElement:root];
    entity.definition = [TBXML textForElement:definitionElement];
    
    TBXMLElement *synonymesElement = [TBXML childElementNamed:@"synonymes" parentElement:root];
    entity.synonymes = [TBXML textForElement:synonymesElement];
    
    return entity;
}
@end
