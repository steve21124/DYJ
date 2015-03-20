//
//  BaseCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 27.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureBase];
    }
    return self;
}

- (void)configureBase
{
    // Selection.
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // Separators.
    _separatorPadding = 15;
    self.separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, PIXEL)];
    self.separatorTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.separatorTop];
    self.separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - PIXEL, self.width, PIXEL)];
    self.separatorBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.separatorBottom];
    self.separatorMiddle = [[UIView alloc] initWithFrame:CGRectMake(self.separatorPadding, self.height - PIXEL, self.width - self.separatorPadding, PIXEL)];
    self.separatorMiddle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.separatorTop.backgroundColor = self.separatorMiddle.backgroundColor = self.separatorBottom.backgroundColor = [UIColor separatorColor];
    [self addSubview:self.separatorMiddle];
}

- (void)prepareForReuse
{
    self.separatorTop.hidden = NO;
    self.separatorMiddle.hidden = YES;
    self.separatorBottom.hidden = NO;
}

@end
