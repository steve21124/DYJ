//
//  FriendsUpdater.h
//  DYJ
//
//  Created by Timur Bernikowich on 11.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsUpdater : NSObject

+ (instancetype)sharedUpdater;

- (void)startUpdating;

@end
