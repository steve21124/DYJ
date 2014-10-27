//
//  NavigationVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "NavigationVC.h"
#import "Categories.h"

@interface NavigationVC ()

@end

@implementation NavigationVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSShadowAttributeName : shadow, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:14]};
}

@end
