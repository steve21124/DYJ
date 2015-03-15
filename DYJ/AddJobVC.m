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
#import "Notification.h"
#import "InputCell.h"
#import "InfoCell.h"
#import "FriendsListVC.h"
#import <UIAlertView+Blocks.h>

NSString *const TaskTitleKey = @"TaskTitleKey";
NSString *const TaskDescriptionKey = @"TaskDescriptionKey";
NSString *const TaskDateKey = @"TaskDateKey";
NSString *const TaskBidKey = @"TaskBidKey";
NSString *const TaskFriendsKey = @"TaskFriendsKey";

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

typedef NS_ENUM(NSUInteger, VCSectionBidsRow) {
    VCSectionBidsRowBids,
    VCSectionBidsRowsCount
};

@interface AddJobVC () <UITableViewDataSource, UITableViewDelegate, InputCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FriendsListVCDelegate>

@property NSMutableDictionary *taskDictionary;
@property UITableView *tableView;
@property UIView *datePicker;
@property UIView *motivesPicker;
@property NSArray *values;
@property (nonatomic) CGFloat keyboardPadding;
@property (nonatomic) CGFloat datePickerPadding;
@property (nonatomic) CGFloat motivesPickerPadding;
@property UITextField *textField;
@property UIToolbar *textFieldToolbar;
@property UIView *textFieldTopView;

@end

@implementation AddJobVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"PLAN A NEW JOB";
    self.taskDictionary = [NSMutableDictionary new];
    self.taskDictionary[TaskFriendsKey] = @[];
    self.values = @[@10, @25, @50, @100];

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
    
    // Text field top view.
    self.textFieldTopView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_BOUNDS.size.width, 44.0)];
    self.textFieldTopView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewContentModeBottom;
    self.textFieldTopView.backgroundColor = [UIColor whiteColor];
    
    UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.textFieldTopView.width, PIXEL)];
    separatorTop.backgroundColor = [UIColor colorWithColorCode:@"cccccc"];
    [self.textFieldTopView addSubview:separatorTop];
    
    // Done text field button.
    UIButton *doneTextFieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneTextFieldButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneTextFieldButton setTitleColor:[UIColor colorWithColorCode:@"FF6C2F"] forState:UIControlStateNormal];
    doneTextFieldButton.frame = CGRectMake(self.textFieldTopView.width - 100, 0, 100, 44);
    [doneTextFieldButton addTarget:self action:@selector(doneTextFieldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.textFieldTopView addSubview:doneTextFieldButton];
    
    // Subscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardMoved:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardMoved:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doneTextFieldButtonPressed:(id)sender
{
    [self.textField resignFirstResponder];
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
    NSNumber *bid = self.taskDictionary[TaskBidKey];
    return ([title length] && [taskDescription length] && expired && bid);
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
        [self showAlertViewForAddButton];
        return;
    }

    // Create new task.
    Task *newTask = [Task new];
    newTask.title = self.taskDictionary[TaskTitleKey];
    newTask.taskDescription = self.taskDictionary[TaskDescriptionKey];
    newTask.creator = [PFUser currentUser];
    newTask.status = @(TaskStatusDefault);
    newTask.expiration = self.taskDictionary[TaskDateKey];
    newTask.reward = self.taskDictionary[TaskBidKey];
    for (PFUser *user in self.taskDictionary[TaskFriendsKey]) {
        [newTask.asigned addObject:user];
    }
    
    // Make a transaction.
    PFUser *localUser = [PFUser currentUser];
    [localUser fetch];
    if (localUser.balance > newTask.reward) {
        [newTask save];
        localUser.balance = @([localUser.balance integerValue] - [newTask.reward integerValue]);
        [localUser save];

        for (PFUser *friend in self.taskDictionary[TaskFriendsKey]) {
            Notification *notification = [Notification new];
            notification.type = @(NotificationTypeNewTask);
            notification.isRead = @(NO);
            notification.sender = [PFUser currentUser];
            notification.task = newTask;
            notification.receiver = friend;
            [notification saveInBackground];
        }

        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" containedIn:self.taskDictionary[TaskFriendsKey]];
        PFUser *currentUser = [PFUser currentUser];
        NSString *message = currentUser.profileName ? [NSString stringWithFormat:@"%@: Help me!", currentUser.profileName] : @"Your friend need help!";
        [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:message];
    }

    if (self.delegate) {
        [self.delegate addJobVCDidFinish:self];
    }
}

