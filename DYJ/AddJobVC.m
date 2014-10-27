//
//  AddJobVC.m
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "AddJobVC.h"
#import "Categories.h"
#import "Task.h"
#import "InputCell.h"
#import "InfoCell.h"

NSString *const TaskTitleKey = @"TaskTitleKey";
NSString *const TaskDescriptionKey = @"TaskDescriptionKey";
NSString *const TaskDateKey = @"TaskDateKey";
NSString *const TaskBidKey = @"TaskBidKey";

typedef NS_ENUM(NSUInteger, VCSection) {
    VCSectionTitles,
    VCSectionDate,
    VCSectionBids,
    VCSectionFriends,
    VCSectionsCount
};

typedef NS_ENUM(NSUInteger, VCSectionTitlesRow) {
    VCSectionTitlesRowName,
    VCSectionTitlesRowDescription,
    VCSectionTitlesRowsCount
};

typedef NS_ENUM(NSUInteger, VCSectionDateRow) {
    VCSectionDateRowExpiration,
    VCSectionDateRowsCount
};

@interface AddJobVC () <UITableViewDataSource, UITableViewDelegate, InputCellDelegate>

@property NSMutableDictionary *taskDictionary;
@property UITableView *tableView;
@property UIView *datePicker;
@property (nonatomic) CGFloat keyboardPadding;
@property (nonatomic) CGFloat datePickerPadding;
@property (nonatomic) CGFloat motivesPickerPadding;

@end

@implementation AddJobVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"PLAN A NEW JOB";
    self.taskDictionary = [NSMutableDictionary new];

    // Close button.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeButtonImage = [UIImage imageNamed:@"Close Left"];
    CGRect closeButtonFrame = CGRectMake(0, 0, closeButtonImage.size.width, closeButtonImage.size.height);
    closeButton.frame = closeButtonFrame;
    [closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButton;

    // Add button.
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    [self updateAddButton];

    // Table View.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor colorWithColorCode:@"EAEAEA"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[InputCell class] forCellReuseIdentifier:NSStringFromClass([InputCell class])];
    [self.tableView registerClass:[InfoCell class] forCellReuseIdentifier:NSStringFromClass([InfoCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TestCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    // Subscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardMoved:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardMoved:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardMoved:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat newKeyboardPadding = [UIApplication sharedApplication].keyWindow.height - [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    [self setKeyboardPadding:newKeyboardPadding animated:YES];
}

- (void)setKeyboardPadding:(CGFloat)keyboardPadding animated:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.keyboardPadding = keyboardPadding;
    } completion:nil];
}

- (void)setKeyboardPadding:(CGFloat)keyboardPadding
{
    _keyboardPadding = keyboardPadding;
    [self updateTableView];
}

- (void)setDatePickerPadding:(CGFloat)datePickerPadding
{
    _datePickerPadding = datePickerPadding;
    [self updateTableView];
}

- (void)setMotivesPickerPadding:(CGFloat)motivesPickerPadding
{
    _motivesPickerPadding = motivesPickerPadding;
    [self updateTableView];
}

- (void)updateTableView
{
    UIEdgeInsets newInsets = self.tableView.contentInset;
    newInsets.bottom = MAX(self.keyboardPadding, MAX(self.datePickerPadding, self.motivesPickerPadding));
    self.tableView.contentInset = newInsets;
    self.tableView.scrollIndicatorInsets = newInsets;
}

- (BOOL)dataAreCorrect
{
    NSString *title = self.taskDictionary[TaskTitleKey];
    NSString *taskDescription = self.taskDictionary[TaskDescriptionKey];
    NSDate *expired = self.taskDictionary[TaskDateKey];
    return ([title length] && [taskDescription length] && expired);
}

- (void)updateAddButton
{
    if ([self dataAreCorrect]) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithColorCode:@"FF6C2F"];
    } else {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithColorCode:@"CCCCCC"];
    }
}

- (void)closeButtonPressed:(id)sender
{
    if (self.delegate) {
        [self.delegate addJobVCDidCancel:self];
    }
}

