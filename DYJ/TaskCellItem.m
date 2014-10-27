//
//  TaskCellItem.m
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "TaskCellItem.h"
#import "Categories.h"

@interface TaskCellItem ()

@property (nonatomic, readwrite) TaskCellItemType type;
@property (nonatomic, readwrite) NSArray *objects;

@end

@implementation TaskCellItem

+ (instancetype)itemWithFrame:(CGRect)frame
{
    TaskCellItem *item = [TaskCellItem buttonWithType:UIButtonTypeCustom];
    item.frame = frame;
    item.type = TaskCellItemTypeLoading;
    return item;
}

- (void)setType:(TaskCellItemType)type
{
    _type = type;
    [self updateView];
}

- (void)setTask:(Task *)task
{
    _task = task;
    [self updateView];
}

- (void)updateView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];

    switch (self.type) {
        case TaskCellItemTypeLoading: {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = CGPointMake(self.width / 2.0, self.height / 2.0);
            [activityIndicator startAnimating];
            [self addSubview:activityIndicator];
            break;
        }
        default:
            break;
    }
}

@end
