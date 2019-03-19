//
//  MTViewController.m
//  MTFFmpegPlayer
//
//  Created by Ternence on 2019/3/18.
//  Copyright © 2019 Ternence. All rights reserved.
//

#import "MTViewController.h"
#import "MTDecoder.h"
#import "MTGLView.h"

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4

@interface MTViewController ()<MTDecoderDelegate>
{
    MTDecoder*          _decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray*     _videoFrames;
    
    NSData*             _currentAudioFrames;
    NSUInteger          _currentAudioFramePos;
    
    MTGLView*           _glView;
    
    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
}

@property (nonatomic, copy) NSString *mediaPath;

@end

@implementation MTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setTitle:@"start" forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    aButton.frame = CGRectMake(self.view.frame.size.width/2 - 25, 100, 50, 50);
    [aButton addTarget:self action:@selector(action_onStartButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aButton];
    
    [self start];
}

//初始化文件和解码器
- (void)start{
    _mediaPath = [[NSBundle mainBundle] pathForResource:@"vue" ofType:@"MOV"];
    __weak MTViewController *weakSelf = self;
    
    MTDecoder* decoder = [[MTDecoder alloc]init];
    decoder.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError * error = nil;
        [decoder openFile:_mediaPath error:&error];
        
        __strong MTViewController *strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf setMovieDecoder:decoder];
            });
        }
    });
    
}

- (void)setMovieDecoder:(MTDecoder *)decoder{
    if (decoder) {
        _decoder = decoder;
        _dispatchQueue = dispatch_queue_create("MTSerialQueue", DISPATCH_QUEUE_SERIAL);
        _videoFrames = [NSMutableArray array];
    }
    
    _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
    _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
    
    if (self.isViewLoaded)
    {
        [self setupPresentView];
    }
}

- (void)action_onStartButtonClick{
    //2次播放，不然开始播放的时候容易卡顿
    [self play];
    [self play];
}

- (void)setupPresentView
{
    _glView = [[MTGLView alloc]initWithFrame:CGRectMake(35, self.view.frame.size.height - 600, 300, 500) decoder:_decoder];
    _glView.center = self.view.center;
    [self.view addSubview:_glView];
    
}

- (void)play{
    [self asyncDecodFrames];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tick];
    });
}


- (void)asyncDecodFrames
{
    __weak MTViewController * weakSelf = self;
    __weak MTDecoder * weakDecoder = _decoder;
    
    
    dispatch_async(_dispatchQueue, ^{
       
        //当已经解码的视频总时间大于_maxBufferedDuration 停止解码
        BOOL good = YES;
        while (good) {
            good = NO;
            
            @autoreleasepool {
                __strong MTDecoder *strongDecoder = weakDecoder;
                
                if (strongDecoder) {
                    NSArray * frames = [strongDecoder decodeFrames:0.1];
                    
                    if (frames.count) {
                        __strong MTViewController * strongSelf = weakSelf;
                        
                        if (strongSelf) {
                            good = [strongSelf addFrames:frames];
                        }
                    }
                }
            }
        }
    });
}

- (BOOL)addFrames:(NSArray *)frames{
    @synchronized (_videoFrames) {
        for (MTFrame * frame in frames) {
            
            if (frame.type == MTFrameTypeVideo) {
                [_videoFrames addObject:frame];
                _bufferedDuration += frame.duration;
            }
        }
    }
    
    return _bufferedDuration < _maxBufferedDuration;
}

- (void)tick{
    //返回当前帧的播放时间
    CGFloat interval = [self presentFrame];
    
    const NSUInteger leftFrames = _videoFrames.count;
    if (0 == leftFrames) {
        return;
    }
    
    //当_videoFrames 中已经没有解码过后的数据,或者剩余的时间小于_minBufferedDuration最小，就继续解码
    if (!leftFrames ||
        !(_bufferedDuration > _minBufferedDuration)) {
        [self asyncDecodFrames];
    }
    
    //播放完一帧后，继续播放下一帧，两帧直接的播放间隔不能小于0.01s
    const NSTimeInterval time = MAX(interval, 0.01);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tick];
    });
}

- (CGFloat)presentFrame{
    CGFloat interval = 0;
    MTVideoFrame * frame;
    
    @synchronized (_videoFrames) {
        if (_videoFrames.count > 0) {
            frame = _videoFrames[0];
            [_videoFrames removeObjectAtIndex:0];
            _bufferedDuration -= frame.duration;
        }
    }
    
    if (frame) {
        if (_glView) {
            [_glView render:frame];
        }
        interval = frame.duration;
    }
    
    return interval;
}

@end
