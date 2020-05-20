
#import "BLMenuView.h"

@interface BLMenuView () <BLMenuItemDelegate>
@property (nonatomic, weak) BLMenuItem *selItem;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, readonly) NSInteger titlesCount;
@property (nonatomic, assign) NSInteger selectIndex;
@end

// 下划线的高度
static CGFloat   const BLProgressHeight = 2.0;
static CGFloat   const BLMenuItemWidth  = 60.0;
static NSInteger const BLMenuItemTagOffset  = 6250;
static NSInteger const BLBadgeViewTagOffset = 1212;
@implementation BLMenuView

#pragma mark - Setter

- (void)setLayoutMode:(BLMenuViewLayoutMode)layoutMode {
    _layoutMode = layoutMode;
    if (!self.superview) { return; }
    [self reload];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!self.scrollView) { return; }
    
    CGFloat leftMargin = self.contentMargin + self.leftView.frame.size.width;
    CGFloat rightMargin = self.contentMargin + self.rightView.frame.size.width;
    CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
    CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.contentMargin;
    
    // Make the contentView center, because system will change menuView's frame if it's a titleView.
    if (startX + contentWidth / 2 != self.bounds.size.width / 2) {
        
        CGFloat xOffset = (self.bounds.size.width - contentWidth) / 2;
        self.leftView.frame = ({
            CGRect frame = self.leftView.frame;
            frame.origin.x = xOffset;
            frame;
        });
        
        self.scrollView.frame = ({
            CGRect frame = self.scrollView.frame;
            frame.origin.x = self.leftView ? CGRectGetMaxX(self.leftView.frame) + self.contentMargin : xOffset;
            frame;
        });
        
        
        self.rightView.frame = ({
            CGRect frame = self.rightView.frame;
            frame.origin.x = CGRectGetMaxX(self.scrollView.frame) + self.contentMargin;
            frame;
        });
        
    }
    
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius {
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.progressView) {
        self.progressView.cornerRadius = _progressViewCornerRadius;
    }
}

- (void)setSpeedFactor:(CGFloat)speedFactor {
    _speedFactor = speedFactor;
    if (self.progressView) {
        self.progressView.speedFactor = _speedFactor;
    }
    
    MJWeakSelf
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BLMenuItem class]]) {
            ((BLMenuItem *)obj).speedFactor = weakSelf.speedFactor;
        }
    }];
    
}

- (void)setProgressWidths:(NSArray *)progressWidths {
    _progressWidths = progressWidths;
    
    if (!self.progressView.superview) { return; }
    
    [self resetFramesFromIndex:0];
}

- (void)setLeftView:(UIView *)leftView {
    if (self.leftView) {
        [self.leftView removeFromSuperview];
        _leftView = nil;
    }
    if (leftView) {
        [self addSubview:leftView];
        _leftView = leftView;
    }
    [self resetFrames];
}

- (void)setRightView:(UIView *)rightView {
    if (self.rightView) {
        [self.rightView removeFromSuperview];
        _rightView = nil;
    }
    if (rightView) {
        [self addSubview:rightView];
        _rightView = rightView;
    }
    [self resetFrames];
}

- (void)setContentMargin:(CGFloat)contentMargin {
    _contentMargin = contentMargin;
    if (self.scrollView) {
        [self resetFrames];
    }
}

#pragma mark - Getter

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = self.selectedColor;
    }
    return _lineColor;
}

- (NSMutableArray *)frames {
    if (_frames == nil) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

- (UIColor *)selectedColor {
    if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:)]) {
        return [self.delegate menuView:self titleColorForState:BLMenuItemStateSelected];
    }
    return [UIColor blackColor];
}

- (UIColor *)normalColor {
    if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:)]) {
        return [self.delegate menuView:self titleColorForState:BLMenuItemStateNormal];
    }
    return [UIColor blackColor];
}

- (CGFloat)selectedSize {
    if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:)]) {
        return [self.delegate menuView:self titleSizeForState:BLMenuItemStateSelected];
    }
    return 18.0;
}

