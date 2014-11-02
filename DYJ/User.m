//
//  User.m
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "User.h"

@implementation User

- (NSString *)profileName
{
    NSDictionary *profile = [self profile];
    return profile[@"name"];
}

- (NSString *)profileURL
{
    NSDictionary *profile = [self profile];
    return profile[@"pictureURL"];
}

- (NSDictionary *)profile
{
    return [self objectForKey:@"profile"];
}

@end
