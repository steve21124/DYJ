//
//  FriendsJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsJobsVC.h"
#import "TaskCell.h"
#import "Categories.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Helper.h"

@interface FriendsJobsVC () <UITableViewDataSource, UITableViewDelegate, TaskCellDelegate>

@property UIView *hintView;
@property UILabel *instructions;
@property UITableView *tableView;
@property NSArray *tasks;

@end

@implementation FriendsJobsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"JOBS YOUR FRIENDS DO";

    // Table View.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(12.0, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:NSStringFromClass([TaskCell class])];
    [self.view addSubview:self.tableView];

    // Hint view.
    self.hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 120)];
    [self.view addSubview:self.hintView];

    self.instructions = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, self.hintView.width - 60, self.hintView.height)];
    self.instructions.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.instructions.numberOfLines = 0;
    [self.hintView addSubview:self.instructions];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:18];
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    NSString *string = @"There’s no jobs yet. However, you can remind your friends to get started!";
    NSAttributedString *attributedInstructions = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color}];
    self.instructions.attributedText = attributedInstructions;

    // Load test data.
    [self loadTasks];
    
}

- (void)loadTasks
{
    PFUser *localUser = [PFUser currentUser];
    if (!localUser) {
        return;
    }
    
    PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
    [taskQuery whereKey:@"asigned" equalTo:[PFUser currentUser]];
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDefault)]];
    [taskQuery whereKey:@"expiration" greaterThan:[NSDate date]];
    [taskQuery orderByDescending:@"createdAt"];
    NSArray *tasks = [taskQuery findObjects];
//    
//    query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
//        if (!error) {
//            
//        }
//    }];
    
    self.tasks = tasks;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.tasks count];
    self.hintView.hidden = numberOfRows;
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

    PFQuery *notificationQuery = [PFQuery queryWithClassName:[Notification parseClassName]];
    [notificationQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [notificationQuery whereKey:@"receiver" equalTo:task.creator];
    [notificationQuery whereKey:@"task" equalTo:task];
    [notificationQuery whereKey:@"type" equalTo:@(NotificationTypePing)];
    [notificationQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:- 60 * 60]];
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
    taskCell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeLoading)];
    [taskCell reloadItems];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:taskCell];
    Task *task = self.tasks[indexPath.row];

    __weak FriendsJobsVC *weakSelf = self;
    __weak TaskCell *weakCell = taskCell;

    PFQuery *notificationQuery = [PFQuery queryWithClassName:[Notification parseClassName]];
    [notificationQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [notificationQuery whereKey:@"receiver" equalTo:task.creator];
    [notificationQuery whereKey:@"task" equalTo:task];
    [notificationQuery whereKey:@"type" equalTo:@(NotificationTypePing)];
    [notificationQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:- 60 * 60]];
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if (!objects.count) {
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
                        [weakSelf reloadCell:weakCell];
                    }
                });
            }
        }
    }];
}

- (void)reloadCell:(UITableViewCell *)cell
{
    if (cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

@end
