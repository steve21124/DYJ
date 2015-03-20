//
//  FriendsView.m
//  DYJ
//
//  Created by Timur Bernikowich on 11/11/2014.
//  Copyright (c) 2014 Timur Bernikowich. All rights reserved.
//

#import "FriendsView.h"
@import QuartzCore;

@interface FriendsView ()

@property NSArray *avatarsViews;

@end

@implementation FriendsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)setAvatarsURLs:(NSArray *)avatarsURLs
{
    _avatarsURLs = avatarsURLs;
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat avatarSize = self.height;
    CGFloat padding = 5.0;
    NSInteger maxAvatarsNumber = self.width / (avatarSize + padding);
    NSMutableArray *avatarsViews = [NSMutableArray new];
    __weak NSArray *weakAvatars = self.avatarsURLs;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        for (NSInteger i = 0; i < maxAvatarsNumber && i < [weakAvatars count]; i++) {
            NSString *stringURL;
            if (!weakAvatars) {
                return;
            } else {
                stringURL = weakAvatars[i];
            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringURL]];
            dispatch_async(dispatch_get_main_queue(), ^() {
                UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (padding + avatarSize), 0, avatarSize, avatarSize)];
                avatarView.layer.cornerRadius = avatarView.width / 2.0;
                avatarView.contentMode = UIViewContentModeScaleAspectFill;
                avatarView.clipsToBounds = YES;
                avatarView.image = [UIImage imageWithData:data];
                [self addSubview:avatarView];
                [avatarsViews addObject:avatarView];
            });
        }
    });
}

@end
