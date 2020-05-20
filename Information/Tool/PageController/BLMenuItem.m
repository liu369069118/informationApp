
#import "BLMenuItem.h"

@interface BLMenuItem () {
    CGFloat _selectedRed, _selectedGreen, _selectedBlue, _selectedAlpha;
    CGFloat _normalRed, _normalGreen, _normalBlue, _normalAlpha;
    int     _sign;
    CGFloat _gap;
    CGFloat _step;
    __weak CADisplayLink *_link;
}

@property (nonatomic, weak) UIView *dotView;
@property (nonatomic, strong) UIImageView *showImageView;

@end

@implementation BLMenuItem

#pragma mark - Public Methods
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.normalColor   = [UIColor blackColor];
        self.selectedColor = [UIColor blackColor];
        self.normalSize    = 15;
        self.selectedSize  = 18;
        self.numberOfLines = 0;
        
//        CGFloat dotSize = 6.0f;
//        UIView *dotView = [[UIView alloc] init];
//        dotView.frame = CGRectMake(frame.size.width, 10, dotSize, dotSize);
//        dotView.backgroundColor = kHBColor255;
//        dotView.layer.cornerRadius = dotSize * 0.5;
//        dotView.layer.masksToBounds = YES;
//        dotView.hidden = YES;
//        [self addSubview:dotView];
//        _dotView = dotView;
    }
    return self;
}

- (CGFloat)speedFactor {
    if (_speedFactor <= 0) {
        _speedFactor = 15.0;
    }
    return _speedFactor;
}

// 设置选中，隐式动画所在
- (void)setSelected:(BOOL)selected {
    if (self.selected == selected) { return; }
    _selected = selected;
    _sign = (selected == YES) ? 1 : -1;
    _gap = (selected == YES) ? (1.0 - self.rate) : (self.rate - 0.0);
    _step = _gap / self.speedFactor;
    if (_link) {
        [_link invalidate];
        //        [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rateChange)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _link = link;
}

- (void)rateChange {
    if (_gap > 0.000001) {
        _gap -= _step;
        if (_gap < 0.0) {
            self.rate = (int)(self.rate + _sign * _step + 0.5);
            return;
        }
        self.rate += _sign * _step;
    } else {
        self.rate = (int)(self.rate + 0.5);
        [_link invalidate];
        _link = nil;
    }
}

// 设置rate,并刷新标题状态
- (void)setRate:(CGFloat)rate {
    if (rate < 0.0 || rate > 1.0) { return; }
    _rate = rate;
    CGFloat r = _normalRed + (_selectedRed - _normalRed) * rate;
    CGFloat g = _normalGreen + (_selectedGreen - _normalGreen) * rate;
    CGFloat b = _normalBlue + (_selectedBlue - _normalBlue) * rate;
    CGFloat a = _normalAlpha + (_selectedAlpha - _normalAlpha) * rate;
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    CGFloat minScale = self.normalSize / self.selectedSize;
    CGFloat trueScale = minScale + (1 - minScale)*rate;
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
    if (rate <= 0.5f) {
        self.font = [UIFont systemFontOfSize:self.selectedSize];
    }else {
        self.font = [UIFont boldSystemFontOfSize:self.selectedSize];
    }
}

- (void)selectedWithoutAnimation {
    self.rate = 1.0;
    _selected = YES;
}

- (void)deselectedWithoutAnimation {
    self.rate = 0;
    _selected = NO;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [selectedColor getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [normalColor getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_normalAlpha];
}

- (void)setShowMessage:(BOOL)showMessage {
    _showMessage = showMessage;
    
    _dotView.hidden = !_showMessage;
}

#pragma mark - Private Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(didPressedMenuItem:)]) {
        [self.delegate didPressedMenuItem:self];
    }
}

- (UIImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.clipsToBounds = YES;
    }
    return _showImageView;
}

- (void)setIsPic:(BOOL)isPic {
    _isPic = isPic;
    if (_isPic) {
        [self addSubview:self.showImageView];
    } else {
        [self.showImageView removeFromSuperview];
    }
}

- (void)setLocalPicName:(NSString *)localPicName {
    _localPicName = localPicName;
    self.showImageView.image = [UIImage imageNamed:self.localPicName];
}

- (void)setRemotePicUrl:(NSString *)remotePicUrl {
    _remotePicUrl = remotePicUrl;
    [self.showImageView sd_setImageWithURL:[NSURL URLWithString:self.remotePicUrl]];
}

- (void)updateIconSizeWith:(CGSize)size {
    if (self.showImageView.superview) {
        [self.showImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(size);
        }];
    }
}

@end

