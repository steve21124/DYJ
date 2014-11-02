//
//  FriendsListVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 02.11.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsListVC.h"
#import "Categories.h"
#import "InfoCell.h"
#import "Helper.h"

@interface FriendsListVC () <UITableViewDataSource, UITableViewDelegate>

@property NSArray *friends;
@property UITableView *tableView;

@end

@implementation FriendsListVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"FRIENDS LIST";
    [self setBackButton];

    // Load friends.
    self.friends = @[];
    User *localUser = [User currentUser];
    PFRelation *friendsRelation = [localUser relationForKey:@"friends"];
    __weak FriendsListVC *weakSelf = self;
    __weak UITableView *weakTableView = self.tableView;
    [[friendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error) {
            weakSelf.friends = friends;
            [weakTableView reloadData];
        }
    }];

    // Table View.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[InfoCell class] forCellReuseIdentifier:NSStringFromClass([InfoCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoCell class]) forIndexPath:indexPath];
    User *friend = self.friends[indexPath.row];

    cell.label.text = friend.profileName;
    cell.infoLabel.text = nil;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
