//
//  ViewController.m
//  DYJ
//
//  Created by Timur Bernikowich on 10.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "StartVC.h"

// Models.
#import "ProfileUpdater.h"

@interface StartVC ()

@property UIView *helloView;
@property UIImageView *logo;
@property UILabel *appTitle;
@property UILabel *instructions;
@property UIButton *facebookLogin;

@end

@implementation StartVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)configureView
{
    // Hello view.
    self.helloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 240)];
    self.helloView.centerX = self.view.width / 2.0;
    self.helloView.centerY = (self.view.height - 128.0) / 2.0;
    self.helloView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.helloView];

    // Logo.
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon big 2"]];
    self.logo.centerX = self.helloView.width / 2.0;
    self.logo.originY = 0;
    [self.helloView addSubview:self.logo];

    // Instructions.
    self.instructions = [[UILabel alloc] initWithFrame:CGRectMake(0, self.helloView.height - 60, self.helloView.width, 60)];
    self.instructions.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.instructions.numberOfLines = 0;
    [self.helloView addSubview:self.instructions];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:18];
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    NSString *string = @"Set your goal – ask your friends for help – reward them if you succeed.";
    NSAttributedString *attributedInstructions = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : color}];
    self.instructions.attributedText = attributedInstructions;

    // Title.
    self.appTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.helloView.width, 36)];
    self.appTitle.originY = self.helloView.height - 36 - 20 - self.instructions.height;
    self.appTitle.textColor = [UIColor mainAppColor];
    self.appTitle.textAlignment = NSTextAlignmentCenter;
    self.appTitle.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:30];
    self.appTitle.text = NSLocalizedString(@"Do Your Job!", nil);
    [self.helloView addSubview:self.appTitle];

    // Facebook login button.
    UIImage *facebookLoginImage = [UIImage imageNamed:@"Sign In Button"];
    self.facebookLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookLogin setImage:facebookLoginImage forState:UIControlStateNormal];
    self.facebookLogin.frame = CGRectMake(0, 0, facebookLoginImage.size.width, facebookLoginImage.size.height);
    self.facebookLogin.center = CGPointMake(self.view.width / 2.0, self.view.height - 64.0);
    self.facebookLogin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.facebookLogin addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.facebookLogin];
}

- (void)loginButtonTouchHandler:(id)sender
{
    // Login using Facebook
    [[Helper sharedHelper] loginCompletion:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
}

@end