- (CGFloat)normalSize {
    if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:)]) {
        return [self.delegate menuView:self titleSizeForState:BLMenuItemStateNormal];
    }
    return 15.0;
}

- (UIView *)badgeViewAtIndex:(NSInteger)index {
    if (![self.dataSource respondsToSelector:@selector(menuView:badgeViewAtIndex:)]) {
        return nil;
    }
    UIView *badgeView = [self.dataSource menuView:self badgeViewAtIndex:index];
    if (!badgeView) {
        return nil;
    }
    badgeView.tag = index + BLBadgeViewTagOffset;
    
    return badgeView;
}

- (void)setShowBottomLine:(BOOL)showBottomLine{
    _showBottomLine = showBottomLine;
    UIView *bottomLine = [self viewWithTag: 777];
    if (bottomLine) {
        bottomLine.hidden = !showBottomLine;
    }
    
}


#pragma mark - Public Methods

- (BLMenuItem *)itemAtIndex:(NSInteger)index {
    return (BLMenuItem *)[self viewWithTag:(index + BLMenuItemTagOffset)];
}

- (void)setProgressViewIsNaughty:(BOOL)progressViewIsNaughty {
    _progressViewIsNaughty = progressViewIsNaughty;
    if (self.progressView) {
        self.progressView.naughty = progressViewIsNaughty;
    }
}

- (void)reload {
    [self.frames removeAllObjects];
    [self.progressView removeFromSuperview];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
}

- (void)slideMenuAtProgress:(CGFloat)progress {
    if (self.progressView) {
        self.progressView.progress = progress;
    }
    NSInteger tag = (NSInteger)progress + BLMenuItemTagOffset;
    CGFloat rate = progress - tag + BLMenuItemTagOffset;
    BLMenuItem *currentItem = (BLMenuItem *)[self viewWithTag:tag];
    BLMenuItem *nextItem = (BLMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        [self.selItem deselectedWithoutAnimation];
        self.selItem = currentItem;
        [self.selItem selectedWithoutAnimation];
        [self refreshContenOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

- (void)selectItemAtIndex:(NSInteger)index {
    NSInteger tag = index + BLMenuItemTagOffset;
    NSInteger currentIndex = self.selItem.tag - BLMenuItemTagOffset;
    self.selectIndex = index;
    if (index == currentIndex || !self.selItem) { return; }
    
    BLMenuItem *item = (BLMenuItem *)[self viewWithTag:tag];
    [self.selItem deselectedWithoutAnimation];
    self.selItem = item;
    [self.selItem selectedWithoutAnimation];
    [self.progressView setProgressWithOutAnimate:index];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:index currentIndex:currentIndex];
    }
    [self refreshContenOffset];
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
    if (index >= self.titlesCount || index < 0) { return; }
    
    BLMenuItem *item = (BLMenuItem *)[self viewWithTag:(BLMenuItemTagOffset + index)];
    item.text = title;
    if (!update) { return; }
    [self resetFrames];
}

- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
    if (index >= self.titlesCount || index < 0) { return; }
    
    BLMenuItem *item = (BLMenuItem *)[self viewWithTag:(BLMenuItemTagOffset + index)];
    item.attributedText = title;
    if (!update) { return; }
    [self resetFrames];
}

- (void)updateBadgeViewAtIndex:(NSInteger)index {
    UIView *oldBadgeView = [self.scrollView viewWithTag:BLBadgeViewTagOffset + index];
    if (oldBadgeView) {
        [oldBadgeView removeFromSuperview];
    }
    
    [self addBadgeViewAtIndex:index];
    [self resetBadgeFrame:index];
}

// 让选中的item位于中间
- (void)refreshContenOffset {
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        } else {
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

#pragma mark - Data source
- (NSInteger)titlesCount {
    return [self.dataSource numbersOfTitlesInMenuView:self];
}

#pragma mark - Private Methods
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.scrollView) { return; }
    
    [self addScrollView];
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
    
    if (self.selectIndex == 0) { return; }
    [self selectItemAtIndex:self.selectIndex];
}

