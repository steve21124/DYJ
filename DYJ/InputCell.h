//
//  InputCell.h
//  DYJ
//
//  Created by Timur Bernikowich on 26.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "BaseCell.h"

@class InputCell;

@protocol InputCellDelegate <NSObject>

- (void)inputCellDidChangeText:(InputCell *)inputCell;
- (void)inputCellPressedReturn:(InputCell *)inputCell;
- (void)inputCellDidBeginEditing:(InputCell *)inputCell;

@end

@interface InputCell : BaseCell

@property (nonatomic, weak) id <InputCellDelegate> delegate;
@property UITextField *textField;

@end
