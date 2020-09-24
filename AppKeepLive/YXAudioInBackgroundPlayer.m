//
//  QiAudioPlayer.m
//  QiAppRunInBackground
//
//  Created by wangyongwang on 2019/12/30.
//  Copyright © 2019 WYW. All rights reserved.
//

#import "YXAudioInBackgroundPlayer.h"

static YXAudioInBackgroundPlayer *instance = nil;

@interface YXAudioInBackgroundPlayer ()

@end

@implementation YXAudioInBackgroundPlayer

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YXAudioInBackgroundPlayer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initPlayer];
    return self;
}

- (void)initPlayer {
    
    [self.player prepareToPlay];
}

- (AVAudioPlayer *)player {
    
    if (!_player) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SomethingJustLikeThis" withExtension:@"mp3"];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        audioPlayer.volume = 0;//静音播放
        audioPlayer.numberOfLoops = NSUIntegerMax;
        NSError *audioSessionError = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ( [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&(audioSessionError)] )
        {
            NSLog(@"set audio session success!");
        }else{
            NSLog(@"set audio session fail!");
        }
        _player = audioPlayer;
    }
    return _player;
}
@end
