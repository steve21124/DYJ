//
//  Helper.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "Helper.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileUpdater.h"
#import "FriendsUpdater.h"

NSString *const HelperDidUpdateLoginStatusNotification = @"HelperDidUpdateLoginStatusNotification";
NSString *const HelperDidUpdateNotifications = @"HelperDidUpdateNotifications";

@implementation Helper

+ (instancetype)sharedHelper
{
    static Helper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [Helper new];
        helper.notifications = [NSArray new];
    });
    return helper;
}

#pragma mark - Authorization

- (BOOL)isAuthorized
{
    PFUser *user = [PFUser currentUser];
    if (user && [PFFacebookUtils isLinkedWithUser:user]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)loginCompletion:(void(^)(User *, NSError *))block
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_friends"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (user) {
            // New user gain 1000 points on balance.
            if (user.isNew) {
                [user setObject:@(1000) forKey:@"balance"];
            }

            // Start updating info.
            [[ProfileUpdater sharedUpdater] startUpdating];
            [[FriendsUpdater sharedUpdater] startUpdating];

            // Post notification.
            [[NSNotificationCenter defaultCenter] postNotificationName:HelperDidUpdateLoginStatusNotification object:nil];

            block((User *)user, error);
        } else {
            block((User *)user, error);
        }
    }];
}

- (void)logout
{
    [PFUser logOut];

    // Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:HelperDidUpdateLoginStatusNotification object:nil];
}

#pragma mark - Notifications

- (void)addNotification:(Notification *)notification
{
    self.notifications = [self.notifications arrayByAddingObject:notification];
    [[NSNotificationCenter defaultCenter] postNotificationName:HelperDidUpdateNotifications object:nil];
}

- (void)removeNotification:(Notification *)notification
{
    NSMutableArray *notifications = [self.notifications mutableCopy];
    [notifications removeObject:notification];
    self.notifications = notifications;
    [[NSNotificationCenter defaultCenter] postNotificationName:HelperDidUpdateNotifications object:nil];
}

@end
