//
//  MyJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "MyJobsVC.h"

// Models.
#import "Task.h"
#import "Notification.h"

// Controllers.
#import "AddJobVC.h"

// Views.
#import "TaskCell.h"
#import "HintView.h"
#import "NotificationView.h"
#import "NotificationActionSelector.h"

#define NOTIFICATION_SIDE_PADDING 15.0
#define NOTIFICATION_HEIGHT 260.0
#define BUTTON_SIDE_PADDING 25.0
#define BUTTON_HEIGHT 45.0
#define BUTTON_NOTIFICATION_SPACING 12.0

@interface MyJobsVC () <UITableViewDataSource, UITableViewDelegate, AddJobVCDelegate, TaskCellDelegate, NotificationActionSelectorDelegate>

@property UIView *contentView;
@property UIView *hintView;
@property (nonatomic) HintView *connectionErrorView;

@property UITableView *tableView;
@property UIRefreshControl *refreshControl;
@property (nonatomic) NSArray *tasks;
@property UIView *notificationsContainer;
@property NotificationView *notificationView;
@property NotificationActionSelector *actionSelector;

@property (nonatomic) BOOL connectionProblem;
@property (nonatomic) BOOL firstTimeLoading;

@end

@implementation MyJobsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"MY JOBS";
    self.firstTimeLoading = YES;

    // Add button.
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *addButtonImage = [UIImage imageNamed:@"add"];
    CGRect addButtonFrame = CGRectMake(0, 0, addButtonImage.size.width, addButtonImage.size.height);
    addButton.frame = addButtonFrame;
    [addButton setImage:addButtonImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addBarButton;

    // Table View.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(6.0, 0, 6.0, 0);
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:NSStringFromClass([TaskCell class])];
    [self.view addSubview:self.tableView];

    // Content view.
    CGRect frame = self.view.bounds;
    frame.size.height -= self.tabBarController.tabBar.height;
    self.contentView = [[UIView alloc] initWithFrame:frame];
    self.contentView.userInteractionEnabled = NO;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];

    // Connection error view.
    HintView *connectionErrorView = [[HintView alloc] initWithFrame:self.contentView.bounds];
    connectionErrorView.userInteractionEnabled = NO;
    connectionErrorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    connectionErrorView.sidePadding = 30.0;
    [connectionErrorView setTitleLabelText:@"No Connection"];
    [connectionErrorView setDescriptionLabelText:@"Check your internet connection and retry loading."];
    self.connectionErrorView = connectionErrorView;
    [self.contentView addSubview:self.connectionErrorView];

    // Hint view.
    [self addHintView];

    // Notifications container.
    self.notificationsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 2 * NOTIFICATION_SIDE_PADDING, NOTIFICATION_HEIGHT + BUTTON_NOTIFICATION_SPACING + BUTTON_HEIGHT)];
    self.notificationsContainer.backgroundColor = [UIColor clearColor];
    self.notificationsContainer.center = CGPointMake(self.contentView.width / 2.0, self.contentView.height / 2.0);
    self.notificationsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:self.notificationsContainer];

    // Refresh control.
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl beginRefreshing];

    // Load data.
    [self loadTasksWithCompletionBlock:^(NSArray *tasks, NSError *error) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    [self findOldTasks];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refreshControl endRefreshing];
}

#pragma mark - Add Task

- (void)addButtonPressed:(id)sender
{
    UINavigationController *vc = [AddJobVC storyboardVC];
    AddJobVC *addJobVC = (AddJobVC *)vc.topViewController;
    addJobVC.delegate = self;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:^(){}];
}