- (void)addButtonPressed:(id)sender
{
    if (![self dataAreCorrect]) {
        return;
    }

    Task *newTask = [Task new];
    newTask.title = self.taskDictionary[TaskTitleKey];
    newTask.taskDescription = self.taskDictionary[TaskDescriptionKey];
    newTask.creator = [PFUser currentUser];
    newTask.expiration = self.taskDictionary[TaskDateKey];
    newTask.reward = @(10);
    [newTask save];
    if (self.delegate) {
        [self.delegate addJobVCDidFinish:self];
    }
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VCSectionsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 36)];
    view.clipsToBounds = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.font = [UIFont fontWithName:@"HelveticaNeueCyr-Medium" size:14];
    label.textColor = [UIColor colorWithColorCode:@"8E8E93"];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];

    switch (section) {
        case VCSectionTitles:
            label.text = @"NAME";
            break;
        case VCSectionDate:
            label.text = @"DEADLINE";
            break;
        case VCSectionBids:
            label.text = @"HOW MANY MOTIVES CAN YOU BID?";
            break;
        case VCSectionFriends:
            label.text = @"CHOOSE FRIENDS TO SUPPORT YOU";
            break;
        default:
            break;
    }
    [label sizeToFit];
    label.originX = 15;
    label.originY = view.height - label.height - 5;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case VCSectionTitles:
            return 2;
        case VCSectionDate:
            return 1;
        case VCSectionBids:
            return 1;
        case VCSectionFriends:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *resultCell;
    switch (indexPath.section) {
        case VCSectionTitles:
        {
            InputCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputCell class]) forIndexPath:indexPath];
            switch (indexPath.row) {
                case VCSectionTitlesRowName:
                    cell.textField.placeholder = @"Your task title";
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    break;
                case VCSectionTitlesRowDescription:
                    cell.textField.placeholder = @"Describe your task here";
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    break;
            }
            cell.separatorTop.hidden = (indexPath.row != 0);
            cell.separatorMiddle.hidden = (indexPath.row == VCSectionTitlesRowsCount - 1);
            cell.separatorBottom.hidden = (indexPath.row != VCSectionTitlesRowsCount - 1);
            cell.delegate = self;
            resultCell = cell;
            break;
        }
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];
            resultCell = cell;
            break;
        }
        case VCSectionDate:
        {
            switch (indexPath.row) {
                case VCSectionTitlesRowName:
                {
                    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoCell class]) forIndexPath:indexPath];
                    cell.label.text = @"Day and time";
                    static NSDateFormatter *dateFormatter;
                    if (!dateFormatter) {
                        dateFormatter = [NSDateFormatter new];
                        dateFormatter.dateStyle = NSDateIntervalFormatterShortStyle;
                        dateFormatter.timeStyle = NSDateIntervalFormatterShortStyle;
                    }
                    cell.infoLabel.text = self.taskDictionary[TaskDateKey] ? [dateFormatter stringFromDate:self.taskDictionary[TaskDateKey]] : @"Till date";
                    resultCell = cell;
                }
            }
        }
    }

    return resultCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case VCSectionTitles:
        {
            switch (indexPath.row) {
                case VCSectionTitlesRowName: {
                    InputCell *cell = (InputCell *)[tableView cellForRowAtIndexPath:indexPath];
                    [cell.textField becomeFirstResponder];
                    break;
                }
                case VCSectionTitlesRowDescription: {
                    InputCell *cell = (InputCell *)[tableView cellForRowAtIndexPath:indexPath];
                    [cell.textField becomeFirstResponder];
                    break;
                }
            }
            break;
        }
        case VCSectionDate:
        {
            if (self.datePicker) {
                [self datePickerDoneButtonPressed:nil];
                return;
            }

            UIDatePicker *datePicker = [UIDatePicker new];
            datePicker.backgroundColor = [UIColor whiteColor];
            datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:5 * 60];
            datePicker.origin = CGPointMake(0, self.view.height);
            [datePicker addTarget:self action:@selector(datePickerChangedDate:) forControlEvents:UIControlEventValueChanged];

            CGRect pickerFrame = datePicker.bounds;
            pickerFrame.size.height += 44.0;
            datePicker.originY = 44.0;
            UIView *pickerView = [[UIView alloc] initWithFrame:pickerFrame];
            pickerView.backgroundColor = [UIColor whiteColor];
            self.datePicker = pickerView;

            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            [done setTitle:@"Done" forState:UIControlStateNormal];
            [done setTitleColor:[UIColor colorWithColorCode:@"FF6C2F"] forState:UIControlStateNormal];
            done.frame = CGRectMake(pickerView.width - 100, 0, 100, 44);
            [done addTarget:self action:@selector(datePickerDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [pickerView addSubview:done];

            NSDate *defaultDate = [NSDate dateWithTimeIntervalSinceNow:3 * 24 * 60 * 60];
            self.taskDictionary[TaskDateKey] = defaultDate;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
            [datePicker setDate:defaultDate animated:YES];
            [pickerView addSubview:datePicker];
            pickerView.originY = self.view.height;
            [self.view addSubview:pickerView];
            [UIView animateWithDuration:0.3 animations:^(){
                pickerView.origin = CGPointMake(0, self.view.height - pickerView.height);
                self.datePickerPadding = pickerView.height;
            }];
        }
    }
}

- (void)datePickerDoneButtonPressed:(UIButton *)sender
{
    UIView *view = self.datePicker;
    [UIView animateWithDuration:0.3 animations:^() {
        view.originY = view.superview.height;
        self.datePickerPadding = 0;
    } completion:^(BOOL complete) {
        [view removeFromSuperview];
        self.datePicker = nil;
    }];
}

- (void)datePickerChangedDate:(UIDatePicker *)sender
{
    NSDate *newDate = sender.date;
    self.taskDictionary[TaskDateKey] = newDate;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)inputCellDidChangeText:(InputCell *)inputCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:inputCell];
    switch (indexPath.section) {
        case VCSectionTitles: {
            switch (indexPath.row) {
                case VCSectionTitlesRowName: {
                    self.taskDictionary[TaskTitleKey] = inputCell.textField.text;
                    break;
                }
                case VCSectionTitlesRowDescription: {
                    self.taskDictionary[TaskDescriptionKey] = inputCell.textField.text;
                    break;
                }
            }
            break;
        }
    }
    [self updateAddButton];
}

- (void)inputCellPressedReturn:(InputCell *)inputCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:inputCell];
    switch (indexPath.section) {
        case VCSectionTitles: {
            switch (indexPath.row) {
                case VCSectionTitlesRowName: {
                    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                    InputCell *nextCell = (InputCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
                    [nextCell.textField becomeFirstResponder];
                    break;
                }
                case VCSectionTitlesRowDescription: {
                    [inputCell.textField resignFirstResponder];
                    break;
                }
            }
            break;
        }
    }
}

@end
