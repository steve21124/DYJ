//
//  ProfileCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 13.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "ProfileCell.h"
#import "Categories.h"

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

    // Name.
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 110.0, self.width, 22.0)];
    self.name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.name.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    self.name.textAlignment = NSTextAlignmentCenter;
    self.name.textColor = [UIColor blackColor];
    [self addSubview:self.name];

    // Balance.
    self.balance = 
}

+ (CGFloat)height
{
    return 190.0;
}

@end