- (void)addJobVCDidCancel:(AddJobVC *)vc
{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)addJobVCDidFinish:(AddJobVC *)vc
{
    // Load data.
    [self.refreshControl beginRefreshing];
    [self loadTasksWithCompletionBlock:^(NSArray *tasks, NSError *error) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark - Updation

- (void)refresh:(id)sender
{
    [self loadTasksWithCompletionBlock:^(NSArray *tasks, NSError *error) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)loadTasksWithCompletionBlock:(void (^)(NSArray *tasks, NSError *error))block
{
    PFUser *localUser = [PFUser currentUser];
    if (!localUser) {
        if (block) {
            block(nil, [NSError errorWithDomain:@"" code:0 userInfo:@{@"description":@"No user."}]);
        }
        return;
    }

    __weak MyJobsVC *weakSelf = self;
    PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
    [taskQuery whereKey:@"creator" equalTo:localUser];
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDefault)]];
    [taskQuery orderByDescending:@"createdAt"];
    [taskQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            weakSelf.firstTimeLoading = NO;
            weakSelf.connectionProblem = YES;
        } else {
            weakSelf.firstTimeLoading = NO;
            weakSelf.connectionProblem = NO;
            weakSelf.tasks = objects;
        }
        if (block) {
            block(objects, error);
        }
    }];
}

- (void)findOldTasks
{
    PFUser *localUser = [PFUser currentUser];
    if (!localUser) {
        return;
    }

    PFQuery *taskWithNotificationQuery = [Notification query];
    [taskWithNotificationQuery whereKey:@"type" equalTo:@(NotificationTypeTaskNoTimeLeft)];
    [taskWithNotificationQuery selectKeys:@[@"task"]];
    [taskWithNotificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            return;
        }
        NSArray *notificationsOfType = objects;
        NSMutableArray *tasksWithNotifications = [NSMutableArray new];
        for (Notification *notification in notificationsOfType) {
            [tasksWithNotifications addObject:notification.task];
        }

        PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
        [taskQuery whereKey:@"creator" equalTo:localUser];
        [taskQuery whereKey:@"expiration" lessThanOrEqualTo:[NSDate date]];
        [taskQuery whereKey:@"objectId" doesNotMatchKey:@"task" inQuery:taskWithNotificationQuery];
        [taskQuery orderByDescending:@"createdAt"];
        [taskQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error || !objects.count) {
                return;
            }
            NSMutableArray *tasks = [objects mutableCopy];
            for (Task *task in objects) {
                for (Task *taskWithNotification in tasksWithNotifications) {
                    if ([task.objectId isEqualToString:taskWithNotification.objectId]) {
                        [tasks removeObject:task];
                    }
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                for (Task *task in tasks) {
                    Notification *notification = [Notification new];
                    notification.type = @(NotificationTypeTaskNoTimeLeft);
                    notification.isRead = @(NO);
                    notification.sender = [PFUser currentUser];
                    notification.task = task;
                    notification.receiver = [PFUser currentUser];
                    [notification save];
                }
            });
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.tasks count];
    self.hintView.hidden = (numberOfRows || self.connectionProblem || self.firstTimeLoading);
    self.connectionErrorView.hidden = (numberOfRows || !self.connectionProblem || self.firstTimeLoading);
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.tasks[indexPath.row];
    NSString *title = task.title;
    return [TaskCell heightWithTitle:title width:self.tableView.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TaskCell class]) forIndexPath:indexPath];

    Task *task = self.tasks[indexPath.row];
    cell.delegate = self;
    cell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeTaskStatusButton)];
    cell.task = task;
    [cell setAvatarsURLs:@[]];

    __weak TaskCell *weakCell = cell;
    __weak Task *weakTask = task;
    
    [[task.asigned query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && weakCell.task == weakTask) {
            NSMutableArray *urls = [NSMutableArray new];
            for (PFUser *user in objects) {
                [urls addObject:user.profilePictureURL];
            }
            [cell setAvatarsURLs:urls];
        }
    }];

    return cell;
}

#pragma mark - Finish Task

