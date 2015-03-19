//
//  TaskCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "TaskCell.h"
#import "TaskCellItem.h"
#import "Categories.h"
#import "FriendsView.h"

@interface TaskCell ()

@property UIView *background;
@property UILabel *title;
@property FriendsView *avatars;
@property NSArray *taskItems;
@property NSArray *separators;

@end

@implementation TaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat sidePadding = 12.0;
    CGFloat padding = 10.0;
    CGFloat itemsHeight = 48.0;

    // Background.
    CGRect backgroundFrame = self.bounds;
    backgroundFrame.origin.x = sidePadding;
    backgroundFrame.origin.y = padding / 2.0;
    backgroundFrame.size.height -= padding;
    backgroundFrame.size.width -= 2 * sidePadding;
    self.background = [[UIView alloc] initWithFrame:backgroundFrame];
    self.background.backgroundColor = [UIColor whiteColor];
    self.background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.background];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];

    // Title.
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, self.background.width - 30.0, 0)];
    self.title.height = self.background.height - 15.0 - 8.0 - 24.0 - 8.0 - itemsHeight;
    self.title.originY = 15.0;
    self.title.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.title.numberOfLines = 0;
    [self.background addSubview:self.title];

    // Avatars.
    self.avatars = [[FriendsView alloc] initWithFrame:CGRectMake(15.0, 0, self.background.width - 30.0, 24)];
    self.avatars.originY = self.background.height - itemsHeight - self.avatars.height - 8.0;
    self.avatars.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.background addSubview:self.avatars];
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
        CGFloat itemWidth = self.background.width / numberOfTaskItems;
        CGFloat itemOriginX = itemWidth * index;
        CGRect itemRect = CGRectMake(itemOriginX, self.background.height - itemsHeight, itemWidth, itemsHeight);
        itemRect = CGRectIntegral(itemRect);
        TaskCellItem *item = [TaskCellItem itemWithFrame:itemRect];
        item.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.background addSubview:item];
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
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.background.height - itemsHeight - PIXEL, self.background.width, PIXEL)];
    horizontalLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    horizontalLine.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
    [self.background addSubview:horizontalLine];
    [separators addObject:horizontalLine];
    for (NSInteger index = 1; index < numberOfTaskItems; index++) {
        CGFloat originX = floor(self.background.width * index / numberOfTaskItems);
        CGRect lineFrame = CGRectMake(originX, self.background.height - itemsHeight, PIXEL, itemsHeight);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
        line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.background addSubview:line];
        [separators addObject:line];
    }
    self.separators = separators;
}

- (void)taskItemSelected:(id)sender
{
    NSInteger index = [self.taskItems indexOfObject:sender];
    if (self.delegate) {
        [self.delegate taskCell:self didSelectItemAtIndex:index];
    }
}

- (void)setAvatarsURLs:(NSArray *)avatars
{
    self.avatars.avatarsURLs = avatars;
}

- (void)setTask:(Task *)task
{
    _task = task;
    [self setTaskTitle:self.task.title];
    [self reloadItems];
}

- (void)reloadItems
{
    for (TaskCellItem *item in self.taskItems) {
        NSInteger index = [self.taskItems indexOfObject:item];
        item.task = self.task;
        item.type = [self.taskItemTypes[index] unsignedIntegerValue];
    }
}

- (void)setTaskTitle:(NSString *)title
{
    CGFloat sidePadding = 12.0;
    CGFloat padding = 10.0;
    CGFloat itemsHeight = 48.0;
    NSInteger numberOfTaskItems = 3;

    self.title.height = self.background.height - 15.0 - 8.0 - 24.0 - 8.0 - itemsHeight;
    self.title.attributedText = [[NSAttributedString alloc] initWithString:title attributes:[TaskCell titleAttributes]];
}

+ (NSDictionary *)titleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16];
    UIColor *color = [UIColor blackColor];
    return @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color};
}

+ (CGFloat)heightWithTitle:(NSString *)title width:(CGFloat)width
{
    CGFloat sidePadding = 12.0;
    CGFloat padding = 10.0;
    CGFloat itemsHeight = 48.0;

    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:title attributes:[self titleAttributes]];
    CGRect rect = [attributed boundingRectWithSize:CGSizeMake(width - 2 * (padding + sidePadding), MAXFLOAT) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) context:nil];

    return ceil(rect.size.height + 15 + 8 + 24 + 8 + itemsHeight + padding);
}

@end
