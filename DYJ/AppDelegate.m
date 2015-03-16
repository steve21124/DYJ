//
//  AppDelegate.m
//  DYJ
//
//  Created by Timur Bernikowich on 10.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendsUpdater.h"
#import "ProfileUpdater.h"
#import "Helper.h"
#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse initialization.
    [Parse setApplicationId:@"mZezLpbXT7O72w6I6meVZXaXYeXqHU1oEAGJc9YB" clientKey:@"Ss1MIRLN7Y7z6rDoEf5GodBSvARai3rJf03I9CrT"];
    [Task registerSubclass];
    [Notification registerSubclass];
    PFUser *localUser = [PFUser currentUser];
    if (localUser) {
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = localUser;
        [installation saveInBackground];
    }

    // Facebook initialization.
    [PFFacebookUtils initializeFacebook];
    [[FriendsUpdater sharedUpdater] startUpdating];
    [[ProfileUpdater sharedUpdater] startUpdating];

    // Register for Push Notitications (iOS 8 changed workflow).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[PFFacebookUtils session] close];
}

@end
