//
//  TabBarVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "TabBarVC.h"

// Controllers.
#import "StartVC.h"

// Frameworks.
@import QuartzCore;

@interface TabBarVC ()

@property UIView *notificationsView;
@property UILabel *notificationsLabel;

@end

@implementation TabBarVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load VCs.
    self.tabBar.tintColor = [UIColor mainAppColor];
    for (UIViewController *vc in self.viewControllers) {
        NSInteger index = [self.viewControllers indexOfObject:vc];
        NSDictionary *items = [self itemsForVCAtIndex:index];
        vc.tabBarItem.title = items[@"title"];
        vc.tabBarItem.image = [UIImage imageNamed:items[@"image"]];
    }

    // Subscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications:) name:HelperDidUpdateNotifications object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginStatus:) name:HelperDidUpdateLoginStatusNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Check Auth.
    [self updateLoginStatusAnimated:NO];
}

- (void)updateLoginStatus:(id)sender
{
    [self updateLoginStatusAnimated:YES];
}

- (void)updateLoginStatusAnimated:(BOOL)animated
{
    if ([Helper sharedHelper].isAuthorized) {
        if ([self.presentedViewController isKindOfClass:[StartVC class]]) {
            [self dismissViewControllerAnimated:animated completion:^(){}];
        }
    } else {
        if (![self.presentedViewController isKindOfClass:[StartVC class]]) {
            [self presentViewController:[StartVC storyboardVC] animated:animated completion:^(){}];
        }
    }
}

- (NSDictionary *)itemsForVCAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return @{@"title" : @"Me", @"image" : @"You 2"};
        case 1:
            return @{@"title" : @"Friends", @"image" : @"Friends 2"};
        case 2:
            return @{@"title" : @"Do it", @"image" : @"Do it 2"};
        case 3:
            return @{@"title" : @"Profile", @"image" : @"Profile 2"};
        default:
            return nil;
    }
}

- (void)updateNotifications:(NSNotification *)notifications
{
    self.notificationsNumber = [[Helper sharedHelper].notifications count];
}

- (void)setNotificationsNumber:(NSInteger)notificationsNumber
{
    _notificationsNumber = notificationsNumber;

    if (!self.notificationsView) {
        self.notificationsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.notificationsView.layer.cornerRadius = 10;
        self.notificationsView.backgroundColor = [UIColor colorWithColorCode:@"ff7b7b"];
        self.notificationsLabel = [[UILabel alloc] initWithFrame:self.notificationsView.bounds];
        self.notificationsLabel.textAlignment = NSTextAlignmentCenter;
        self.notificationsLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:12];
        self.notificationsLabel.textColor = [UIColor whiteColor];
        [self.notificationsView addSubview:self.notificationsLabel];
        self.notificationsView.center = CGPointMake(self.tabBar.width / 2.0, 0.0);
        [self.tabBar addSubview:self.notificationsView];
    }

    self.notificationsLabel.text = [NSString stringWithFormat:@"%ld", (long)notificationsNumber];
    self.notificationsView.hidden = !notificationsNumber;
}

@end
