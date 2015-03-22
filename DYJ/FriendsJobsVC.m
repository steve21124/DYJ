//
//  FriendsJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsJobsVC.h"

// Views.
#import "HintView.h"
#import "TaskCell.h"

#define PING_REFRESH_TIME 3600

@interface FriendsJobsVC () <UITableViewDataSource, UITableViewDelegate, TaskCellDelegate>

@property UIView *contentView;
@property (nonatomic) HintView *connectionErrorView;
@property (nonatomic) HintView *noJobsView;

@property UITableView *tableView;
@property UIRefreshControl *refreshControl;
@property NSArray *tasks;

@property (nonatomic) BOOL connectionProblem;
@property (nonatomic) BOOL firstTimeLoading;

@end

@implementation FriendsJobsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"JOBS YOUR FRIENDS DO";
    self.firstTimeLoading = YES;

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

    // No jobs view.
    HintView *noJobsView = [[HintView alloc] initWithFrame:self.contentView.bounds];
    noJobsView.userInteractionEnabled = NO;
    noJobsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    noJobsView.sidePadding = 30.0;
    [noJobsView setTitleLabelText:@"There’s no jobs yet"];
    [noJobsView setDescriptionLabelText:@"However, you can remind your friends to get started!"];
    self.noJobsView = noJobsView;
    [self.contentView addSubview:self.noJobsView];

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

    __weak FriendsJobsVC *weakSelf = self;
    PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
    [taskQuery whereKey:@"asigned" equalTo:[PFUser currentUser]];
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDefault)]];
    [taskQuery whereKey:@"expiration" greaterThan:[NSDate date]];
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

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.tasks count];
    self.noJobsView.hidden = (numberOfRows || self.connectionProblem || self.firstTimeLoading);
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
    cell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeLoading)];
    cell.task = task;
    [cell setAvatarsURLs:@[]];
    
    __weak TaskCell *weakCell = cell;
    __weak Task *weakTask = task;

    [self updateCellStatus:cell];
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

#pragma mark - Pings

- (void)updateCellStatus:(TaskCell *)cell
{
    __weak TaskCell *weakCell = cell;
    __weak Task *weakTask = cell.task;

    PFQuery *notificationQuery = [self queryForFreshPings:cell.task];
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error && weakCell.task == weakTask) {
            if (objects.count) {
                weakCell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeRemindStatus)];
                [weakCell reloadItems];
            } else {
                weakCell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeRemindButton)];
                [weakCell reloadItems];
            }
        }
    }];
}

- (PFQuery *)queryForFreshPings:(Task *)task
{
    PFQuery *notificationQuery = [PFQuery queryWithClassName:[Notification parseClassName]];
    [notificationQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [notificationQuery whereKey:@"receiver" equalTo:task.creator];
    [notificationQuery whereKey:@"task" equalTo:task];
    [notificationQuery whereKey:@"type" equalTo:@(NotificationTypePing)];
    [notificationQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:- PING_REFRESH_TIME]];
    return notificationQuery;
}

- (void)taskCell:(TaskCell *)taskCell didSelectItemAtIndex:(NSInteger)index
{
    taskCell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeLoading)];
    [taskCell reloadItems];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:taskCell];
    Task *task = self.tasks[indexPath.row];

    __weak FriendsJobsVC *weakSelf = self;
    __weak TaskCell *weakCell = taskCell;

    PFQuery *notificationQuery = [self queryForFreshPings:task];
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error && !objects.count) {
            Notification *notification = [Notification new];
            notification.type = @(NotificationTypePing);
            notification.isRead = @(NO);
            notification.sender = [PFUser currentUser];
            notification.task = task;
            notification.receiver = task.creator;
            [notification save];

            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:task.creator];
            PFUser *currentUser = [PFUser currentUser];
            NSString *message = currentUser.profileName ? [NSString stringWithFormat:@"%@: Move on!", currentUser.profileName] : @"Move on!";
            [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:message];

            dispatch_async(dispatch_get_main_queue(), ^(){
                if (weakCell && weakCell.task == task) {
                    [weakSelf updateCellStatus:weakCell];
                }
            });
        }
    }];
}

@end
