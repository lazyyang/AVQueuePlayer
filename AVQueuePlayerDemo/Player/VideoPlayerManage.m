//
//  VideoPlayerManage.m
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//

#import "VideoPlayerManage.h"


@implementation VideoPlayerManage

+ (instancetype)instance
{
    static VideoPlayerManage *playerManage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManage = [[VideoPlayerManage alloc] init];
    });
    return playerManage;
}

- (instancetype)init
{
    if (self = [super init]) {
        _playerListArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setPlayerDataSourceWithURLArray:(NSArray *)urlArray
{
    for (id item in urlArray) {
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:item]];
        [self.playerListArray addObject:videoItem];
    }
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:self.playerListArray]];
}

- (void)play
{
    [self.queuePlayer play];
}

- (void)pause
{
    [self.queuePlayer pause];
}

- (void)playNext
{
    [self.queuePlayer advanceToNextItem];
}

- (void)playWithIndex:(NSInteger)index
{
    [self.queuePlayer removeAllItems];
    for (int i = index; i <self.playerListArray.count; i ++) {
        AVPlayerItem* obj = [self.playerListArray objectAtIndex:i];
        if ([self.queuePlayer canInsertItem:obj afterItem:nil]) {
            [obj seekToTime:kCMTimeZero];
            [self.queuePlayer insertItem:obj afterItem:nil];
        }
    }
}

@end
