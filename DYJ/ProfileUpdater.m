//
//  ProfileUpdater.m
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "ProfileUpdater.h"

@interface ProfileUpdater ()

@property NSTimer *timer;
@property BOOL updating;

@end

@implementation ProfileUpdater

+ (instancetype)sharedUpdater
{
    static ProfileUpdater *updater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updater = [ProfileUpdater new];
    });
    return updater;
}

- (void)startUpdating
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    }
    [self update];
}

- (void)update
{
    if (self.updating) {
        return;
    } else {
        self.updating = YES;
    }

    if (![Helper sharedHelper].isAuthorized) {
        self.updating = NO;
        return;
    }

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Parse the data received.
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [NSMutableDictionary new];

            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"name"] = name;
            }
            NSString *location = userData[@"location"][@"name"];
            if (location) {
                userProfile[@"location"] = location;
            }
            NSString *facebookID = userData[@"id"];
            if (facebookID) {
                userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            }
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookId"];
            [[PFUser currentUser] saveInBackground];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [[Helper sharedHelper] logout];
        }
        self.updating = NO;
    }];
}

@end
