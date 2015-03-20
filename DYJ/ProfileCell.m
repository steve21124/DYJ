//
//  ProfileCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 13.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "ProfileCell.h"
@import QuartzCore;

@implementation ProfileCell

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
    self.backgroundColor = [UIColor clearColor];

    // Avatar.
    self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 30.0, 75.0, 75.0)];
    self.avatar.centerX = self.width / 2.0;
    self.avatar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    self.avatar.layer.cornerRadius = self.avatar.width / 2.0;
    self.avatar.clipsToBounds = YES;
    [self addSubview:self.avatar];

    // Name.
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 110.0, self.width, 22.0)];
    self.name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.name.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    self.name.textAlignment = NSTextAlignmentCenter;
    self.name.textColor = [UIColor blackColor];
    [self addSubview:self.name];

    // Balance.
    self.balance = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 140.0, self.width, 20.0)];
    self.balance.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.balance.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    self.balance.textAlignment = NSTextAlignmentCenter;
    self.balance.textColor = [UIColor colorWithColorCode:@"FFB838"];
    [self addSubview:self.balance];
}

+ (CGFloat)height
{
    return 186.0;
}

@end
