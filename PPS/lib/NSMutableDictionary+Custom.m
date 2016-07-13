//
//  NSMutableDictionary+Custom.m
//  ReferralHive
//
//  Created by Najmul Hasan on 12/2/13.
//  Copyright (c) 2013 Najmul Hasan. All rights reserved.
//

#import "NSMutableDictionary+Custom.h"

@implementation NSMutableDictionary (Custom)

- (void)resolveNullObject{
    
    NSArray *nullObjectKeys = [self allKeysForObject:[NSNull null]];
    [nullObjectKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self setValue:@"" forKey:(NSString*)obj];
    }];
}

@end
