//
//  PFUser+DYJ.h
//  DYJ
//
//  Created by Timur Bernikowich on 10.03.15.
//  Copyright (c) 2015 Timur Bernikowich. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (DYJ)

@property (nonatomic) NSNumber *balance;
@property (nonatomic, readonly) NSString *profileName;
@property (nonatomic, readonly) NSString *profilePictureURL;

@end
