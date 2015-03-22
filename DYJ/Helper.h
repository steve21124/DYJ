//
//  Helper.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"
#import "PFUser+DYJ.h"
#import "Task.h"

extern NSString *const HelperDidUpdateLoginStatusNotification;
extern NSString *const HelperDidUpdateNotifications;

@interface Helper : NSObject

+ (instancetype)sharedHelper;

@property (nonatomic) BOOL isAuthorized;
- (void)loginCompletion:(void(^)(PFUser *, NSError *))block;
- (void)logout;

@property NSArray *notifications;
- (void)addNotification:(Notification *)notification;
- (void)removeNotification:(Notification *)notification;

@end