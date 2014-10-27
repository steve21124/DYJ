//
//  ProfileUpdater.h
//  DYJ
//
//  Created by Timur Bernikowich on 18.10.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileUpdater : NSObject

+ (instancetype)sharedUpdater;

- (void)startUpdating;

@end
