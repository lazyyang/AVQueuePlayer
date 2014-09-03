//
//  PlayerView.m
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//

#import "PlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation PlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _playerLayer = [[AVPlayerLayer alloc] init];
        [_playerLayer setFrame:frame];
        [self.layer addSublayer:_playerLayer];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
