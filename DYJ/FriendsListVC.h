//
//  FriendsListVC.h
//  DYJ
//
//  Created by Timur Bernikowich on 02.11.14.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "BaseVC.h"

@class FriendsListVC;

@protocol FriendsListVCDelegate <NSObject>

- (void)friendsListVCWillClose:(FriendsListVC *)vc;

@end

@interface FriendsListVC : BaseVC

@property (nonatomic, weak) id <FriendsListVCDelegate> delegate;
@property (nonatomic) NSArray *asignedFriends;

@end