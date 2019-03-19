//
//  MTDecoder.h
//  MTFFmpegPlayer
//
//  Created by Ternence on 2019/3/18.
//  Copyright © 2019 Ternence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    MTFrameTypeAudio,
    MTFrameTypeVideo,
}MTFrameType;

typedef enum {
    MTVideoFrameFormatRGB,
    MTVideoFrameFormatYUV,
}MTVideoFrameFormat;

@interface MTFrame : NSObject
@property (nonatomic, assign) MTFrameType type;
@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) CGFloat duration;
@end

@interface MTAudioFrame : MTFrame
@property (nonatomic, strong) NSData * samples;
@end

@interface MTVideoFrame : MTFrame
@property (nonatomic, assign) MTVideoFrameFormat format;
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@end

@interface MTVideoFrameRGB : MTVideoFrame
@property (nonatomic, assign) NSUInteger linesize;
@property (nonatomic, strong) NSData *rgb;
@end

@interface MTVideoFrameYUV : MTVideoFrame
@property (nonatomic, strong) NSData * luma;
@property (nonatomic, strong) NSData * chromaB;
@property (nonatomic, strong) NSData * chromaR;
@end

@protocol MTDecoderDelegate <NSObject>

- (void)getYUV420Data:(void *)pData width:(int)width height:(int)height;


@end

@interface MTDecoder : NSObject
@property (nonatomic, weak) __weak id<MTDecoderDelegate>delegate;

@property (nonatomic, strong, readonly) NSString * path;
@property (nonatomic, assign) CGFloat fps;

@property (nonatomic, assign) NSUInteger frameWidth;
@property (nonatomic, assign) NSUInteger frameHeight;


- (BOOL)setupVideoFrameFormat:(MTVideoFrameFormat)format;
- (BOOL)openFile:(NSString *)path error:(NSError **)perror;
- (NSArray *)decodeFrames:(CGFloat)minDuration;

@end

NS_ASSUME_NONNULL_END
