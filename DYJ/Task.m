//
//  Task.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "Task.h"
#import <PFObject+Subclass.h>

@implementation Task

@dynamic title;
@dynamic taskDescription;
@dynamic creator;
@dynamic reward;
@dynamic expiration;
@dynamic status;

+ (NSString *)parseClassName
{
    return @"Task";
}

@end
