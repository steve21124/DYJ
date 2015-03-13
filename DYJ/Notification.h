//
//  Notification.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

typedef NS_ENUM(NSUInteger, NotificationType) {
    NotificationTypeNewTask,
    NotificationTypePing,
    NotificationTypeTaskNoTimeLeft,
    NotificationTypeReward,
    NotificationTypesCount
};

@interface Notification : PFObject <PFSubclassing>

@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *isRead;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) PFUser *sender;
@property (nonatomic) PFUser *receiver;
@property (nonatomic) Task *task;

+ (NSString *)parseClassName;

@end