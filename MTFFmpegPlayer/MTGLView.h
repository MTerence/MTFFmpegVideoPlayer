//
//  MTGLView.h
//  MTFFmpegPlayer
//
//  Created by Ternence on 2019/3/18.
//  Copyright © 2019 Ternence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTGLView : UIView

- (id) initWithFrame:(CGRect) frame
            decoder:(MTDecoder *) decoder;

- (void) render:(MTVideoFrame *) frame;

@end

NS_ASSUME_NONNULL_END
