//
//  InputCell.m
//  DYJ
//
//  Created by Timur Bernikowich on 26.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "InputCell.h"
#import "Categories.h"

@interface InputCell () <UITextFieldDelegate>

@end

@implementation InputCell

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
    // Text field.
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(self.separatorPadding, 0, self.width - 2 * self.separatorPadding, 20)];
    self.textField.centerY = self.height / 2.0;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.textField.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17];
    self.textField.delegate = self;
    [self addSubview:self.textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.delegate) {
        [self.delegate inputCellDidChangeText:self];
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate) {
        [self.delegate inputCellPressedReturn:self];
    }
    return NO;
}

@end