- (void)resetFrames {
    CGRect frame = self.bounds;
    if (self.rightView) {
        CGRect rightFrame = self.rightView.frame;
        rightFrame.origin.x = frame.size.width - rightFrame.size.width;
        self.rightView.frame = rightFrame;
        frame.size.width -= rightFrame.size.width;
    }
    
    if (self.leftView) {
        CGRect leftFrame = self.leftView.frame;
        leftFrame.origin.x = 0;
        self.leftView.frame = leftFrame;
        frame.origin.x += leftFrame.size.width;
        frame.size.width -= leftFrame.size.width;
    }
    
    frame.origin.x += self.contentMargin;
    frame.size.width -= self.contentMargin * 2;
    self.scrollView.frame = frame;
    UIView *bottomLine = [self viewWithTag:777];
    bottomLine.frame = CGRectMake(0, CGRectGetHeight(self.frame)-1.0/[UIScreen mainScreen].scale, self.frame.size.width, 1.0/[UIScreen mainScreen].scale);
    [self resetFramesFromIndex:0];
//    [self refreshContenOffset];
}

- (void)resetFramesFromIndex:(NSInteger)index {
    [self.frames removeAllObjects];
    [self calculateItemFrames];
    for (NSInteger i = index; i < self.titlesCount; i++) {
        [self resetItemFrame:i];
        [self resetBadgeFrame:i];
    }
    if (!self.progressView.superview) { return; }
    CGRect frame = self.progressView.frame;
    frame.size.width = self.scrollView.contentSize.width;
    if (self.style == BLMenuViewStyleLine || self.style == BLMenuViewStyleTriangle) {
        frame.origin.y = self.frame.size.height - self.progressHeight - self.progressViewBottomSpace;
    } else {
        frame.origin.y = (self.scrollView.frame.size.height - frame.size.height) / 2.0;
    }
    
    self.progressView.frame = frame;
    self.progressView.itemFrames = [self convertProgressWidthsToFrames];
    [self.progressView setNeedsDisplay];
}

- (void)resetItemFrame:(NSInteger)index {
    BLMenuItem *item = (BLMenuItem *)[self viewWithTag:(BLMenuItemTagOffset + index)];
    CGRect frame = [self.frames[index] CGRectValue];
    item.frame = frame;
    if ([self.delegate respondsToSelector:@selector(menuView:didLayoutItemFrame:atIndex:)]) {
        [self.delegate menuView:self didLayoutItemFrame:item atIndex:index];
    }
}

- (void)resetBadgeFrame:(NSInteger)index {
    CGRect frame = [self.frames[index] CGRectValue];
    UIView *badgeView = [self.scrollView viewWithTag:(BLBadgeViewTagOffset + index)];
    if (badgeView) {
        CGRect badgeFrame = [self badgeViewAtIndex:index].frame;
        badgeFrame.origin.x += frame.origin.x;
        badgeView.frame = badgeFrame;
    }
}

