//
//  Notification.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@dynamic type;
@dynamic isRead;
@dynamic createdAt;
@dynamic sender;
@dynamic receiver;
@dynamic task;

+ (NSString *)parseClassName
{
    return @"Notification";
}

@end
