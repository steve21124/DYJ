//
//  User.h
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (User)

@property (nonatomic) NSNumber *balance;
@property (nonatomic, readonly) NSString *profileName;
@property (nonatomic, readonly) NSString *profilePictureURL;

@end
