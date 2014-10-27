//
//  JobCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JobCellType) {
    JobCellTypeMineCurrent,
    JobCellTypeNotMineCurrent,
    JobCellTypeMineSuccess,
    JobCellTypeMineFailure,
    JobCellTypesCount
};

@class JobCell;

@protocol JobCellDelegate <NSObject>

- (void)jobCellButtonPressed:(JobCell *)cell;

@end

@interface JobCell : UITableViewCell

@property (nonatomic, weak) id <JobCellDelegate> delegate;

@property (nonatomic) JobCellType type;
@property (nonatomic) UIColor *tagColor;

@property UILabel *title;
@property UIView *tagCircle;
@property UIImageView *tagIcon;
@property UILabel *about;
@property UIView *rightView;
@property UIButton *rightButton;

@property UIView *separatorBottom;

+ (CGFloat)height;

@end
