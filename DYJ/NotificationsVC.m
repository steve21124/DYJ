//
//  NotificationsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "NotificationsVC.h"
#import "Helper.h"
#import "Categories.h"
#import "NotificationView.h"
#import "NotificationActionSelector.h"

#define NUMBER_OF_NOTIFICATIONS_SHOWN_SIMULTANEOUSLY 3

#define NOTIFICATION_SIDE_PADDING 15.0
#define NOTIFICATION_HEIGHT 260.0
#define BUTTON_SIDE_PADDING 25.0
#define BUTTON_HEIGHT 45.0
#define BUTTON_NOTIFICATION_SPACING 12.0

#define NOTIFICATION_SCALE_DECREASE_PERCENT 0.01
#define NOTIFICATION_SHIFT 2.0

@interface NotificationsVC () <UIAlertViewDelegate, NotificationActionSelectorDelegate>

@property UIView *contentView;
@property UIView *notificationsContainer;
@property NSArray *notifications;
@property NotificationActionSelector *actionSelector;
@property NSArray *shownNotificationViews;

@end

@implementation NotificationsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Page.
    self.navigationItem.title = @"DO YOUR JOB!";
    self.view.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];

    // Content view.
    CGRect frame = self.view.bounds;
    frame.size.height -= self.tabBarController.tabBar.height;
    self.contentView = [[UIView alloc] initWithFrame:frame];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];

    // Notifications container.
    self.notificationsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 2 * NOTIFICATION_SIDE_PADDING, NOTIFICATION_HEIGHT + BUTTON_NOTIFICATION_SPACING + BUTTON_HEIGHT)];
    self.notificationsContainer.backgroundColor = [UIColor clearColor];
    self.notificationsContainer.center = CGPointMake(self.contentView.width / 2.0, self.contentView.height / 2.0);
    self.notificationsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.notificationsContainer];

    // Query for unread notifications.
    PFQuery *notificationQuery = [Notification query];
    [notificationQuery whereKey:@"receiver" equalTo:[PFUser currentUser]];
    [notificationQuery whereKey:@"isRead" equalTo:@(NO)];
    [notificationQuery orderByDescending:@"createdAt"];
    [notificationQuery includeKey:@"sender"];
    [notificationQuery includeKey:@"task"];
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            self.notifications = objects;
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self loadNotifications];
            });
        }
    }];
}

- (void)loadNotifications
{
    // Notification.
    NSMutableArray *newNotificationViews = [NSMutableArray new];
    for (NSInteger index = 0; index < NUMBER_OF_NOTIFICATIONS_SHOWN_SIMULTANEOUSLY; index++) {
        NotificationView *notificationView;
        if (index < self.shownNotificationViews.count) {
            notificationView = self.shownNotificationViews[index];
        } else {
            CGRect frame = CGRectMake(0, 0, self.notificationsContainer.width, NOTIFICATION_HEIGHT);
            Notification *notification = self.notifications.count > index ? self.notifications[index] : nil;
            if (!notification) {
                break;
            }
            notificationView = [[NotificationView alloc] initWithFrame:frame notification:notification];
            NotificationView *previousNotificationView = index ? newNotificationViews[index - 1] : nil;
            if (previousNotificationView) {
                [self.notificationsContainer insertSubview:notificationView belowSubview:previousNotificationView];
            } else {
                [self.notificationsContainer addSubview:notificationView];
            }
        }
        CGFloat percent = 1.0 - index * NOTIFICATION_SCALE_DECREASE_PERCENT;
        notificationView.transform = CGAffineTransformMakeScale(percent, percent);
        notificationView.center = CGPointMake(self.notificationsContainer.width / 2.0, notificationView.height / 2.0 - NOTIFICATION_SHIFT * 2.0 * index);
        [newNotificationViews addObject:notificationView];
    }
    self.shownNotificationViews = newNotificationViews;

    Notification *notification = self.shownNotificationViews.count ? self.shownNotificationViews[0] : nil;
    if (notification) {
        NotificationActionSelector *selector = [[NotificationActionSelector alloc] initWithFrame:CGRectMake(0.0, self.notificationsContainer.height - BUTTON_HEIGHT, self.view.width - 2 * BUTTON_SIDE_PADDING, BUTTON_HEIGHT)];
        selector.center = CGPointMake(self.notificationsContainer.width / 2.0, selector.centerY);
        if ([notification.type integerValue] == NotificationTypePing) {
            [selector addButtonWithTitle:@"OK!" type:NotificationActionSelectorButtonTypeDefault];
        } else if ([notification.type integerValue] == NotificationTypeNewTask) {
            [selector addButtonWithTitle:@"OK!" type:NotificationActionSelectorButtonTypeDefault];
        }
        //[selector addButtonWithTitle:@"NO" type:NotificationActionSelectorButtonTypeDefault];
        //[selector addButtonWithTitle:@"YES" type:NotificationActionSelectorButtonTypeDestructive];
        selector.delegate = self;
        self.actionSelector = selector;
        [self.notificationsContainer addSubview:selector];
    }
}

- (void)notificationActionSelector:(NotificationActionSelector *)selector didSelectButtonAtIndex:(NSInteger)index
{
    Notification *notification = self.notifications.count ? self.notifications[0] : nil;
    if (notification) {
        if ([notification.type integerValue] == NotificationTypePing || [notification.type integerValue] == NotificationTypeNewTask) {
            self.actionSelector.userInteractionEnabled = NO;
            notification.isRead = @(YES);
            [notification saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
                self.actionSelector.userInteractionEnabled = YES;
                if (successful) {
                    NSMutableArray *notifications = [self.notifications mutableCopy];
                    [notifications removeObject:notification];
                    self.notifications = notifications;
#warning Animate selector
                    NSMutableArray *notificationsViews = [self.shownNotificationViews mutableCopy];
                    NotificationView *view = notificationsViews[0];
                    [notificationsViews removeObjectAtIndex:0];
                    self.shownNotificationViews = notificationsViews;
                    [view removeFromSuperview];
                    [self.actionSelector removeFromSuperview];
                    [self loadNotifications];
                }
            }];
        }
    }
}

@end
