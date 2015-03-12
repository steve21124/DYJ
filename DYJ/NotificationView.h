//
//  NotificationView.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationView : UIView

- (instancetype)initWithFrame:(CGRect)frame notification:(Notification *)notification;

@property (nonatomic) Notification *notification;

@end
