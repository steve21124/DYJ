//
//  BaseVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 02.11.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "BaseVC.h"
#import "Categories.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backButtonImage = [UIImage imageNamed:@"BackButton"];
    CGRect backButtonFrame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
    backButton.frame = backButtonFrame;
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem addLeftBarButtonItem:backBarButton];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
