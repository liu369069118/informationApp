

#import <UIKit/UIKit.h>
@class BLMenuItem;

typedef NS_ENUM(NSUInteger, BLMenuItemState) {
    BLMenuItemStateSelected,
    BLMenuItemStateNormal,
};

@protocol BLMenuItemDelegate <NSObject>
@optional
- (void)didPressedMenuItem:(BLMenuItem *)menuItem;
@end

@interface BLMenuItem : UILabel
/** 设置rate,并刷新标题状态 */
@property (nonatomic, assign) CGFloat rate;

/** normal状态的字体大小，默认大小为15 */
@property (nonatomic, assign) CGFloat normalSize;

/** selected状态的字体大小，默认大小为18 */
@property (nonatomic, assign) CGFloat selectedSize;

/** normal状态的字体颜色，默认为黑色 (可动画) */
@property (nonatomic, strong) UIColor *normalColor;

/** selected状态的字体颜色，默认为红色 (可动画) */
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, weak) id<BLMenuItemDelegate> delegate;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;

@property (nonatomic, assign) BOOL showMessage; // 是否显示提醒的白点

@property (nonatomic, assign) BOOL isPic; // 是否为图片样式，NO：文本样式，YES：图片样式，默认NO

//属性二选一，使用本地资源或者网络资源
@property (nonatomic, strong) NSString *localPicName; // 图片name
@property (nonatomic, strong) NSString *remotePicUrl; // 图片url

- (void)updateIconSizeWith:(CGSize)size;

- (void)selectedWithoutAnimation;
- (void)deselectedWithoutAnimation;

@end