- (void)taskCell:(TaskCell *)taskCell didSelectItemAtIndex:(NSInteger)index
{
    if ([taskCell.taskItemTypes[index] integerValue] == TaskCellItemTypeTaskStatusButton) {
        __weak Task *weakTask = taskCell.task;
        [UIAlertView showWithTitle:@"Warning" message:@"Do you want to finish your task now?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == alertView.cancelButtonIndex) {
                return;
            }
            if (!weakTask) {
                return;
            }

            PFQuery *taskWithNotificationQuery = [Notification query];
            [taskWithNotificationQuery whereKey:@"type" equalTo:@(NotificationTypeTaskNoTimeLeft)];
            [taskWithNotificationQuery whereKey:@"task" equalTo:weakTask];
            [taskWithNotificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error || objects.count || !weakTask) {
                    return;
                }
                Notification *notification = [Notification new];
                notification.type = @(NotificationTypeTaskNoTimeLeft);
                notification.isRead = @(NO);
                notification.sender = [PFUser currentUser];
                notification.task = weakTask;
                notification.receiver = [PFUser currentUser];
                [notification saveInBackground];

                weakTask.status = @(TaskStatusFinished);
                [weakTask saveInBackground];

                CGRect frame = CGRectMake(0, 0, self.notificationsContainer.width, NOTIFICATION_HEIGHT);
                NotificationView *notificationView = [[NotificationView alloc] initWithFrame:frame notification:notification];
                self.notificationView = notificationView;
                self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
                self.contentView.userInteractionEnabled = YES;
                [self.notificationsContainer addSubview:notificationView];
                notificationView.center = CGPointMake(self.notificationsContainer.width / 2.0, notificationView.height / 2.0);

                NotificationActionSelector *selector = [[NotificationActionSelector alloc] initWithFrame:CGRectMake(0.0, self.notificationsContainer.height - BUTTON_HEIGHT, self.view.width - 2 * BUTTON_SIDE_PADDING, BUTTON_HEIGHT)];
                selector.center = CGPointMake(self.notificationsContainer.width / 2.0, selector.centerY);
                [selector addButtonWithTitle:@"NO" type:NotificationActionSelectorButtonTypeDefault];
                [selector addButtonWithTitle:@"YES" type:NotificationActionSelectorButtonTypeDestructive];
                selector.delegate = self;
                self.actionSelector = selector;
                [self.notificationsContainer addSubview:selector];
            }];
        }];
    }
}

- (void)notificationActionSelector:(NotificationActionSelector *)selector didSelectButtonAtIndex:(NSInteger)index
{
    if (!self.notificationView) {
        return;
    }

    Notification *notification = self.notificationView.notification;
    self.actionSelector.userInteractionEnabled = NO;
    Task *task = notification.task;
    [task fetch];
    PFQuery *asignedQuery = [task.asigned query];
    [asignedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            self.actionSelector.userInteractionEnabled = YES;
            return;
        }

        if (index == 0) {
            PFUser *user = [PFUser currentUser];
            user.balance = @([user.balance integerValue] + [task.reward integerValue]);
            [user saveInBackground];

            task.status = @(TaskStatusFail);
        } else {
            task.status = @(TaskStatusDone);

            for (PFUser *friend in objects) {
                friend.balance = @([friend.balance integerValue] + [task.reward integerValue] / objects.count);
                [friend saveInBackground];
            }
        }
        task.finishedAt = [NSDate date];
        [task saveInBackground];

        for (PFUser *friend in objects) {
            Notification *notification = [Notification new];
            notification.type = @(NotificationTypeReward);
            notification.isRead = @(NO);
            notification.sender = [PFUser currentUser];
            notification.task = task;
            notification.receiver = friend;
            [notification saveInBackground];
        }

        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" containedIn:objects];
        PFUser *currentUser = [PFUser currentUser];
        NSString *message = [NSString stringWithFormat:@"%@: Finished task!", currentUser.profileName];
        [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:message];

        notification.isRead = @(YES);
        [notification saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
            self.actionSelector.userInteractionEnabled = YES;
            if (successful) {
                self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
                self.contentView.userInteractionEnabled = NO;
                [self.notificationView removeFromSuperview];
                [self.actionSelector removeFromSuperview];
            }
        }];
    }];
}

#pragma mark - Additional views

- (void)addHintView
{
    self.hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 120)];
    self.hintView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.hintView];

    UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(30, self.hintView.height - 60, self.hintView.width - 60, 60)];
    instructions.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    instructions.numberOfLines = 0;
    [self.hintView addSubview:instructions];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:18];
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    NSString *string = @"You haven’t set any goal yet. Start by tapping plus icon.";
    NSAttributedString *attributedInstructions = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color}];
    instructions.attributedText = attributedInstructions;

    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    arrow.originY = 16.0;
    arrow.originX = self.hintView.width - arrow.width - 20.0;
    [self.hintView addSubview:arrow];
}

@end