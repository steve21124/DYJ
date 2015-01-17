//
//  Task.h
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

typedef NS_ENUM(NSUInteger, TaskStatus) {
    TaskStatusDefault,
    TaskStatusFinished,
    TaskStatusFail,
    TaskStatusDone,
    TaskStatusesCount
};

@interface Task : PFObject <PFSubclassing>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *taskDescription;
@property (nonatomic) PFUser *creator;
@property (nonatomic) NSNumber *reward;
@property (nonatomic) NSDate *expiration;
@property (nonatomic) NSDate *finishedAt;
@property (nonatomic) NSNumber *status;

@property (nonatomic, readonly) PFRelation *asigned;

+ (NSString *)parseClassName;

@end