//
//  HintView.h
//  DYJ
//
//  Created by Timur Bernikowich on 19.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintView : UIView

@property (nonatomic) CGFloat sidePadding;

- (void)setTitleLabelText:(NSString *)text;
- (void)setDescriptionLabelText:(NSString *)text;

@end
