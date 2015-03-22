//
//  MyJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "MyJobsVC.h"
#import "TaskCell.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AddJobVC.h"
#import "Task.h"
#import "Notification.h"
#import "HintView.h"

@interface MyJobsVC () <UITableViewDataSource, UITableViewDelegate, AddJobVCDelegate, TaskCellDelegate>

@property UIView *hintView;
@property UIView *contentView;
@property (nonatomic) HintView *connectionErrorView;
@property UILabel *instructions;
@property UIImageView *arrow;

@property UITableView *tableView;
@property UIRefreshControl *refreshControl;
@property (nonatomic) NSArray *tasks;

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

    // Refresh control.
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl beginRefreshing];

    // Load test data.
    [self loadTasksWithCompletionBlock:^(NSArray *tasks, NSError *error) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    [self findOldTasks];
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
    [self loadTasksWithCompletionBlock:^(NSArray *tasks, NSError *error) {
        [self.tableView reloadData];
    }];
}

- (void)addJobVCDidFinish:(AddJobVC *)vc
{
    [self loadTasksWithCompletionBlock:nil];
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
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDefault), @(TaskStatusFinished)]];
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

- (void)taskCell:(TaskCell *)taskCell didSelectItemAtIndex:(NSInteger)index
{
    
}

#pragma mark - Additional views

- (void)addHintView
{
    self.hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 120)];
    self.hintView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.hintView];

    self.instructions = [[UILabel alloc] initWithFrame:CGRectMake(30, self.hintView.height - 60, self.hintView.width - 60, 60)];
    self.instructions.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.instructions.numberOfLines = 0;
    [self.hintView addSubview:self.instructions];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:18];
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    NSString *string = @"You haven’t set any goal yet. Start by tapping plus icon.";
    NSAttributedString *attributedInstructions = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color}];
    self.instructions.attributedText = attributedInstructions;

    self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    self.arrow.originY = 16.0;
    self.arrow.originX = self.hintView.width - self.arrow.width - 20.0;
    [self.hintView addSubview:self.arrow];
}

@end