- (NSArray *)convertProgressWidthsToFrames {
    if (!self.frames.count) { NSAssert(NO, @"BUUUUUUUG...SHOULDN'T COME HERE!!"); }
    
    if (self.progressWidths.count < self.titlesCount) {
        NSMutableArray *progressFrames = [NSMutableArray arrayWithCapacity:self.frames.count];
        NSInteger count = self.frames.count;
        for (int i = 0; i < count; i++) {
            CGRect itemFrame = [self.frames[i] CGRectValue];
            CGFloat progressWidth = itemFrame.size.width - 2 * self.progressHorizontalSpace;
            CGFloat x = itemFrame.origin.x + (itemFrame.size.width - progressWidth) / 2;
            CGRect progressFrame = CGRectMake(x, itemFrame.origin.y, progressWidth, 0);
            [progressFrames addObject:[NSValue valueWithCGRect:progressFrame]];
        }
        return progressFrames.copy;
    } else {
        NSMutableArray *progressFrames = [NSMutableArray array];
        NSInteger count = (self.frames.count <= self.progressWidths.count) ? self.frames.count : self.progressWidths.count;
        for (int i = 0; i < count; i++) {
            CGRect itemFrame = [self.frames[i] CGRectValue];
            CGFloat progressWidth = [self.progressWidths[i] floatValue];
            CGFloat x = itemFrame.origin.x + (itemFrame.size.width - progressWidth) / 2;
            CGRect progressFrame = CGRectMake(x, itemFrame.origin.y, progressWidth, 0);
            [progressFrames addObject:[NSValue valueWithCGRect:progressFrame]];
        }
        return progressFrames.copy;
    }
}

- (void)addBadgeViews {
    NSInteger count = self.titlesCount;
    for (int i = 0; i < count; i++) {
        [self addBadgeViewAtIndex:i];
    }
}

- (void)addBadgeViewAtIndex:(NSInteger)index {
    UIView *badgeView = [self badgeViewAtIndex:index];
    if (badgeView) {
        [self.scrollView addSubview:badgeView];
    }
}

- (void)makeStyle {
    CGRect frame = CGRectZero;
    if (self.style == BLMenuViewStyleDefault) { return; }
    if (self.style == BLMenuViewStyleLine) {
        self.progressHeight = self.progressHeight > 0 ? self.progressHeight : BLProgressHeight;
        frame = CGRectMake(0, self.frame.size.height - self.progressHeight - self.progressViewBottomSpace, self.scrollView.contentSize.width, self.progressHeight);
    } else {
        self.progressHeight = self.progressHeight > 0 ? self.progressHeight : self.frame.size.height * 0.8;
        frame = CGRectMake(0, (self.frame.size.height - self.progressHeight) / 2, self.scrollView.contentSize.width, self.progressHeight);
        self.progressViewCornerRadius = self.progressViewCornerRadius > 0 ? self.progressViewCornerRadius : self.progressHeight / 2.0;
    }
    [self bl_addProgressViewWithFrame:frame
                           isTriangle:(self.style == BLMenuViewStyleTriangle)
                            hasBorder:(self.style == BLMenuViewStyleSegmented)
                               hollow:(self.style == BLMenuViewStyleFloodHollow)
                         cornerRadius:self.progressViewCornerRadius];
}

- (void)deselectedItemsIfNeeded {
    MJWeakSelf
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[BLMenuItem class]] || obj == weakSelf.selItem) {
            return;
        }
        [(BLMenuItem *)obj deselectedWithoutAnimation];
    }];
}

