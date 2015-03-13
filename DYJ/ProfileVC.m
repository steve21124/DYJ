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

@interface ProfileVC () <UITableViewDataSource, UITableViewDelegate>

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

    // Table view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:NSStringFromClass([ProfileCell class])];
    [self.view addSubview:self.tableView];
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
#warning Implement it!
        return [TaskCell heightWithTitle:nil width:0.0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ProfileCell class]) forIndexPath:indexPath];
    cell.name.text = [PFUser currentUser].profileName;
    return cell;
}

@end
