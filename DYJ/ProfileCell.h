//
//  ProfileCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 13.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property UIImageView *avatar;
@property UILabel *name;
@property UILabel *balance;

+ (CGFloat)height;

@end
