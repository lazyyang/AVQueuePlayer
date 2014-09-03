//
//  ViewController.m
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerManage.h"


@interface ViewController ()

@property (strong, nonatomic) PlayerView *playerView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *playBtn;

@end

@implementation ViewController

#pragma mark - event
- (void)sliderValueChangedBegin:(UISlider *)slider
{
    AVQueuePlayer *player = [[VideoPlayerManage instance] queuePlayer];
    [player pause];
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
}

- (void)sliderValueChangedEnd:(UISlider *)slider
{
    AVQueuePlayer *player = [[VideoPlayerManage instance] queuePlayer];
    [player pause];
    [player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
    [player seekToTime:CMTimeMakeWithSeconds(slider.value, player.currentTime.timescale) completionHandler:^(BOOL finished) {
        NSLog(@"进度调节完成");
        [player play];
        [_playBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [self updateStatus:player.currentItem];
    }];
}

- (void)playOrPause:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"暂停"]) {
        [[VideoPlayerManage instance] pause];
        [button setTitle:@"播放" forState:UIControlStateNormal];
    }
    else{
        [[VideoPlayerManage instance] play];
        [button setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (void)playNext:(UIButton *)button
{
    [[VideoPlayerManage instance] playNext];
}

#pragma mark -createSlider
- (void)createSlider
{
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 330, 320, 2)];
    [self.view addSubview:_progressView];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 315, 320, 31)];
    [_slider addTarget:self action:@selector(sliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderValueChangedBegin:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_slider];
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    [self.view addSubview:_playerView];
    
    [self createSlider];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 290, 200, 15)];
    _timeLabel.text = @"";
    [self.view addSubview:_timeLabel];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _playBtn.frame = CGRectMake(0, 350, 320, 50);
    [_playBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    
    UIButton *playNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playNext.frame = CGRectMake(0, 410, 320, 50);
    [playNext setTitle:@"下一集" forState:UIControlStateNormal];
    [playNext addTarget:self action:@selector(playNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playNext];
    
    NSArray *urlArray = @[@"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/08/29/2228059-280-068-2342.mp4",
                          @"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/09/01/2233658-280-068-2335.mp4",
                          @"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/08/29/2228059-280-068-2342.mp4",
                          @"http://ips.ifeng.com/3gs.ifeng.com/userfiles/video02/2014/08/26/2220447-280-068-2354.mp4",
                          @"http://www.jxvdy.com/file/upload/201405/05/18-24-58-42-627.mp4"];
    [[VideoPlayerManage instance] setPlayerDataSourceWithURLArray:urlArray];
    [self.playerView.playerLayer setPlayer:[VideoPlayerManage instance].queuePlayer];
    [[VideoPlayerManage instance] play];
    
    //注册通知
    for (id item in [VideoPlayerManage instance].playerListArray) {
        //完成一集播放时
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishedPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
        
        //KVO
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
    }
}

- (void)updateStatus:(AVPlayerItem *)playerItem
{
    self.timeObserver = [[VideoPlayerManage instance].queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat timeDuration = CMTimeGetSeconds(playerItem.duration);
        CGFloat timeCurrent = CMTimeGetSeconds(playerItem.currentTime);
        [self.slider setMaximumValue:timeDuration];
        [self.slider setValue:timeCurrent animated:YES];
        _timeLabel.text = [NSString stringWithFormat:@"%d/%d",(int)timeCurrent,(int)timeDuration];
    }];
}

- (NSTimeInterval)availableDuration:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    CGFloat result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)itemDidFinishedPlaying:(NSNotification *)notif
{
    NSLog(@"本集播放");
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"可以播放了 = %@",self.timeObserver);
            
            CGFloat timeDuration = CMTimeGetSeconds(playerItem.duration);
            CGFloat timeCurrent = CMTimeGetSeconds(playerItem.currentTime);
            [self.slider setMaximumValue:timeDuration];
            [self.slider setValue:timeCurrent animated:YES];
            
            NSLog(@"----%f",timeDuration);

            [[[VideoPlayerManage instance] queuePlayer] removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
            [self updateStatus:playerItem];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        CGFloat availableTime = [self availableDuration:playerItem];
        CGFloat durationTime = CMTimeGetSeconds(playerItem.duration);
        [self.progressView setProgress:availableTime / durationTime animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
