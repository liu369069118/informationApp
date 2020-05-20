//
//  ATActionSheet.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATActionSheet.h"

#define TITLE_TEXT_COLOR                    ATColor(77, 77, 77)     //标题
#define DESCRIPTIVE_TEXT_COLOR              ATColor(128, 128, 128)  //描述文字
#define CANCELANDOTHER_BUTTON_TITLE_COLOE   ATColor(0, 118, 255)    //蓝色
#define DESCRIPTIVE_BUTTON_TITLE_COLOR      ATColor(254, 56, 36)    //红色

#define SELECTED_BUTTON_COLOR               ATColor(204, 204, 204)  //button选中颜色
#define BUTTON_HEIGHT   60
#define CONTROL_INTERVAL 14.0f
#define TEXT_MARGIN 60.0f

typedef void(^touchItemBlock)(ATActionSheet *, NSString *, NSInteger );

@interface ATActionSheet ()

@property (nonatomic, weak) UIView *bgBlackView; //背景透明视图
@property (nonatomic, weak) UIView *btnBgView;  //按钮背景视图
@property (nonatomic, weak) UIView *titleView;  //标题视图
@property (nonatomic, weak) UIToolbar *otherButtonBgView; //其他按钮背景视图
@property (nonatomic, weak) UIToolbar *cancelButtonView; //其他按钮背景视图

@property (nonatomic, strong) NSMutableArray *classArray;   //按钮集合

@property (nonatomic, assign) CGFloat otherHeight;

@property (nonatomic, copy) touchItemBlock touchItemBlock;

@end

@implementation ATActionSheet

#pragma mark - Public method
- (void)showAction {
    [_btnBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-CONTROL_INTERVAL);
    }];
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgBlackView.alpha = 0.4f;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissAction{
    [_btnBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.otherHeight);
    }];
    [UIView animateWithDuration: 0.25 animations:^{
        self.bgBlackView.alpha = 0.0f;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissActionWhenTapBackgroundView{
    [_btnBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.otherHeight);
    }];
    [UIView animateWithDuration: 0.25 animations:^{
        self.bgBlackView.alpha = 0.0f;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.classArray.count>0 && self.touchItemBlock) {
            UIButton *cancelButton = self.classArray[0];
            self.touchItemBlock(self, cancelButton.titleLabel.text, 0);
        }
    }];
}

#pragma mark - Override

#pragma mark - Intial Methods
- (instancetype)initActionSheetWithTitle:(NSString *)title
                         descriptiveText:(NSString *)descriptive
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                  destructiveButtonTitles:(NSArray *)destructiveButtonTitles
                       otherButtonTitles:(NSArray *)otherButtonTitles
                              itemAction:(void(^)(ATActionSheet *actionSheet, NSString *title, NSInteger index))itemAction;
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self = [super initWithFrame:window.bounds];
    if (self) {
        [window addSubview: self];
        
        _otherHeight    = 0;
        _classArray     = [[NSMutableArray alloc]initWithCapacity:1];
        
        [self bgBlackView];
        [self btnBgView];
        
        [self createBtnBgViewWithTitle:title
                       descriptiveText:descriptive
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitles:destructiveButtonTitles
                     otherButtonTitles:otherButtonTitles];
        
        _touchItemBlock = ^(ATActionSheet *action, NSString *title, NSInteger index){
            itemAction(action, title ,index);
            [action dismissAction];
        };
        
        [self layoutIfNeeded];
    }
    return self;
}
#pragma mark - Target Methods

#pragma mark - Delegate Name

#pragma mark - Setter Getter Methods

- (UIView *)bgBlackView{
    if (!_bgBlackView) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        UIView *bgBlackView = [[UIView alloc]initWithFrame:window.bounds];
        bgBlackView.backgroundColor = [UIColor blackColor];
        bgBlackView.alpha = 0.0f;
        [self addSubview:bgBlackView];
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 1;
        [tap addTarget: self action: @selector(dismissActionWhenTapBackgroundView)];
        [bgBlackView addGestureRecognizer: tap];
        _bgBlackView = bgBlackView;
    }
    return _bgBlackView;
}

- (UIView *)btnBgView{
    if (!_btnBgView) {
        UIView *btnBgView = [[UIView alloc]init];
        [self addSubview:btnBgView];
        _btnBgView = btnBgView;
    }
    return _btnBgView;
}

