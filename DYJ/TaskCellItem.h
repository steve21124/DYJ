//
//  TaskCellItem.h
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

typedef NS_ENUM(NSUInteger, TaskCellItemType) {
    TaskCellItemTypeTimeLeft,
    TaskCellItemTypeBid,
    TaskCellItemTypeRemindButton,
    TaskCellItemTypeRemindStatus,
    TaskCellItemTypeTaskStatusButton,
    TaskCellItemTypeTaskStatus,
    TaskCellItemTypeLoading,
    TaskCellItemTypesCount
};

@interface TaskCellItem : UIButton

+ (instancetype)itemWithFrame:(CGRect)frame;

@property (nonatomic, readonly) TaskCellItemType type;
@property (nonatomic, readonly) Task *task;

@end
