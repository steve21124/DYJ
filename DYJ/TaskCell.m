//
//  TaskCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "TaskCell.h"
#import "TaskCellItem.h"
#import "FriendsView.h"

#define ITEMS_HEIGHT 48.0f
#define HORIZONTAL_PADDING 12.0f
#define VERTICAL_PADDING 5.0f
#define CONTENT_TOP_PADDING 15.0f
#define CONTENT_HORIZONTAL_PADDING 15.0f
#define CONTENT_SPACING 8.0f
#define AVATARS_VIEW_HEIGHT 24.0f

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

    // Background.
    CGRect backgroundFrame = self.bounds;
    backgroundFrame.origin.x = HORIZONTAL_PADDING;
    backgroundFrame.origin.y = VERTICAL_PADDING;
    backgroundFrame.size.height -= 2 * VERTICAL_PADDING;
    backgroundFrame.size.width -= 2 * HORIZONTAL_PADDING;
    self.background = [[UIView alloc] initWithFrame:backgroundFrame];
    self.background.backgroundColor = [UIColor whiteColor];
    self.background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.background];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];

    // Title.
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_HORIZONTAL_PADDING, 0.0f, self.background.width - 2 * CONTENT_HORIZONTAL_PADDING, 0.0f)];
    self.title.height = self.background.height - CONTENT_TOP_PADDING - CONTENT_SPACING - AVATARS_VIEW_HEIGHT - CONTENT_SPACING - ITEMS_HEIGHT;
    self.title.originY = CONTENT_TOP_PADDING;
    self.title.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.title.numberOfLines = 0;
    [self.background addSubview:self.title];

    // Avatars.
    self.avatars = [[FriendsView alloc] initWithFrame:CGRectMake(CONTENT_HORIZONTAL_PADDING, 0.0f, self.background.width - 2 * CONTENT_HORIZONTAL_PADDING, AVATARS_VIEW_HEIGHT)];
    self.avatars.originY = self.background.height - ITEMS_HEIGHT - self.avatars.height - CONTENT_SPACING;
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
        CGRect itemRect = CGRectMake(itemOriginX, self.background.height - ITEMS_HEIGHT, itemWidth, ITEMS_HEIGHT);
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
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.background.height - ITEMS_HEIGHT - PIXEL, self.background.width, PIXEL)];
    horizontalLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    horizontalLine.backgroundColor = [UIColor colorWithColorCode:@"E8E8E8"];
    [self.background addSubview:horizontalLine];
    [separators addObject:horizontalLine];
    for (NSInteger index = 1; index < numberOfTaskItems; index++) {
        CGFloat originX = floor(self.background.width * index / numberOfTaskItems);
        CGRect lineFrame = CGRectMake(originX, self.background.height - ITEMS_HEIGHT, PIXEL, ITEMS_HEIGHT);
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
    self.title.height = self.background.height - 15.0 - 8.0 - 24.0 - 8.0 - ITEMS_HEIGHT;
    self.title.attributedText = [[NSAttributedString alloc] initWithString:title attributes:[TaskCell titleAttributes]];
}

+ (NSDictionary *)titleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16.0f];
    UIColor *color = [UIColor blackColor];
    return @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color};
}

+ (CGFloat)heightWithTitle:(NSString *)title width:(CGFloat)width
{
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:title attributes:[self titleAttributes]];
    CGRect rect = [attributed boundingRectWithSize:CGSizeMake(width - 2 * (HORIZONTAL_PADDING + CONTENT_HORIZONTAL_PADDING), MAXFLOAT) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) context:nil];

    return ceil(rect.size.height + CONTENT_TOP_PADDING + CONTENT_SPACING + AVATARS_VIEW_HEIGHT + CONTENT_SPACING + ITEMS_HEIGHT + 2 * VERTICAL_PADDING);
}

@end
