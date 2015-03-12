//
//  NotificationActionSelector.m
//  DYJ
//
//  Created by Timur Bernikowich on 12.03.13.
//  Copyright (c) 2013 Timur Bernikowich. All rights reserved.
//

#import "NotificationActionSelector.h"
#import "Categories.h"
#import "ActionButton.h"

@import QuartzCore;

#define ITEM_SPACING 10.0

@interface NotificationActionSelector ()

@property (nonatomic) NSArray *buttons;

@end

@implementation NotificationActionSelector

- (void)addButtonWithTitle:(NSString *)title type:(NotificationActionSelectorButtonType)type
{
    NSArray *buttons = self.buttons;

    // New button.
    ActionButton *newButton = [ActionButton buttonWithType:UIButtonTypeCustom];
    if (type == NotificationActionSelectorButtonTypeDestructive) {
        newButton.defaultBackgroundColor = [UIColor colorWithColorCode:@"73BE20"];
        newButton.highlightedBackgroundColor = [UIColor colorWithColorCode:@"467C0B"];
    } else {
        newButton.defaultBackgroundColor = [UIColor colorWithColorCode:@"FF6C2F"];
        newButton.highlightedBackgroundColor = [UIColor colorWithColorCode:@"B54618"];
    }
    [newButton setTitle:title forState:UIControlStateNormal];
    [newButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newButton.layer.cornerRadius = 4.0;
    newButton.clipsToBounds = YES;
    [newButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:newButton];
    buttons = [buttons arrayByAddingObject:newButton];

    // Resizing.
    NSInteger itemCount = buttons.count;
    CGFloat itemWidth = (self.width - ITEM_SPACING * (itemCount - 1)) / itemCount;
    CGFloat offset = 0.0;
    for (UIButton *button in buttons) {
        button.frame = CGRectMake(offset, 0, itemWidth, self.height);
        offset += itemWidth + ITEM_SPACING;
    }

    self.buttons = buttons;
}

- (void)buttonPressed:(id)sender
{
    NSInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound) {
        if (self.delegate) {
            [self.delegate notificationActionSelector:self didSelectButtonAtIndex:index];
        }
    }
}

- (NSArray *)buttons
{
    if (!_buttons) {
        _buttons = @[];
    }
    return _buttons;
}

@end