- (UIView *)titleView{
    if (!_titleView) {
        UIView *view = [[UIView alloc]init];
        [_otherButtonBgView addSubview:view];
        _titleView = view;
    }
    return _titleView;
}

- (UIToolbar *)otherButtonBgView{
    if (!_otherButtonBgView) {
        UIToolbar *tempOtherButtonBgView = [[UIToolbar alloc]init];
        tempOtherButtonBgView.layer.cornerRadius = 10;
        tempOtherButtonBgView.layer.masksToBounds = YES;
        [_btnBgView addSubview:tempOtherButtonBgView];
        _otherButtonBgView = tempOtherButtonBgView;
    }
    return _otherButtonBgView;
}

- (UIToolbar *)cancelButtonView {
    if (!_cancelButtonView) {
        UIToolbar *cancelButtonView = [[UIToolbar alloc]init];
        cancelButtonView.layer.cornerRadius = 10;
        cancelButtonView.layer.masksToBounds = YES;
        [_btnBgView addSubview:cancelButtonView];
        _cancelButtonView = cancelButtonView;
        
        [_cancelButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.otherButtonBgView.mas_bottom).offset(10);
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(BUTTON_HEIGHT);
        }];
    }
    return _cancelButtonView;
    
}

#pragma mark - Private method
- (void)createBtnBgViewWithTitle:(NSString *)title
                 descriptiveText:(NSString *)descriptive
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitles:(NSArray *)destructiveButtonTitles
               otherButtonTitles:(NSArray *)otherButtonTitles{
    
    [self otherButtonBgView];
    [self cancelButtonView];
    
    CGFloat titleBtnBottomY = 0;
    if (title) {
//        titleBtnBottomY += [self createTitleLabelWithTitle:title];
    }
    
    if (descriptive) {
        titleBtnBottomY += [self createDescriptiveLabelWithDescriptive:descriptive
                                                       titleBtnBottomY:titleBtnBottomY];
    }
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(titleBtnBottomY);
    }];
    
    CGFloat otherBtnBottomY = titleBtnBottomY;
    CGFloat destructiveBtnBottomY = titleBtnBottomY;
    
    if (otherButtonTitles) {
        destructiveBtnBottomY = [self createOtherButtonWithOtherButtonTitles:otherButtonTitles
                                                             otherBtnBottomY:otherBtnBottomY];
    }
    
    if (destructiveButtonTitles) {
        destructiveBtnBottomY = [self createDestructiveButtonWithDestructiveButtonTitles:destructiveButtonTitles destructiveBtnBottomY:destructiveBtnBottomY];
    }
    
    [_otherButtonBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(destructiveBtnBottomY);
    }];
    
    if (cancelButtonTitle) {
        [self createCancelButtonWithCancelButtonTitle:cancelButtonTitle];
        
        _otherHeight = destructiveBtnBottomY + CONTROL_INTERVAL + BUTTON_HEIGHT;
    }else{
        [_otherButtonBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-8);
        }];
        _otherHeight = destructiveBtnBottomY + CONTROL_INTERVAL;
    }
    
    [_btnBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(CONTROL_INTERVAL);
        make.right.mas_equalTo(-CONTROL_INTERVAL);
        make.bottom.mas_equalTo(self.mas_bottom).offset(self.otherHeight);
    }];
}

- (CGFloat)createTitleLabelWithTitle:(NSString *)title {
    UILabel *titleLbl = [[UILabel alloc]init];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.text = [NSString stringWithFormat:@"%@",title];
    titleLbl.textColor = TITLE_TEXT_COLOR;
    titleLbl.font = [UIFont systemFontOfSize:15];
    titleLbl.numberOfLines = 0;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGRect rect = [titleLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth - 32, kScreenHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attribute
                                              context:nil];
    [self.titleView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(rect.size.height);
    }];
    return rect.size.height;
}

