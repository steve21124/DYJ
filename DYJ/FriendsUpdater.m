//
//  FriendsUpdater.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsUpdater.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Helper.h"

@interface FriendsUpdater ()

@property NSTimer *timer;
@property BOOL updating;

@end

@implementation FriendsUpdater

+ (instancetype)sharedUpdater
{
    static FriendsUpdater *updater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updater = [FriendsUpdater new];
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
        return;
    }

    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Result will contain an array with your user's friends in the "data" key.
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];

            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }

            // Construct a PFUser query that will find friends whose facebook ids are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookId" containedIn:friendIds];
            NSArray *friends = [friendQuery findObjects];

            // Add relations with friends.
            PFUser *localUser = [PFUser currentUser];
            PFRelation *friendsRelation = [localUser relationForKey:@"friends"];
            for (PFUser *friend in friends) {
                [friendsRelation addObject:friend];
            }
            [localUser saveInBackground];

#warning Push message example
//            // Create our Installation query
//            // Send push notification to query
//            PFQuery *pushQuery = [PFInstallation query];
//            [pushQuery whereKey:@"user" matchesQuery:friendQuery];
//            [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:@"New Push Message."];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [[Helper sharedHelper] logout];
        }
        self.updating = NO;
    }];

}

@end