//
//  ActionButton.m
//  DYJ
//
//  Created by Timur Bernikowich on 12.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "ActionButton.h"

@implementation ActionButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    ActionButton *button = [super buttonWithType:buttonType];
    button.defaultBackgroundColor = [UIColor grayColor];
    button.highlightedBackgroundColor = [UIColor blackColor];
    return button;
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

@end
