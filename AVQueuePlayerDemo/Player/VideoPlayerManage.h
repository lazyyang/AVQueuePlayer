//
//  VideoPlayerManage.h
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@interface VideoPlayerManage : NSObject

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;
@property (strong, nonatomic) NSMutableArray *playerListArray;
@property (strong, nonatomic) PlayerView *playerView;

/**
 *  单例
 *
 *  @return id
 */
+ (instancetype)instance;

/**
 *  初始化Player的数据源
 *
 *  @param urlArray url数组,存NSString类型
 */
- (void)setPlayerDataSourceWithURLArray:(NSArray *)urlArray;

/**
 *  播放下一集
 */
- (void)playNext;

/**
 *  播放某一集
 *
 *  @param index 某集的序号
 */
- (void)playWithIndex:(NSInteger)index;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;


@end
