//
//  TaskCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

- (void)setTaskTitle:(NSString *)title;

+ (CGFloat)heightWithTitle:(NSString *)title width:(CGFloat)width;

@end