- (void)addScrollView {
    CGFloat width = self.frame.size.width - self.contentMargin * 2;
    CGFloat height = self.frame.size.height;
    CGRect frame = CGRectMake(self.contentMargin, 0, width, height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.scrollsToTop = NO;
    scrollView.decelerationRate = 0.1f;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    //临时增加一条底线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, height-1.0/[UIScreen mainScreen].scale, self.frame.size.width, 1.0/[UIScreen mainScreen].scale)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.08f];
    bottomLine.tag = 777;
    [self addSubview:bottomLine];
}

- (void)addItems {
    [self calculateItemFrames];
    
    NSInteger count = self.titlesCount;
    for (int i = 0; i < count; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        BLMenuItem *item = [[BLMenuItem alloc] initWithFrame:frame];
        if (self.fontName) {
            item.font = [UIFont fontWithName:self.fontName size:self.selectedSize];
        } else {
            item.font = [UIFont systemFontOfSize:self.selectedSize];
        }
        item.tag = (i+BLMenuItemTagOffset);
        item.delegate = self;
        item.text = [self.dataSource menuView:self titleAtIndex:i];
        item.textAlignment = NSTextAlignmentCenter;
        if ([self.dataSource respondsToSelector:@selector(menuView:initialMenuItem:atIndex:)]) {
            item = [self.dataSource menuView:self initialMenuItem:item atIndex:i];
        }
        item.userInteractionEnabled = YES;
        item.backgroundColor = [UIColor clearColor];
        item.normalSize    = self.normalSize;
        item.selectedSize  = self.selectedSize;
        item.normalColor   = self.normalColor;
        item.selectedColor = self.selectedColor;
        item.speedFactor   = self.speedFactor;
        if (i == 0) {
            [item selectedWithoutAnimation];
            self.selItem = item;
        } else {
            [item deselectedWithoutAnimation];
        }
        [self.scrollView addSubview:item];
    }
}

// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
// 这里与后面的 `-addItems` 做了重复的操作，并不是很合理
- (void)calculateItemFrames {
    CGFloat contentWidth = [self itemMarginAtIndex:0];
    NSInteger count = self.titlesCount;
    for (int i = 0; i < count; i++) {
        CGFloat itemW = BLMenuItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemW = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemW, self.frame.size.height);
        // 记录frame
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemW + [self itemMarginAtIndex:i+1];
    }
    // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
    if (contentWidth < self.scrollView.frame.size.width) {
        CGFloat distance = self.scrollView.frame.size.width - contentWidth;
        CGFloat (^shiftDis)(int);
        switch (self.layoutMode) {
            case BLMenuViewLayoutModeScatter: {
                CGFloat gap = distance / (self.titlesCount + 1);
                shiftDis = ^CGFloat(int index) { return gap * (index + 1); };
                break;
            }
            case BLMenuViewLayoutModeLeft: {
                shiftDis = ^CGFloat(int index) { return 0.0; };
                break;
            }
            case BLMenuViewLayoutModeRight: {
                shiftDis = ^CGFloat(int index) { return distance; };
                break;
            }
            case BLMenuViewLayoutModeCenter: {
                shiftDis = ^CGFloat(int index) { return distance / 2; };
                break;
            }
        }
        
        NSInteger frameCount = self.frames.count;
        for (int i = 0; i < frameCount; i++) {
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += shiftDis(i);
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.scrollView.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (CGFloat)itemMarginAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:itemMarginAtIndex:)]) {
        return [self.delegate menuView:self itemMarginAtIndex:index];
    }
    return 0.0;
}

// MARK:Progress View
- (void)bl_addProgressViewWithFrame:(CGRect)frame isTriangle:(BOOL)isTriangle hasBorder:(BOOL)hasBorder hollow:(BOOL)isHollow cornerRadius:(CGFloat)cornerRadius {
    BLProgressView *pView = [[BLProgressView alloc] initWithFrame:frame];
    pView.itemFrames = [self convertProgressWidthsToFrames];
    pView.color = self.lineColor.CGColor;
    pView.isTriangle = isTriangle;
    pView.hasBorder = hasBorder;
    pView.hollow = isHollow;
    pView.cornerRadius = cornerRadius;
    pView.naughty = self.progressViewIsNaughty;
    pView.speedFactor = self.speedFactor;
    pView.backgroundColor = [UIColor clearColor];
    self.progressView = pView;
    [self.scrollView insertSubview:self.progressView atIndex:0];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(BLMenuItem *)menuItem {
    if (self.selItem == menuItem) return;
    
    CGFloat progress = menuItem.tag - BLMenuItemTagOffset;
    [self.progressView moveToPostion:progress];
    
    NSInteger currentIndex = self.selItem.tag - BLMenuItemTagOffset;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:menuItem.tag-BLMenuItemTagOffset currentIndex:currentIndex];
    }
    
    menuItem.selected = YES;
    self.selItem.selected = NO;
    self.selItem = menuItem;
    
    NSTimeInterval delay = self.style == BLMenuViewStyleDefault ? 0 : 0.3f;
    MJWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 让选中的item位于中间
        [weakSelf refreshContenOffset];
    });
}

@end
