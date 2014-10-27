//
//  FriendsJobsVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsJobsVC.h"
#import "JobCell.h"
#import "Categories.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface FriendsJobsVC () <UITableViewDataSource, UITableViewDelegate, JobCellDelegate>

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[JobCell class] forCellReuseIdentifier:NSStringFromClass([JobCell class])];
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
    [self loadTestData];
}

- (void)loadTestData
{
    NSMutableArray *tasks = [NSMutableArray new];

    self.tasks = tasks;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tasks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JobCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JobCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JobCell class]) forIndexPath:indexPath];

    cell.type = JobCellTypeNotMineCurrent;
    cell.delegate = self;

    return cell;
}

- (void)jobCellButtonPressed:(JobCell *)cell
{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }

            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            // Create our Installation query
            // Send push notification to query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" matchesQuery:friendQuery];
            [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:@"Move on!"];
        }
    }];
}

@end
