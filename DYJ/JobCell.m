//
//  JobCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "JobCell.h"
#import "Categories.h"
@import QuartzCore;

@implementation JobCell

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
    // Tag.
    self.tagColor = [UIColor yellowColor];
    CGFloat circleRadius = 16.0;
    self.tagCircle = [[UIView alloc] initWithFrame:CGRectMake(12, 12, 2 * circleRadius, 2 * circleRadius)];
    self.tagCircle.layer.cornerRadius = circleRadius;
    self.tagCircle.backgroundColor = self.tagColor;
    [self addSubview:self.tagCircle];

    // Image.
    self.tagIcon = [[UIImageView alloc] initWithFrame:self.tagCircle.bounds];
    self.tagIcon.backgroundColor = [UIColor clearColor];
    [self.tagCircle addSubview:self.tagIcon];

    // Right view.
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(self.width - 64, 0, 64, self.height);
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:16];
    [self.rightButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
    self.type = JobCellTypeMineCurrent;

    // Label.
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(self.tagCircle.originX + self.tagCircle.width + 12, self.tagCircle.originY, self.width - (self.tagCircle.originX + self.tagCircle.width + 12 + 64), self.tagCircle.height)];
    self.title.font = [UIFont fontWithName:@"Roboto-Condensed" size:16];
    self.title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.title.textColor = [UIColor colorWithColorCode:@"81929f"];
    [self addSubview:self.title];

    // Separator.
    self.separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1 / [UIScreen mainScreen].scale)];
    self.separatorBottom.originY = self.height - self.separatorBottom.height;
    self.separatorBottom.backgroundColor = [UIColor colorWithColorCode:@"edf0f2"];
    self.separatorBottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.separatorBottom];
}

- (void)buttonPressed:(id)sender
{
    [self.delegate jobCellButtonPressed:self];
}

- (void)setTagColor:(UIColor *)tagColor
{
    _tagColor = tagColor;
    self.tagCircle.backgroundColor = self.tagColor;
}

- (void)setType:(JobCellType)type
{
    _type = type;
    switch (type) {
        case JobCellTypeMineCurrent:
            self.rightButton.backgroundColor = [UIColor colorWithColorCode:@"8aefb2"];
            [self.rightButton setTitle:@"Done?" forState:UIControlStateNormal];
            break;
        case JobCellTypeNotMineCurrent:
            self.rightButton.backgroundColor = [UIColor colorWithColorCode:@"ffcc66"];
            [self.rightButton setTitle:@"Push!" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

+ (CGFloat)height
{
    return 56.0;
}

@end