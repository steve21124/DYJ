//
//  MyJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "MyJobsVC.h"
#import "TaskCell.h"
#import "Categories.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AddJobVC.h"
#import "Task.h"
#import "Notification.h"

@interface MyJobsVC () <UITableViewDataSource, UITableViewDelegate, AddJobVCDelegate, TaskCellDelegate>

@property UIView *hintView;
@property UILabel *instructions;
@property UIImageView *arrow;

@property UITableView *tableView;
@property NSArray *tasks;

@end

@implementation MyJobsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"MY JOBS";

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
    self.tableView.contentInset = UIEdgeInsetsMake(12.0, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:NSStringFromClass([TaskCell class])];
    [self.view addSubview:self.tableView];

    // Hint view.
    self.hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
    [self.view addSubview:self.hintView];

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

    // Load test data.
    [self loadTasks];
    [self findOldTasks];
}

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
    [self loadTasks];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)loadTasks
{
    PFUser *localUser = [PFUser currentUser];
    if (!localUser) {
        return;
    }

    PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
    [taskQuery whereKey:@"creator" equalTo:localUser];
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDefault), @(TaskStatusFinished)]];
    [taskQuery orderByDescending:@"createdAt"];
    NSArray *tasks = [taskQuery findObjects];

    self.tasks = tasks;
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
    NSArray *notificationsOfType = [taskWithNotificationQuery findObjects];
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
        NSMutableArray *tasks = [objects mutableCopy];
        for (Task *task in objects) {
            for (Task *taskWithNotification in tasksWithNotifications) {
                if ([task.objectId isEqualToString:taskWithNotification.objectId]) {
                    [tasks removeObject:task];
                }
            }
        }
        if (!error && tasks.count) {
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
        }
    }];
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

@end