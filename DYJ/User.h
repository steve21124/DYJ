//
//  User.h
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser

@property (nonatomic, readonly) NSString *profileName;
@property (nonatomic, readonly) NSString *profileURL;

@end
