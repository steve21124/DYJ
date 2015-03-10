//
//  Task.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "Task.h"

@implementation Task

@dynamic title;
@dynamic taskDescription;
@dynamic creator;
@dynamic reward;
@dynamic expiration;
@dynamic status;
@dynamic finishedAt;

+ (NSString *)parseClassName
{
    return @"Task";
}

- (PFRelation *)asigned
{
    PFRelation *asignedFriends = [self relationForKey:@"asigned"];
    return asignedFriends;
}

@end
