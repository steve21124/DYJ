//
//  InfoCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 27.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

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
    // Labels.
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.separatorPadding, 0, self.width - 2 * self.separatorPadding, 20)];
    self.label.centerY = self.height / 2.0;
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.label.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17];
    [self addSubview:self.label];
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.separatorPadding, 0, self.width - 2 * self.separatorPadding, 20)];
    self.infoLabel.centerY = self.height / 2.0;
    self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17];
    self.infoLabel.textColor = [UIColor colorWithColorCode:@"8E8E93"];
    self.infoLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.infoLabel];
}

@end