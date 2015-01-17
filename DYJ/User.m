//
//  User.m
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "User.h"

@implementation PFUser (User)

#pragma mark - Balance

- (NSNumber *)balance
{
    return [self objectForKey:@"balance"];
}

- (void)setBalance:(NSNumber *)balance
{
    [self setObject:balance forKey:@"balance"];
}

#pragma mark - Profile

- (NSString *)profileName
{
    NSDictionary *profile = [self profile];
    return profile[@"name"];
}

- (NSString *)profilePictureURL
{
    NSDictionary *profile = [self profile];
    return profile[@"pictureURL"];
}

- (NSDictionary *)profile
{
    return [self objectForKey:@"profile"];
}

@end
