//
//  STATEKitConstants.h
//  STATEKit
//
//  Created by Francescu SANTONI on 20/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#ifndef STATEKitConstants
#define STATEKitConstants

#define UNSTRING(s) NSString* const s = @#s;
#define STkExtern(s) extern NSString* const s;

#ifdef DEBUG
#   define STkL(...) NSLog(__VA_ARGS__)
#   define STkExceptionDebug(s) [NSException exceptionWithName:s reason:s userInfo:nil]
#else
#   define STkL(...)
#   define STkExceptionDebug(s)
#endif

/* 
 *   STATIC FORWARDING :
 *      0 -> Dynamic    -> The binding will only call the function name through StateManager
 *      1 -> Static     -> The binding will call the forwared function itself
 */
#define kSTkConfig_STATIC_FORWARDING 1
#define kSTkConfig_STATE_DELIMITER @"."

#define STkPath(...) [@[__VA_ARGS__] componentsJoinedByString:kSTkConfig_STATE_DELIMITER]
typedef BOOL (^FSFunctionBlock)();

#endif