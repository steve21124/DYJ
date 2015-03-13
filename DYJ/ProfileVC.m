//
//  ProfileVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 13.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "ProfileVC.h"
#import "Categories.h"
#import "Helper.h"
#import "ProfileCell.h"
#import "TaskCell.h"

@interface ProfileVC () <UITableViewDataSource, UITableViewDelegate, TaskCellDelegate>

@property UITableView *tableView;
@property PFUser *user;
@property NSArray *completedTasks;

@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"MY PROFILE";
    self.completedTasks = @[];
    self.user = [PFUser currentUser];

    // Table view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:NSStringFromClass([ProfileCell class])];
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:NSStringFromClass([TaskCell class])];
    [self.view addSubview:self.tableView];

    [self loadProfile];
    [self loadTasks];
}

- (void)loadProfile
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)loadTasks
{
    PFUser *localUser = [PFUser currentUser];
    if (!localUser) {
        return;
    }

    PFQuery *taskQuery = [PFQuery queryWithClassName:[Task parseClassName]];
    [taskQuery whereKey:@"creator" equalTo:localUser];
    [taskQuery whereKey:@"status" containedIn:@[@(TaskStatusDone), @(TaskStatusFail)]];
    [taskQuery orderByDescending:@"finishedAt"];
    [taskQuery findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        self.completedTasks = tasks;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.completedTasks.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [ProfileCell height];
    } else {
        Task *task = self.completedTasks[indexPath.row];
        NSString *title = task.title;
        return [TaskCell heightWithTitle:title width:self.tableView.width];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ProfileCell class]) forIndexPath:indexPath];
        cell.name.text = self.user.profileName;
        cell.balance.attributedText = [TaskCellItem motivesStringWithMotives:self.user.balance];

        __weak PFUser *weakUser = [PFUser currentUser];
        __weak ProfileCell *weakCell = cell;
        weakCell.avatar.image = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakUser.profilePictureURL]];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (image && weakCell) {
                    weakCell.avatar.image = image;
                }
            });
        });

        return cell;
    } else if (indexPath.section == 1) {
        TaskCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TaskCell class]) forIndexPath:indexPath];

        Task *task = self.completedTasks[indexPath.row];
        cell.delegate = self;
        cell.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid), @(TaskCellItemTypeTaskStatus)];
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
    } else {
        return nil;
    }
}

@end
