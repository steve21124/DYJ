//
//  NotificationsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "NotificationsVC.h"
#import "Helper.h"

@interface NotificationsVC () <UIAlertViewDelegate>

@end

@implementation NotificationsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"DO YOUR JOB!";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadMoreNotification];
}

- (void)loadMoreNotification
{
    NSInteger numberOfNotifications = [[Helper sharedHelper].notifications count];
    if (numberOfNotifications) {
        Notification *notification = [[Helper sharedHelper].notifications firstObject];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.text
                                                        message:@"Убраться дома"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [[Helper sharedHelper] removeNotification:notification];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadMoreNotification];
}

@end
