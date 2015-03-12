//
//  NotificationView.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "NotificationView.h"
#import "Categories.h"
#import "TaskCellItem.h"
@import QuartzCore;

#define HEADER_HEIGHT 78.0
#define HEADER_SIDE_PADDING 15.0
#define HEADER_TEXT_PADDING 75.0
#define HEADER_AVATAR_SIZE 48.0

@interface NotificationView ()

@property UIView *contentView;
@property NSArray *borders;
@property (nonatomic) NotificationType type;
@property (nonatomic) NSArray *taskItemTypes;
@property NSArray *taskItems;
@property NSArray *separators;
@property UIImageView *avatarView;
@property UILabel *headerLabel;
@property UILabel *bodyLabel;

@end

@implementation NotificationView

- (instancetype)initWithFrame:(CGRect)frame notification:(Notification *)notification
{
    self = [self initWithFrame:frame];
    if (self) {
        [self configureView];
        self.type = NotificationTypePing;
        self.notification = notification;
    }
    return self;
}

- (void)configureView
{
    CGFloat sidePadding = 20.0;
    CGFloat titlePadding = 80.0;
    CGFloat itemsHeight = 48.0;

    // Background.
    self.backgroundColor = [UIColor whiteColor];
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.contentView];

    // Borders.
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - PIXEL, self.width, PIXEL)];
    UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(0, PIXEL, PIXEL, self.height - 2 * PIXEL)];
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, PIXEL)];
    UIView *rightBorder = [[UIView alloc] initWithFrame:CGRectMake(self.width - PIXEL, PIXEL, PIXEL, self.height - 2 * PIXEL)];
    bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    leftBorder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    rightBorder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.borders = @[bottomBorder, leftBorder, topBorder, rightBorder];
    for (UIView *border in self.borders) {
        border.backgroundColor = [UIColor colorWithColorCode:@"979797"];
        [self addSubview:border];
    }

    // Header separator.
    UIView *headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.contentView.width, PIXEL)];
    headerSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    headerSeparator.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
    [self.contentView addSubview:headerSeparator];

    // Avatar.
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(HEADER_SIDE_PADDING, HEADER_SIDE_PADDING, HEADER_AVATAR_SIZE, HEADER_AVATAR_SIZE)];
    self.avatarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    self.avatarView.layer.cornerRadius = self.avatarView.width / 2.0;
    self.avatarView.clipsToBounds = YES;
    [self.contentView addSubview:self.avatarView];

    // Header.
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_TEXT_PADDING, 0.0, self.contentView.width - HEADER_TEXT_PADDING - HEADER_SIDE_PADDING, HEADER_HEIGHT)];
    self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.headerLabel.textAlignment = NSTextAlignmentLeft;
    self.headerLabel.numberOfLines = 0;
    [self.contentView addSubview:self.headerLabel];

    // Body.
    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(sidePadding, HEADER_HEIGHT, self.contentView.width - 2 * sidePadding, self.contentView.height - HEADER_HEIGHT - itemsHeight)];
    self.bodyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:18.0];
    self.bodyLabel.numberOfLines = 0;
    [self.contentView addSubview:self.bodyLabel];
}

- (void)setNotification:(Notification *)notification
{
    _notification = notification;
    self.type = [self.notification.type integerValue];
    [self reloadItems];

    NSAttributedString *header = [self headerForNotification:notification];
    self.headerLabel.attributedText = header;

    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 5.0;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *body = [[NSAttributedString alloc] initWithString:self.notification.task.title attributes:@{NSParagraphStyleAttributeName:style}];
    self.bodyLabel.attributedText = body;

    __weak NotificationView *weakSelf = self;
    __weak Notification *weakNotification = self.notification;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakNotification.sender.profilePictureURL]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (image && weakNotification && weakSelf.notification == weakNotification) {
                weakSelf.avatarView.image = image;
            }
        });

    });
}

- (void)reloadItems
{
    for (TaskCellItem *item in self.taskItems) {
        NSInteger index = [self.taskItems indexOfObject:item];
        item.task = self.notification.task;
        item.type = [self.taskItemTypes[index] unsignedIntegerValue];
    }
}

