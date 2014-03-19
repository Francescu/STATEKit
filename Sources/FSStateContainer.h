//
//  FSStateContainer.h
//  STATEKit
//
//  Created by Francescu SANTONI on 18/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSState;
@interface FSStateContainer : NSObject
@property (nonatomic, strong) NSDictionary *children;
- (FSState *(^)(NSString *identifier))add;
- (FSState *(^)(NSString *identifier))state;
@end