- (void)showAlertViewForAddButton
{
    [UIAlertView showWithTitle:@"Warning" message:@"Enter all data please." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (![self.taskDictionary[TaskTitleKey] length]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:VCSectionTitlesRowName inSection:VCSectionTitles];
            InputCell *cell = (InputCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
            [self resignFirstResponder];
            return;
        }
        if (![self.taskDictionary[TaskDescriptionKey] length]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:VCSectionTitlesRowDescription inSection:VCSectionTitles];
            InputCell *cell = (InputCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
            [self resignFirstResponder];
            return;
        }
        if (!self.taskDictionary[TaskDateKey]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:VCSectionDateRowExpiration inSection:VCSectionDate];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            return;
        }
        if (!self.taskDictionary[TaskBidKey]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:VCSectionBidsRowBids inSection:VCSectionBids];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            return;
        }
    }];
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
            return VCSectionTitlesRowsCount;
        case VCSectionDate:
            return VCSectionDateRowsCount;
        case VCSectionBids:
            return VCSectionBidsRowsCount;
        case VCSectionFriends:
        {
            NSArray *friends = self.taskDictionary[TaskFriendsKey];
            return [friends count] + 1;
        }
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
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.inputAccessoryView = self.textFieldTopView;
                    break;
                case VCSectionTitlesRowDescription:
                    cell.textField.placeholder = @"Describe your task here";
                    cell.textField.returnKeyType = UIReturnKeyNext;
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.inputAccessoryView = self.textFieldTopView;
                    break;
            }
            cell.separatorTop.hidden = (indexPath.row != 0);
            cell.separatorMiddle.hidden = (indexPath.row == VCSectionTitlesRowsCount - 1);
            cell.separatorBottom.hidden = (indexPath.row != VCSectionTitlesRowsCount - 1);
            cell.delegate = self;
            resultCell = cell;
            break;
        }
        case VCSectionDate:
        {
            switch (indexPath.row) {
                case VCSectionDateRowExpiration:
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
            break;
        }
        case VCSectionBids:
        {
            switch (indexPath.row) {
                case VCSectionBidsRowBids:
                {
                    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoCell class]) forIndexPath:indexPath];
                    cell.label.text = @"Your bid";
                    NSNumber *bid = self.taskDictionary[TaskBidKey];
                    cell.infoLabel.text = bid ? [NSString stringWithFormat:@"%@ motives", bid] : @"Select your bid";
                    resultCell = cell;
                }
            }
            break;
        }
        case VCSectionFriends:
        {
            InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoCell class]) forIndexPath:indexPath];

            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1);
            cell.separatorTop.hidden = !isFirstCell;
            cell.separatorMiddle.hidden = isLastCell;
            cell.separatorBottom.hidden = !isLastCell;

            NSArray *friends = self.taskDictionary[TaskFriendsKey];
            PFUser *friend;
            if (indexPath.row < [friends count]) {
                friend = friends[indexPath.row];
            }

            if (friend) {
                cell.label.text = friend.profileName;
                cell.infoLabel.text = nil;
            } else {
                cell.label.text = @"Add";
                cell.infoLabel.text = @"Friends list";
            }

            resultCell = cell;
            break;
        }
    }

    return resultCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performAfterDelay:0.3 block:^() {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];

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
            if (self.motivesPicker) {
                [self motivesPickerDoneButtonPressed:nil];
            }
            if (self.datePicker) {
                [self datePickerDoneButtonPressed:nil];
                return;
            }
            [self.textField resignFirstResponder];

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

            UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerView.width, PIXEL)];
            [pickerView addSubview:separatorTop];
            separatorTop.backgroundColor = [UIColor colorWithColorCode:@"cccccc"];

            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            [done setTitle:@"Done" forState:UIControlStateNormal];
            [done setTitleColor:[UIColor colorWithColorCode:@"FF6C2F"] forState:UIControlStateNormal];
            done.frame = CGRectMake(pickerView.width - 100, 0, 100, 44);
            [done addTarget:self action:@selector(datePickerDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [pickerView addSubview:done];

            NSDate *defaultDate = [NSDate dateWithTimeIntervalSinceNow:3 * 24 * 60 * 60];
            NSDate *selectedDate = self.taskDictionary[TaskDateKey];
            if (!selectedDate) {
                selectedDate = defaultDate;
                self.taskDictionary[TaskDateKey] = defaultDate;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
            [datePicker setDate:selectedDate animated:YES];
            [pickerView addSubview:datePicker];
            pickerView.originY = self.view.height;
            [self.view addSubview:pickerView];
            [UIView animateWithDuration:0.3 animations:^(){
                pickerView.origin = CGPointMake(0, self.view.height - pickerView.height);
                self.datePickerPadding = pickerView.height;
            }];
            break;
        }
        case VCSectionBids:
        {
            if (self.datePicker) {
                [self datePickerDoneButtonPressed:nil];
            }
            if (self.motivesPicker) {
                [self motivesPickerDoneButtonPressed:nil];
                return;
            }
            [self.textField resignFirstResponder];

            UIPickerView *bidsPicker = [UIPickerView new];
            bidsPicker.backgroundColor = [UIColor whiteColor];
            bidsPicker.dataSource = self;
            bidsPicker.delegate = self;
            bidsPicker.origin = CGPointMake(0, self.view.height);

            CGRect pickerFrame = bidsPicker.bounds;
            pickerFrame.size.height += 44.0;
            bidsPicker.originY = 44.0;
            UIView *pickerView = [[UIView alloc] initWithFrame:pickerFrame];
            pickerView.backgroundColor = [UIColor whiteColor];
            self.motivesPicker = pickerView;

            UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerView.width, PIXEL)];
            [pickerView addSubview:separatorTop];
            separatorTop.backgroundColor = [UIColor colorWithColorCode:@"cccccc"];

            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            [done setTitle:@"Done" forState:UIControlStateNormal];
            [done setTitleColor:[UIColor colorWithColorCode:@"FF6C2F"] forState:UIControlStateNormal];
            done.frame = CGRectMake(pickerView.width - 100, 0, 100, 44);
            [done addTarget:self action:@selector(motivesPickerDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [pickerView addSubview:done];

            NSNumber *defaultValue = @10;
            NSNumber *selectedValue = self.taskDictionary[TaskBidKey];
            if (!selectedValue) {
                selectedValue = defaultValue;
                self.taskDictionary[TaskBidKey] = defaultValue;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionBids] withRowAnimation:UITableViewRowAnimationAutomatic];
            [pickerView addSubview:bidsPicker];
            pickerView.originY = self.view.height;
            [self.view addSubview:pickerView];
            [UIView animateWithDuration:0.3 animations:^(){
                pickerView.origin = CGPointMake(0, self.view.height - pickerView.height);
                self.motivesPickerPadding = pickerView.height;
            }];
            break;
        }
        case VCSectionFriends:
        {
            if (self.datePicker) {
                [self datePickerDoneButtonPressed:nil];
            }
            if (self.motivesPicker) {
                [self motivesPickerDoneButtonPressed:nil];
            }
            [self.textField resignFirstResponder];
            NSArray *friends = self.taskDictionary[TaskFriendsKey];
            PFUser *friend;
            if (indexPath.row < [friends count]) {
                friend = friends[indexPath.row];
            }

            if (friend) {
#warning Remove friend
            } else {
                [self performSegueWithIdentifier:@"SelectFriends" sender:indexPath];
            }
            break;
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
    [self updateAddButton];
}

- (void)datePickerChangedDate:(UIDatePicker *)sender
{
    NSDate *newDate = sender.date;
    self.taskDictionary[TaskDateKey] = newDate;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionDate] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)motivesPickerDoneButtonPressed:(UIButton *)sender
{
    UIView *view = self.motivesPicker;
    [UIView animateWithDuration:0.3 animations:^() {
        view.originY = view.superview.height;
        self.motivesPickerPadding = 0;
    } completion:^(BOOL complete) {
        [view removeFromSuperview];
        self.motivesPicker = nil;
    }];
    [self updateAddButton];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.values count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@ motives", self.values[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.taskDictionary[TaskBidKey] = self.values[row];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionBids] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)inputCellDidBeginEditing:(InputCell *)inputCell
{
    if (self.datePicker) {
        [self datePickerDoneButtonPressed:nil];
    }
    if (self.motivesPicker) {
        [self motivesPickerDoneButtonPressed:nil];
    }
    self.textField = inputCell.textField;
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
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:VCSectionDateRowExpiration inSection:VCSectionDate];
                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    [inputCell.textField resignFirstResponder];
                    break;
                }
            }
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectFriends"]) {
        FriendsListVC *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.asignedFriends = self.taskDictionary[TaskFriendsKey];
    }
}

- (void)friendsListVCWillClose:(FriendsListVC *)vc
{
    self.taskDictionary[TaskFriendsKey] = vc.asignedFriends;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VCSectionFriends] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
