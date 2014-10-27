//
//  AddJobVC.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddJobVC;

@protocol AddJobVCDelegate <NSObject>

- (void)addJobVCDidCancel:(AddJobVC *)vc;
- (void)addJobVCDidFinish:(AddJobVC *)vc;

@end

@interface AddJobVC : UIViewController

@property (nonatomic, weak) id <AddJobVCDelegate> delegate;

@end