//
//  UIColor+Customization.m
//  DYJ
//
//  Created by Timur Bernikowich on 21.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import "Customization.h"

@implementation UIColor (Customization)

+ (UIColor *)mainAppColor
{
    return [UIColor colorWithColorCode:@"FF6C2F"];
}

+ (UIColor *)mainSelectedAppColor
{
    return [UIColor colorWithColorCode:@"B54618"];
}

+ (UIColor *)secondaryAppColor
{
    return [UIColor colorWithColorCode:@"73BE20"];
}

+ (UIColor *)secondarySelectedAppColor
{
    return [UIColor colorWithColorCode:@"467C0B"];
}

+ (UIColor *)separatorColor
{
    return [UIColor colorWithColorCode:@"CCCCCC"];
}

@end