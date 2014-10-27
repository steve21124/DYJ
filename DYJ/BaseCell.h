//
//  BaseCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 27.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCell : UITableViewCell

@property (nonatomic) CGFloat separatorPadding;
@property UIView *separatorTop;
@property UIView *separatorMiddle;
@property UIView *separatorBottom;

@end
