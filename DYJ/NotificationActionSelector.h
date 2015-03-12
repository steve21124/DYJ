//
//  NotificationActionSelector.h
//  DYJ
//
//  Created by Timur Bernikowich on 12.03.13.
//  Copyright (c) 2013 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

typedef NS_ENUM(NSUInteger, NotificationActionSelectorButtonType){
    NotificationActionSelectorButtonTypeDefault,
    NotificationActionSelectorButtonTypeDestructive,
    NotificationActionSelectorButtonTypesCount
};

@class NotificationActionSelector;

@protocol NotificationActionSelectorDelegate <NSObject>

- (void)notificationActionSelector:(NotificationActionSelector *)selector didSelectButtonAtIndex:(NSInteger)index;

@end

@interface NotificationActionSelector : UIView

@property (nonatomic, weak) id <NotificationActionSelectorDelegate> delegate;
@property (nonatomic) Notification *notification;

- (void)addButtonWithTitle:(NSString *)title type:(NotificationActionSelectorButtonType)type;

@end