- (CGFloat)createDescriptiveLabelWithDescriptive:(NSString *)descriptive titleBtnBottomY:(CGFloat)titleBtnBottomY {
    UILabel *descriptiveLbl = [[UILabel alloc]init];
    descriptiveLbl.text = descriptive;
    descriptiveLbl.textColor = DESCRIPTIVE_TEXT_COLOR;
    descriptiveLbl.font = [UIFont systemFontOfSize:15];
    descriptiveLbl.textAlignment = NSTextAlignmentCenter;
    descriptiveLbl.numberOfLines = 0;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGRect rect = [descriptiveLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth - (2 * TEXT_MARGIN + 2 * CONTROL_INTERVAL), kScreenHeight)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attribute
                                                    context:nil];
    [self.titleView addSubview:descriptiveLbl];
    CGFloat labelHeight = rect.size.height;
    [descriptiveLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(TEXT_MARGIN);
        make.right.mas_equalTo(-TEXT_MARGIN);
        make.top.mas_equalTo(titleBtnBottomY + CONTROL_INTERVAL);
    }];
    return labelHeight + CONTROL_INTERVAL * 2;
}

- (CGFloat)createOtherButtonWithOtherButtonTitles:(NSArray *)otherButtonTitles otherBtnBottomY:(CGFloat)otherBtnBottomY {
    NSInteger count = otherButtonTitles.count;
    for (int i = 0; i < count; i ++) {
        UIButton *other = [self createTitleButtonWithTitle:otherButtonTitles[i]
                                                titleColor:CANCELANDOTHER_BUTTON_TITLE_COLOE];
        other.titleLabel.font = [UIFont systemFontOfSize:17];
        [_otherButtonBgView addSubview:other];
        [_classArray addObject:other];
        [other mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(otherBtnBottomY);
            make.height.mas_equalTo(BUTTON_HEIGHT);
        }];
        otherBtnBottomY += BUTTON_HEIGHT;
    }
    return otherBtnBottomY;
}

- (CGFloat)createDestructiveButtonWithDestructiveButtonTitles:(NSArray *)destructiveButtonTitles destructiveBtnBottomY:(CGFloat)destructiveBtnBottomY {
    NSInteger count = destructiveButtonTitles.count;
    for (int i = 0; i < count; i ++) {
        UIButton *destructive = [self createTitleButtonWithTitle:destructiveButtonTitles[i]
                                                      titleColor:DESCRIPTIVE_BUTTON_TITLE_COLOR];
        destructive.titleLabel.font = [UIFont systemFontOfSize:17];
        [_otherButtonBgView addSubview:destructive];
        [_classArray addObject:destructive];
        [destructive mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(destructiveBtnBottomY);
            make.height.mas_equalTo(BUTTON_HEIGHT);
        }];
        destructiveBtnBottomY += BUTTON_HEIGHT;
    }
    return destructiveBtnBottomY;
}

- (void)createCancelButtonWithCancelButtonTitle:(NSString *)cancelButtonTitle {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [button setTitle:cancelButtonTitle forState:UIControlStateNormal];
    button.userInteractionEnabled = NO;
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    [button setTitleColor:CANCELANDOTHER_BUTTON_TITLE_COLOE forState:UIControlStateNormal];
    [_cancelButtonView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    [_classArray insertObject:button atIndex:0];
}

- (UIButton *)createTitleButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO;
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = SELECTED_BUTTON_COLOR;;
    [button addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    return button;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIButton *button in _classArray) {
        CGRect rect2 = [button convertRect:button.bounds toView:self];
        BOOL contains = CGRectContainsPoint(rect2, point);
        if (contains) {
            button.backgroundColor = SELECTED_BUTTON_COLOR;
            break;
        }else{
            button.backgroundColor = [UIColor clearColor];
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSInteger touchItemIndex = 0;
    NSInteger count = _classArray.count;
    for (int i = 0; i < count; i ++) {
        UIButton *button = _classArray[i];
        CGRect rect2 = [button convertRect:button.bounds toView:self];
        BOOL contains = CGRectContainsPoint(rect2, point);
        if (contains) {
            button.backgroundColor = [UIColor clearColor];
            touchItemIndex = i;
            _touchItemBlock(self, button.titleLabel.text, touchItemIndex);
//            if (i == 0) {
//                [self dismissAction];
//            }
            break;
        }
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIButton *button in _classArray) {
        CGRect rect2 = [button convertRect:button.bounds toView:self];
        BOOL contains = CGRectContainsPoint(rect2, point);
        if (contains) {
            button.backgroundColor = SELECTED_BUTTON_COLOR;
        }else{
            button.backgroundColor = [UIColor clearColor];
        }
    }
}

@end
