//
//  PFUser+DYJ.m
//  DYJ
//
//  Created by Timur Bernikowich on 10.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "PFUser+DYJ.h"

@implementation PFUser (DYJ)

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
