//
//  HintView.m
//  DYJ
//
//  Created by Timur Bernikowich on 19.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "HintView.h"
#import "Categories.h"

@interface HintView ()

@property UIView *contentView;
@property UILabel *titleLabel;
@property UILabel *descriptionLabel;

@end

@implementation HintView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.backgroundColor = [UIColor clearColor];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width - 2 * self.sidePadding, 76.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    contentView.center = CGPointMake(self.width / 2.0, self.height / 2.0);
    contentView.backgroundColor = [UIColor clearColor];
    self.contentView = contentView;
    [self addSubview:self.contentView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.contentView.width, 28.0f)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:26.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithColorCode:@"666666"];
    self.titleLabel = titleLabel;
    [self.contentView addSubview:self.titleLabel];

    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.contentView.height - 42.0f, contentView.width, 42.0f)];
    descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17.0f];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [UIColor colorWithColorCode:@"666666"];
    self.descriptionLabel = descriptionLabel;
    [self.contentView addSubview:self.descriptionLabel];
}

- (void)setSidePadding:(CGFloat)sidePadding
{
    _sidePadding = sidePadding;

    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.width = self.width - 2 * sidePadding;
    self.contentView.frame = contentFrame;
    self.contentView.center = CGPointMake(self.width / 2.0, self.height / 2.0);
}

- (void)setTitleLabelText:(NSString *)text
{
    self.titleLabel.text = text;
}

- (void)setDescriptionLabelText:(NSString *)text
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *description = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    self.descriptionLabel.attributedText = description;
}

@end
