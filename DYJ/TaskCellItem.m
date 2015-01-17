//
//  TaskCellItem.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "TaskCellItem.h"
#import "Categories.h"

@interface TaskCellItem ()

@property (nonatomic, readwrite) NSArray *objects;

@property (nonatomic) UIColor *defaultBackgroundColor;
@property (nonatomic) UIColor *highlightedBackgroundColor;

@end

@implementation TaskCellItem

+ (instancetype)itemWithFrame:(CGRect)frame
{
    TaskCellItem *item = [TaskCellItem buttonWithType:UIButtonTypeCustom];
    item.frame = frame;
    item.type = TaskCellItemTypeLoading;
    return item;
}

- (void)setType:(TaskCellItemType)type
{
    _type = type;
    [self updateView];
}

- (void)setTask:(Task *)task
{
    _task = task;
    [self updateView];
}

- (void)updateView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    self.defaultBackgroundColor = [UIColor whiteColor];
    self.highlightedBackgroundColor = [UIColor whiteColor];

    // By default item is unselectable.
    self.userInteractionEnabled = NO;
    
    switch (self.type) {
        case TaskCellItemTypeLoading: {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = CGPointMake(self.width / 2.0, self.height / 2.0);
            activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [activityIndicator startAnimating];
            [self addSubview:activityIndicator];
            break;
        }
        case TaskCellItemTypeTimeLeft: {
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, self.width, 20)];
            timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            timeLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:16];
            timeLabel.textColor = [UIColor colorWithColorCode:@"D0021B"];
            timeLabel.textAlignment = NSTextAlignmentCenter;
            timeLabel.text = [self timeLeftToDate:self.task.expiration];
            [self addSubview:timeLabel];
            UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, self.width, 12)];
            leftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            leftLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:10];
            leftLabel.textColor = [UIColor colorWithColorCode:@"979797"];
            leftLabel.textAlignment = NSTextAlignmentCenter;
            leftLabel.text = @"LEFT";
            [self addSubview:leftLabel];
            break;
        }
        case TaskCellItemTypeBid: {
            UILabel *motivesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, self.width, 20)];
            motivesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            motivesLabel.textColor = [UIColor colorWithColorCode:@"FFB838"];
            motivesLabel.textAlignment = NSTextAlignmentCenter;
            motivesLabel.attributedText = [self motivesStringWithMotives:self.task.reward];
            [self addSubview:motivesLabel];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, self.width, 12)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:10];
            titleLabel.textColor = [UIColor colorWithColorCode:@"979797"];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"BID";
            [self addSubview:titleLabel];
            break;
        }
        case TaskCellItemTypeRemindButton: {
            self.defaultBackgroundColor = [UIColor colorWithColorCode:@"FF6C2F"];
            self.highlightedBackgroundColor = [UIColor colorWithColorCode:@"B54618"];
            self.userInteractionEnabled = YES;
            UILabel *actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.width, 22)];
            actionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            actionLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:18];
            actionLabel.textColor = [UIColor colorWithColorCode:@"F8F8F8"];
            actionLabel.textAlignment = NSTextAlignmentCenter;
            actionLabel.text = @"Do";
            [self addSubview:actionLabel];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, self.width, 12)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:10];
            titleLabel.textColor = [UIColor colorWithColorCode:@"F8F8F8"];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"REMIND";
            titleLabel.alpha = 0.6;
            [self addSubview:titleLabel];
            break;
        }
        case TaskCellItemTypeTaskStatusButton: {
            self.defaultBackgroundColor = [UIColor colorWithColorCode:@"73BE20"];
            self.highlightedBackgroundColor = [UIColor colorWithColorCode:@"467C0B"];
            self.userInteractionEnabled = YES;
            UILabel *actionLabel = [[UILabel alloc] initWithFrame:self.bounds];
            actionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            actionLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:18];
            actionLabel.textColor = [UIColor whiteColor];
            actionLabel.textAlignment = NSTextAlignmentCenter;
            actionLabel.text = @"Finished?";
            [self addSubview:actionLabel];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Selection

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor
{
    _defaultBackgroundColor = defaultBackgroundColor;
    [self updateSelection];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor
{
    _highlightedBackgroundColor = highlightedBackgroundColor;
    [self updateSelection];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateSelection];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateSelection];
}

- (void)updateSelection
{
    if (self.highlighted || self.selected) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
    }
}

#pragma mark - Helpers

- (NSString *)timeLeftToDate:(NSDate *)date
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval toDate = [date timeIntervalSinceReferenceDate];
    NSTimeInterval timeLeft = toDate - now;
    
    NSTimeInterval second = 1;
    NSTimeInterval minute = second * 60;
    NSTimeInterval hour = minute * 60;
    NSTimeInterval day = hour * 24;
    NSTimeInterval week = day * 7;
    NSTimeInterval month = week * 4;
    
    NSString *timeLeftString;
    if (timeLeft >= 2 * month) {
        timeLeftString = [NSString stringWithFormat:@"%ld months", (long)(timeLeft / month)];
    } else if (timeLeft >= month) {
        timeLeftString = [NSString stringWithFormat:@"%ld month", (long)(timeLeft / month)];
    } else if (timeLeft >= 2 * week) {
        timeLeftString = [NSString stringWithFormat:@"%ld weeks", (long)(timeLeft / week)];
    } else if (timeLeft >= week) {
        timeLeftString = [NSString stringWithFormat:@"%ld week", (long)(timeLeft / week)];
    } else if (timeLeft >= 2 * day) {
        timeLeftString = [NSString stringWithFormat:@"%ld days", (long)(timeLeft / day)];
    } else if (timeLeft >= day) {
        timeLeftString = [NSString stringWithFormat:@"%ld day", (long)(timeLeft / day)];
    } else if (timeLeft >= 2 * hour) {
        timeLeftString = [NSString stringWithFormat:@"%ld hours", (long)(timeLeft / hour)];
    } else if (timeLeft >= hour) {
        timeLeftString = [NSString stringWithFormat:@"%ld hour", (long)(timeLeft / hour)];
    } else if (timeLeft >= 2 * minute) {
        timeLeftString = [NSString stringWithFormat:@"%ld minutes", (long)(timeLeft / minute)];
    } else if (timeLeft >= minute) {
        timeLeftString = [NSString stringWithFormat:@"%ld minute", (long)(timeLeft / minute)];
    } else if (timeLeft >= 2 * second) {
        timeLeftString = [NSString stringWithFormat:@"%ld seconds", (long)(timeLeft / second)];
    } else if (timeLeft >= second) {
        timeLeftString = [NSString stringWithFormat:@"%ld second", (long)(timeLeft / second)];
    } else {
        timeLeftString = @"no time";
    }
    
    return timeLeftString;
}

- (NSAttributedString *)motivesStringWithMotives:(NSNumber *)motives
{
    NSMutableAttributedString *motivesString;
    
    NSString *bid = [NSString stringWithFormat:@"%ld", (long)[motives integerValue]];
    NSString *space = @" ";
    NSString *title = ([motives integerValue] > 1) ? @"motives" : @"motive";
    
    UIFont *bidFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:16];
    UIFont *spaceFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:14];
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:12];
    
    motivesString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", bid, space, title]];
    
    [motivesString addAttribute:NSFontAttributeName value:bidFont range:NSMakeRange(0, [bid length])];
    [motivesString addAttribute:NSFontAttributeName value:spaceFont range:NSMakeRange([bid length], [space length])];
    [motivesString addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange([bid length] + [space length], [title length])];
    
    return motivesString;
}

@end