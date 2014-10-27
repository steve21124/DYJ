//
//  Task.h
//  DYJ
//
//  Created by Timur Bernikowich on 22.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

@interface Task : PFObject <PFSubclassing>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *taskDescription;
@property (nonatomic) PFUser *creator;
@property (nonatomic) NSNumber *reward;
@property (nonatomic) NSDate *expiration;
@property (nonatomic) NSNumber *status;

+ (NSString *)parseClassName;

@end