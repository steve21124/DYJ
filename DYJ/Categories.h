
//
//  NSObject+PerformBlockAfterDelay.h
//  Elevator
//
//  Created by Igor Khmurets on 27.11.12.
//  Copyright (c) 2012 Igor Khmurets/Alexander Lednik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DISPLAY_IS_4_INCH ([UIScreen mainScreen].bounds.size.height == 568.0)

#define SYSTEM_VERSION_IS_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define KEYBOARD_HEIGHT 216.0
#define PIXEL 1.0 / ([UIScreen mainScreen].scale)
#define SCREEN_BOUNDS ([[UIScreen mainScreen] bounds])

#define L(str) NSLocalizedString(str, nil)
#define LOG(obj) NSLog(@"%@", obj)

#define ALERT(str) UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alertView show];
#define INFO(str) UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alertView show];

@interface NSObject (PerformBlockAfterDelay)

- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;

@end


@interface UIColor (HexColor)

+ (UIColor *)colorWithColorCode:(NSString *)colorCode;

@end

@interface UIViewController (Storyboard)

+ (id)storyboardVC;

@end

@interface UIView (Coordinates)

@property (nonatomic) CGFloat originX;
@property (nonatomic) CGFloat originY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGSize size;

@end

@interface UINavigationItem (Additions)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;
- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;
- (UIBarButtonItem *)styledRightBarButtonItem;
- (UIBarButtonItem *)styledLeftBarButtonItem;

@end

@interface NSDictionary (NonNULLObject)

- (id)nonNullObjectForKey:(id)key;

@end
