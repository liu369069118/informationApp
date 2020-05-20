
#import <UIKit/UIKit.h>

@interface BLProgressView : UIView

@property (nonatomic, strong) NSArray *itemFrames;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) CGFloat progress;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat cornerRadius;

// 调皮属性，用于实现新腾讯视频效果
@property (nonatomic, assign) BOOL naughty;
@property (nonatomic, assign) BOOL isTriangle;
@property (nonatomic, assign) BOOL hollow;
@property (nonatomic, assign) BOOL hasBorder;

- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToPostion:(NSInteger)pos;

@end
