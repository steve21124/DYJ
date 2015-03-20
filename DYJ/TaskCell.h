//
//  TaskCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "TaskCellItem.h"

@class TaskCell;

@protocol TaskCellDelegate <NSObject>

- (void)taskCell:(TaskCell *)taskCell didSelectItemAtIndex:(NSInteger)index;

@end

@interface TaskCell : UITableViewCell

@property (nonatomic, weak) id <TaskCellDelegate> delegate;

@property (nonatomic) NSArray *taskItemTypes;
@property (nonatomic) Task *task;
- (void)setAvatarsURLs:(NSArray *)avatars;

+ (CGFloat)heightWithTitle:(NSString *)title width:(CGFloat)width;
- (void)reloadItems;

@end