- (void)setType:(NotificationType)type
{
    switch (type) {
        case NotificationTypePing:
            self.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid)];
            break;
        case NotificationTypeNewTask:
            self.taskItemTypes = @[@(TaskCellItemTypeTimeLeft), @(TaskCellItemTypeBid)];
            break;
        default:
            break;
    }
}

- (void)setTaskItemTypes:(NSArray *)taskItemTypes
{
    if ([_taskItemTypes isEqualToArray:taskItemTypes]) {
        return;
    } else {
        _taskItemTypes = taskItemTypes;
    }

    NSInteger numberOfTaskItems = [taskItemTypes count];
    CGFloat itemsHeight = 48.0;

    // Items.
    if (self.taskItems) {
        for (UIView *oldItem in self.taskItems) {
            [oldItem removeFromSuperview];
        }
    }
    NSMutableArray *items = [NSMutableArray new];
    for (NSInteger index = 0; index < numberOfTaskItems; index++) {
        CGFloat itemWidth = self.width / numberOfTaskItems;
        CGFloat itemOriginX = itemWidth * index;
        CGRect itemRect = CGRectMake(itemOriginX, self.height - itemsHeight, itemWidth, itemsHeight);
        itemRect = CGRectIntegral(itemRect);
        TaskCellItem *item = [TaskCellItem itemWithFrame:itemRect];
        item.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:item];
        [item addTarget:self action:@selector(taskItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:item];
    }
    self.taskItems = items;

    // Lines.
    if (self.separators) {
        for (UIView *oldSeparator in self.separators) {
            [oldSeparator removeFromSuperview];
        }
    }
    NSMutableArray *separators = [NSMutableArray new];
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - itemsHeight - PIXEL, self.width, PIXEL)];
    horizontalLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    horizontalLine.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
    [self.contentView addSubview:horizontalLine];
    [separators addObject:horizontalLine];
    for (NSInteger index = 1; index < numberOfTaskItems; index++) {
        CGFloat originX = floor(self.width * index / numberOfTaskItems);
        CGRect lineFrame = CGRectMake(originX, self.height - itemsHeight, PIXEL, itemsHeight);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
        line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:line];
        [separators addObject:line];
    }
    self.separators = separators;
}

- (NSAttributedString *)headerForNotification:(Notification *)notification
{
    NSMutableAttributedString *header;

    if ([notification.type integerValue] == NotificationTypePing) {
        NSString *sender = notification.sender.profileName;
        sender = sender ? sender : @"Friend";
        UIFont *nameFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:15.0];
        NSDictionary *nameAttributes = @{NSFontAttributeName:nameFont};
        header = [[NSMutableAttributedString alloc] initWithString:sender attributes:nameAttributes];

        UIFont *textFont = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:15.0];
        NSDictionary *textAttributes = @{NSFontAttributeName:textFont};
        NSAttributedString *reminds = [[NSAttributedString alloc] initWithString:@" reminds: " attributes:textAttributes];
        [header appendAttributedString:reminds];

        UIFont *logoFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:15.0];
        UIColor *logoColor = [UIColor colorWithColorCode:@"FF6C2F"];
        NSDictionary *logoAttributes = @{NSFontAttributeName:logoFont, NSForegroundColorAttributeName:logoColor};
        NSAttributedString *logo = [[NSAttributedString alloc] initWithString:@"Do Your Job!" attributes:logoAttributes];
        [header appendAttributedString:logo];
    } else if ([notification.type integerValue] == NotificationTypeNewTask) {
        NSString *sender = notification.sender.profileName;
        sender = sender ? sender : @"Friend";
        UIFont *nameFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:15.0];
        NSDictionary *nameAttributes = @{NSFontAttributeName:nameFont};
        header = [[NSMutableAttributedString alloc] initWithString:sender attributes:nameAttributes];

        UIFont *textFont = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:15.0];
        NSDictionary *textAttributes = @{NSFontAttributeName:textFont};
        NSAttributedString *reminds = [[NSAttributedString alloc] initWithString:@" asked you to help with:" attributes:textAttributes];
        [header appendAttributedString:reminds];
    }

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 5.0;
    [header addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, header.length)];

    return header;
}

- (void)taskItemSelected:(id)sender
{
    NSInteger index = [self.taskItems indexOfObject:sender];
}

@end