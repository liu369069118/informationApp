
#import "BLPageController.h"

NSString *const BLControllerDidAddToSuperViewNotification = @"BLControllerDidAddToSuperViewNotification";
NSString *const BLControllerDidFullyDisplayedNotification = @"BLControllerDidFullyDisplayedNotification";

static NSInteger const kBLUndefinedIndex = -1;
static NSInteger const kBLControllerCountUndefined = -1;
@interface BLPageController () {
    CGFloat _viewHeight, _viewWidth, _viewX, _viewY, _targetX, _superviewHeight;
    BOOL    _hasInited, _shouldNotScroll, _isTabBarHidden;
    NSInteger _initializedIndex, _controllerConut, _markedSelectIndex;
}
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 当前展示在屏幕上的控制器，方便在滚动的时候读取 (避免不必要计算)
@property (nonatomic, strong) NSMutableDictionary *displayVC;
// 用于记录销毁的viewController的位置 (如果它是某一种scrollView的Controller的话)
@property (nonatomic, strong) NSMutableDictionary *posRecords;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSMutableDictionary *backgroundCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;
@property (nonatomic, readonly) NSInteger childControllersCount;
@end

@implementation BLPageController

#pragma mark - Lazy Loading
- (NSMutableDictionary *)posRecords {
    if (_posRecords == nil) {
        _posRecords = [[NSMutableDictionary alloc] init];
    }
    return _posRecords;
}

- (NSMutableDictionary *)displayVC {
    if (_displayVC == nil) {
        _displayVC = [[NSMutableDictionary alloc] init];
    }
    return _displayVC;
}

- (NSMutableDictionary *)backgroundCache {
    if (_backgroundCache == nil) {
        _backgroundCache = [[NSMutableDictionary alloc] init];
    }
    return _backgroundCache;
}

#pragma mark - Public Methods

- (instancetype)initWithViewControllerClasses:(NSArray<Class> *)classes andTheirTitles:(NSArray<NSString *> *)titles {
    if (self = [super init]) {
        NSParameterAssert(classes.count == titles.count);
        _viewControllerClasses = [NSArray arrayWithArray:classes];
        _titles = [NSArray arrayWithArray:titles];
        
        [self bl_setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self bl_setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self bl_setup];
    }
    return self;
}

- (void)setEdgesForExtendedLayout:(UIRectEdge)edgesForExtendedLayout {
    if (self.edgesForExtendedLayout == edgesForExtendedLayout) { return; }
    [super setEdgesForExtendedLayout:edgesForExtendedLayout];
    
    if (_hasInited) {
        _hasInited = NO;
        [self viewDidLayoutSubviews];
    }
}

- (void)forceLayoutSubviews {
    _hasInited = NO;
    [self viewDidLayoutSubviews];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    
    if (!self.scrollView) { return; }
    self.scrollView.scrollEnabled = scrollEnable;
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius {
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.menuView) {
        self.menuView.progressViewCornerRadius = progressViewCornerRadius;
    }
}

- (void)setMenuViewLayoutMode:(BLMenuViewLayoutMode)menuViewLayoutMode {
    _menuViewLayoutMode = menuViewLayoutMode;
    if (self.menuView.superview) {
        [self bl_resetMenuView];
    }
}

- (void)setCachePolicy:(BLPageControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    if (cachePolicy != BLPageControllerCachePolicyDisabled) {
        self.memCache.countLimit = _cachePolicy;
    }
}

- (void)setSelectIndex:(int)selectIndex {
    _selectIndex = selectIndex;
    _markedSelectIndex = kBLUndefinedIndex;
    if (self.menuView && _hasInited) {
        [self.menuView selectItemAtIndex:selectIndex];
    } else {
        _markedSelectIndex = selectIndex;
    }
}

- (void)setProgressViewIsNaughty:(BOOL)progressViewIsNaughty {
    _progressViewIsNaughty = progressViewIsNaughty;
    if (self.menuView) {
        self.menuView.progressViewIsNaughty = progressViewIsNaughty;
    }
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    _progressWidth = progressWidth;
    self.progressViewWidths = ({
        NSInteger childCount = self.childControllersCount;
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:childCount];
        for (int i = 0; i < childCount; i++) {
            [tmp addObject:@(progressWidth)];
        }
        tmp.copy;
    });
}

- (void)setProgressHorizontalSpace:(CGFloat)progressHorizontalSpace {
    _progressHorizontalSpace = progressHorizontalSpace;
    
    if (self.menuView) {
        self.menuView.progressHorizontalSpace = _progressHorizontalSpace;
    }
}

- (void)setProgressViewWidths:(NSArray *)progressViewWidths {
    _progressViewWidths = progressViewWidths;
    if (self.menuView) {
        self.menuView.progressWidths = progressViewWidths;
    }
}

- (void)setMenuViewContentMargin:(CGFloat)menuViewContentMargin {
    _menuViewContentMargin = menuViewContentMargin;
    if (self.menuView) {
        self.menuView.contentMargin = menuViewContentMargin;
    }
}

- (void)setViewFrame:(CGRect)viewFrame {
    if (CGRectEqualToRect(viewFrame, _viewFrame)) { return; }
    
    _viewFrame = viewFrame;
    if (self.menuView) {
        _hasInited = NO;
        [self viewDidLayoutSubviews];
    }
}

- (void)reloadData {
    [self bl_clearDatas];
    
    if (!self.childControllersCount) { return; }
    
    [self bl_resetScrollView];
    [self.memCache removeAllObjects];
    [self bl_resetMenuView];
    [self viewDidLayoutSubviews];
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.menuView updateTitle:title atIndex:index andWidth:NO];
}

- (void)updateAttributeTitle:(NSAttributedString * _Nonnull)title atIndex:(NSInteger)index {
    [self.menuView updateAttributeTitle:title atIndex:index andWidth:NO];
}

- (void)updateTitle:(NSString *)title andWidth:(CGFloat)width atIndex:(NSInteger)index {
    if (self.itemsWidths && index < self.itemsWidths.count) {
        NSMutableArray *mutableWidths = [NSMutableArray arrayWithArray:self.itemsWidths];
        mutableWidths[index] = @(width);
        self.itemsWidths = [mutableWidths copy];
    } else {
        NSInteger childCount = self.childControllersCount;
        NSMutableArray *mutableWidths = [NSMutableArray arrayWithCapacity:childCount];
        for (int i = 0; i < childCount; i++) {
            CGFloat itemWidth = (i == index) ? width : self.menuItemWidth;
            [mutableWidths addObject:@(itemWidth)];
        }
        self.itemsWidths = [mutableWidths copy];
    }
    [self.menuView updateTitle:title atIndex:index andWidth:YES];
}

- (void)setShowOnNavigationBar:(BOOL)showOnNavigationBar {
    if (_showOnNavigationBar == showOnNavigationBar) {
        return;
    }
    
    _showOnNavigationBar = showOnNavigationBar;
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        [self bl_addMenuView];
        [self forceLayoutSubviews];
        [self.menuView slideMenuAtProgress:self.selectIndex];
    }
}

#pragma mark - Notification
- (void)willResignActive:(NSNotification *)notification {
    NSInteger childCount = self.childControllersCount;
    for (int i = 0; i < childCount; i++) {
        id obj = [self.memCache objectForKey:@(i)];
        if (obj) {
            [self.backgroundCache setObject:obj forKey:@(i)];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    for (NSNumber *key in self.backgroundCache.allKeys) {
        if (![self.memCache objectForKey:key]) {
            [self.memCache setObject:self.backgroundCache[key] forKey:key];
        }
    }
    [self.backgroundCache removeAllObjects];
}

#pragma mark - Delegate
- (NSDictionary *)infoWithIndex:(NSInteger)index {
    NSString *title = [self titleAtIndex:index];
    return @{@"title": title ? title : @"", @"index": @(index)};
}

- (void)willCachedController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willCachedViewController:withInfo:)]) {
        NSDictionary *info = [self infoWithIndex:index];
        [self.delegate pageController:self willCachedViewController:vc withInfo:info];
    }
}

- (void)willEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    _selectIndex = (int)index;
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willEnterViewController:withInfo:)]) {
        NSDictionary *info = [self infoWithIndex:index];
        [self.delegate pageController:self willEnterViewController:vc withInfo:info];
    }
}

// 完全进入控制器 (即停止滑动后调用)
- (void)didEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (!self.childControllersCount) { return; }
    NSDictionary *info = [self infoWithIndex:index];
    if ([self.delegate respondsToSelector:@selector(pageController:didEnterViewController:withInfo:)]) {
        [self.delegate pageController:self didEnterViewController:vc withInfo:info];
    }
    
    // 当控制器创建时，调用延迟加载的代理方法
    if (_initializedIndex == index && [self.delegate respondsToSelector:@selector(pageController:lazyLoadViewController:withInfo:)]) {
        [self.delegate pageController:self lazyLoadViewController:vc withInfo:info];
        _initializedIndex = kBLUndefinedIndex;
    }
    
    // 根据 preloadPolicy 预加载控制器
    if (self.preloadPolicy == BLPageControllerPreloadPolicyNever) { return; }
    int start = 0;
    int end = (int)self.childControllersCount - 1;
    if (index > self.preloadPolicy) {
        start = (int)index - self.preloadPolicy;
    }
    if (self.childControllersCount - 1 > self.preloadPolicy + index) {
        end = (int)index + self.preloadPolicy;
    }
    for (int i = start; i <= end; i++) {
        // 如果已存在，不需要预加载
        if (![self.memCache objectForKey:@(i)] && !self.displayVC[@(i)]) {
            [self bl_addViewControllerAtIndex:i];
            [self bl_postAddToSuperViewNotificationWithIndex:i];
        }
    }
    _selectIndex = (int)index;
}

#pragma mark - Data source
- (NSInteger)childControllersCount {
    if (_controllerConut == kBLControllerCountUndefined) {
        if ([self.dataSource respondsToSelector:@selector(numbersOfChildControllersInPageController:)]) {
            _controllerConut = [self.dataSource numbersOfChildControllersInPageController:self];
        } else {
            _controllerConut = self.viewControllerClasses.count;
        }
    }
    return _controllerConut;
}

- (UIViewController *)initializeViewControllerAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pageController:viewControllerAtIndex:)]) {
        return [self.dataSource pageController:self viewControllerAtIndex:index];
    }
    return [[self.viewControllerClasses[index] alloc] init];
}

- (NSString * _Nonnull)titleAtIndex:(NSInteger)index {
    NSString *title = nil;
    if ([self.dataSource respondsToSelector:@selector(pageController:titleAtIndex:)]) {
        title = [self.dataSource pageController:self titleAtIndex:index];
    } else {
        title = self.titles[index];
    }
    return (title ? title : @"");
}

#pragma mark - Private Methods

- (void)bl_resetScrollView {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }
    [self bl_addScrollView];
    [self bl_addViewControllerAtIndex:self.selectIndex];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}

- (void)bl_clearDatas {
    _controllerConut = kBLControllerCountUndefined;
    _hasInited = NO;
    NSUInteger maxIndex = (self.childControllersCount - 1 > 0) ? (self.childControllersCount - 1) : 0;
    _selectIndex = self.selectIndex < self.childControllersCount ? self.selectIndex : (int)maxIndex;
    if (self.progressWidth > 0) { self.progressWidth = self.progressWidth; }
    
    NSArray *displayingViewControllers = self.displayVC.allValues;
    for (UIViewController *vc in displayingViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    self.memoryWarningCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bl_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bl_growCachePolicyToHigh) object:nil];
    self.currentViewController = nil;
    [self.posRecords removeAllObjects];
    [self.displayVC removeAllObjects];
}

// 当子控制器init完成时发送通知
- (void)bl_postAddToSuperViewNotificationWithIndex:(int)index {
    if (!self.postNotification) { return; }
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:BLControllerDidAddToSuperViewNotification
                                                        object:info];
}

// 当子控制器完全展示在user面前时发送通知
- (void)bl_postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    if (!self.postNotification) { return; }
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:BLControllerDidFullyDisplayedNotification
                                                        object:info];
}

// 初始化一些参数，在init中调用
- (void)bl_setup {
    _titleSizeSelected  = 16.0f;
    _titleSizeNormal    = 14.0f;
    _titleColorSelected = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.87f];
    _titleColorNormal   = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.38f];
    
    _menuBGColor   = [UIColor whiteColor];
    _menuHeight    = 44.0f;
    _progressWidth = 16.0f;
    _progressViewCornerRadius = 1.5f;
    _progressHeight = 3.0f;
    _progressColor = [UIColor colorWithHexString:@"45B7FF"];
    _progressViewBottomSpace = 3.f;
    
    _menuItemWidth = 65.0f;
    
    _memCache = [[NSCache alloc] init];
    _initializedIndex = kBLUndefinedIndex;
    _markedSelectIndex = kBLUndefinedIndex;
    _controllerConut  = kBLControllerCountUndefined;
    _scrollEnable = YES;
    
    self.automaticallyCalculatesItemWidths = NO;
    self.progressViewIsNaughty = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.preloadPolicy = BLPageControllerPreloadPolicyNever;
    self.cachePolicy = BLPageControllerCachePolicyNoLimit;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// 包括宽高，子控制器视图 frame
- (void)bl_calculateSize {
    CGFloat navigationHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    UIView *tabBar = [self bl_bottomView];
    CGFloat height = (tabBar && !tabBar.hidden) ? CGRectGetHeight(tabBar.frame) : 0;
    CGFloat tarBarHeight = (self.hidesBottomBarWhenPushed == YES) ? 0 : height;
    // 计算相对 window 的绝对 frame (self.view.window 可能为 nil)
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    CGRect absoluteRect = [self.view convertRect:self.view.bounds toView:mainWindow];
    navigationHeight -= absoluteRect.origin.y;
    tarBarHeight -= mainWindow.frame.size.height - CGRectGetMaxY(absoluteRect);
    
    _viewX = self.viewFrame.origin.x;
    _viewY = self.viewFrame.origin.y;
    if (CGRectEqualToRect(self.viewFrame, CGRectZero)) {
        _viewWidth = self.view.frame.size.width;
        _viewHeight = self.view.frame.size.height - self.menuHeight - self.menuViewBottomSpace - navigationHeight - tarBarHeight;
        _viewY += navigationHeight;
    } else {
        _viewWidth = self.viewFrame.size.width;
        _viewHeight = self.viewFrame.size.height - self.menuHeight - self.menuViewBottomSpace;
    }
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        _viewHeight += self.menuHeight;
    }    // 重新计算各个控制器视图的宽高
    
    NSInteger childCount = self.childControllersCount;
    _childViewFrames = [NSMutableArray arrayWithCapacity:childCount];
    for (int i = 0; i < childCount; i++) {
        CGRect frame = CGRectMake(i*_viewWidth, 0, _viewWidth, _viewHeight);
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (void)bl_addScrollView {
    BLScrollView *scrollView = [[BLScrollView alloc] init];
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = self.bounces;
    scrollView.otherGestureRecognizerSimultaneously = self.otherGestureRecognizerSimultaneously;
    scrollView.scrollEnabled = self.scrollEnable;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    //    if (!self.navigationController) { return; }
    //    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {
    //        [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    //    }
}

- (void)bl_addMenuView {
    CGFloat menuY = _viewY;
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat menuHeight = self.menuHeight > navHeight ? navHeight : self.menuHeight;
        menuY = (navHeight - menuHeight) / 2;
    }
    
    CGRect frame = CGRectMake(_viewX, menuY, _viewWidth, self.menuHeight);
    BLMenuView *menuView = [[BLMenuView alloc] initWithFrame:frame];
    menuView.backgroundColor = self.menuBGColor;
    menuView.delegate = self;
    menuView.dataSource = self;
    menuView.style = self.menuViewStyle;
    menuView.layoutMode = self.menuViewLayoutMode;
    menuView.progressHeight = self.progressHeight;
    menuView.contentMargin = self.menuViewContentMargin;
    menuView.progressViewBottomSpace = self.progressViewBottomSpace;
    menuView.progressWidths = self.progressViewWidths;
    menuView.progressHorizontalSpace = self.progressHorizontalSpace;
    menuView.progressViewIsNaughty = self.progressViewIsNaughty;
    menuView.progressViewCornerRadius = self.progressViewCornerRadius;
    if (self.titleFontName) {
        menuView.fontName = self.titleFontName;
    }
    if (self.progressColor) {
        menuView.lineColor = self.progressColor;
    }
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        self.navigationItem.titleView = menuView;
    } else {
        [self.view addSubview:menuView];
    }
    self.menuView = menuView;
}

- (void)bl_layoutChildViewControllers {
    int currentPage = (int)self.scrollView.contentOffset.x / _viewWidth;
    int start = currentPage == 0 ? currentPage : (currentPage - 1);
    int end = (currentPage == self.childControllersCount - 1) ? currentPage : (currentPage + 1);
    for (int i = start; i <= end; i++) {
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        if ([self bl_isInScreen:frame]) {
            if (vc == nil) {
                [self bl_initializedControllerWithIndexIfNeeded:i];
            }
        } else {
            if (vc) {
                // vc不在视野中且存在，移除他
                [self bl_removeViewController:vc atIndex:i];
            }
        }
    }
}

// 创建或从缓存中获取控制器并添加到视图上
- (void)bl_initializedControllerWithIndexIfNeeded:(NSInteger)index {
    // 先从 cache 中取
    UIViewController *vc = [self.memCache objectForKey:@(index)];
    if (vc) {
        // cache 中存在，添加到 scrollView 上，并放入display
        [self bl_addCachedViewController:vc atIndex:index];
    } else {
        // cache 中也不存在，创建并添加到display
        [self bl_addViewControllerAtIndex:(int)index];
    }
    [self bl_postAddToSuperViewNotificationWithIndex:(int)index];
}

- (void)bl_removeSuperfluousViewControllersIfNeeded {
    MJWeakSelf
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [weakSelf.childViewFrames[index] CGRectValue];
        if (![weakSelf bl_isInScreen:frame]) {
            [weakSelf bl_removeViewController:vc atIndex:index];
        }
    }];
}

- (void)bl_addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];
}

// 创建并添加子控制器
- (void)bl_addViewControllerAtIndex:(int)index {
    _initializedIndex = index;
    UIViewController *viewController = [self initializeViewControllerAtIndex:index];
    if (self.values.count == self.childControllersCount && self.keys.count == self.childControllersCount) {
        [viewController setValue:self.values[index] forKey:self.keys[index]];
    }
    [self addChildViewController:viewController];
    CGRect frame = self.childViewFrames.count ? [self.childViewFrames[index] CGRectValue] : self.view.frame;
    viewController.view.frame = frame;
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];
    
    [self bl_backToPositionIfNeeded:viewController atIndex:index];
}

// 移除控制器，且从display中移除
- (void)bl_removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self bl_rememberPositionIfNeeded:viewController atIndex:index];
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];
    
    // 放入缓存
    if (self.cachePolicy == BLPageControllerCachePolicyDisabled) {
        return;
    }
    
    if (![self.memCache objectForKey:@(index)]) {
        [self willCachedController:viewController atIndex:index];
        [self.memCache setObject:viewController forKey:@(index)];
    }
}

- (void)bl_backToPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    if ([self.memCache objectForKey:@(index)]) return;
    UIScrollView *scrollView = [self bl_isKindOfScrollViewController:controller];
    if (scrollView) {
        NSValue *pointValue = self.posRecords[@(index)];
        if (pointValue) {
            CGPoint pos = [pointValue CGPointValue];
            [scrollView setContentOffset:pos];
        }
    }
}

- (void)bl_rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    UIScrollView *scrollView = [self bl_isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

- (UIScrollView *)bl_isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    } else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

- (BOOL)bl_isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat ScreenWidth = self.scrollView.frame.size.width;
    
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x-contentOffsetX < ScreenWidth) {
        return YES;
    } else {
        return NO;
    }
}

- (void)bl_resetMenuView {
    if (!self.menuView) {
        [self bl_addMenuView];
    } else {
        [self.menuView reload];
        if (self.menuView.userInteractionEnabled == NO) {
            self.menuView.userInteractionEnabled = YES;
        }
        if (self.selectIndex != 0) {
            [self.menuView selectItemAtIndex:self.selectIndex];
        }
        [self.view bringSubviewToFront:self.menuView];
    }
}

- (void)bl_growCachePolicyAfterMemoryWarning {
    self.cachePolicy = BLPageControllerCachePolicyBalanced;
    [self performSelector:@selector(bl_growCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)bl_growCachePolicyToHigh {
    self.cachePolicy = BLPageControllerCachePolicyHigh;
}

- (UIView *)bl_bottomView {
    return self.tabBarController.tabBar ? self.tabBarController.tabBar : self.navigationController.toolbar;
}

#pragma mark - Adjust Frame
- (void)bl_adjustScrollViewFrame {
    // While rotate at last page, set scroll frame will call `-scrollViewDidScroll:` delegate
    // It's not my expectation, so I use `_shouldNotScroll` to lock it.
    // Wait for a better solution.
    _shouldNotScroll = YES;
    CGRect scrollFrame = CGRectMake(_viewX, _viewY + self.menuHeight + self.menuViewBottomSpace, _viewWidth, _viewHeight);
    CGFloat oldContentOffsetX = self.scrollView.contentOffset.x;
    CGFloat contentWidth = self.scrollView.contentSize.width;
    scrollFrame.origin.y -= self.showOnNavigationBar && self.navigationController.navigationBar ? self.menuHeight : 0;
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = CGSizeMake(self.childControllersCount * _viewWidth, 0);
    CGFloat xContentOffset = contentWidth == 0 ? self.selectIndex * _viewWidth : oldContentOffsetX / contentWidth * self.childControllersCount * _viewWidth;
    [self.scrollView setContentOffset:CGPointMake(xContentOffset, 0)];
    _shouldNotScroll = NO;
}

- (void)bl_adjustDisplayingViewControllersFrame {
    MJWeakSelf
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [weakSelf.childViewFrames[index] CGRectValue];
        vc.view.frame = frame;
    }];
}

- (void)bl_adjustMenuViewFrame {
    // 根据是否在导航栏上展示调整frame
    CGFloat menuHeight = self.menuHeight;
    __block CGFloat menuX = _viewX;
    __block CGFloat menuY = _viewY;
    __block CGFloat rightWidth = 0;
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[BLMenuView class]] && ![obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")] && obj.alpha != 0 && obj.hidden == NO) {
                CGFloat maxX = CGRectGetMaxX(obj.frame);
                if (maxX < _viewWidth / 2) {
                    CGFloat leftWidth = maxX;
                    menuX = menuX > leftWidth ? menuX : leftWidth;
                }
                CGFloat minX = CGRectGetMinX(obj.frame);
                if (minX > _viewWidth / 2) {
                    CGFloat width = (_viewWidth - minX);
                    rightWidth = rightWidth > width ? rightWidth : width;
                }
            }
        }];
        CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
        menuHeight = self.menuHeight > navHeight ? navHeight : self.menuHeight;
        menuY = (navHeight - menuHeight) / 2;
    }
    CGFloat menuWidth = _viewWidth - menuX - rightWidth;
    self.menuView.frame = CGRectMake(menuX, menuY, menuWidth, menuHeight);
    [self.menuView resetFrames];
}

- (CGFloat)bl_calculateItemWithAtIndex:(NSInteger)index {
    NSString *title = [self titleAtIndex:index];
    UIFont *titleFont = self.titleFontName ? [UIFont fontWithName:self.titleFontName size:self.titleSizeSelected] : [UIFont systemFontOfSize:self.titleSizeSelected];
    NSDictionary *attrs = @{NSFontAttributeName: titleFont};
    CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
    return ceil(itemWidth);
}

- (void)bl_delaySelectIndexIfNeeded {
    if (_markedSelectIndex != kBLUndefinedIndex) {
        self.selectIndex = (int)_markedSelectIndex;
    }
}

- (void)bl_clearDataMemory {
    self.memoryWarningCount++;
    self.cachePolicy = BLPageControllerCachePolicyLowMemory;
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bl_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bl_growCachePolicyToHigh) object:nil];
    
    [self.memCache removeAllObjects];
    [self.posRecords removeAllObjects];
    self.posRecords = nil;
    
    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(bl_growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.childControllersCount) return;
    
    [self bl_calculateSize];
    
    [self bl_addScrollView];
    
    [self bl_addViewControllerAtIndex:self.selectIndex];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    
    [self bl_addMenuView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.childControllersCount) return;
    
    CGFloat oldSuperviewHeight = _superviewHeight;
    _superviewHeight = self.view.frame.size.height;
    
    BOOL oldTabBarIsHidden = _isTabBarHidden;
    _isTabBarHidden = [self bl_bottomView].hidden;
    
    BOOL shouldNotLayout = (_hasInited && _superviewHeight == oldSuperviewHeight && _isTabBarHidden == oldTabBarIsHidden);
    if (shouldNotLayout) return;
    
    // 计算宽高及子控制器的视图frame
    [self bl_calculateSize];
    
    [self bl_adjustScrollViewFrame];
    
    [self bl_adjustMenuViewFrame];
    
    [self bl_adjustDisplayingViewControllersFrame];
    
    [self bl_removeSuperfluousViewControllersIfNeeded];
    
    _hasInited = YES;
    [self.view layoutIfNeeded];
    [self bl_delaySelectIndexIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.childControllersCount) { return; }
    
    [self bl_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self bl_clearDataMemory];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    if (_shouldNotScroll || !_hasInited) { return; }
    
    [self bl_layoutChildViewControllers];
    if (_startDragging) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        if (contentOffsetX > scrollView.contentSize.width - _viewWidth) {
            contentOffsetX = scrollView.contentSize.width - _viewWidth;
        }
        CGFloat rate = contentOffsetX / _viewWidth;
        [self.menuView slideMenuAtProgress:rate];
    }
    
    // Fix scrollView.contentOffset.y -> (-20) unexpectedly.
    if (scrollView.contentOffset.y == 0) { return; }
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = 0.0;
    scrollView.contentOffset = contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    _startDragging = YES;
    self.menuView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    self.menuView.userInteractionEnabled = YES;
    _selectIndex = (int)scrollView.contentOffset.x / _viewWidth;
    [self bl_removeSuperfluousViewControllersIfNeeded];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self bl_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self bl_removeSuperfluousViewControllersIfNeeded];
    [self bl_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    if (!decelerate) {
        self.menuView.userInteractionEnabled = YES;
        CGFloat rate = _targetX / _viewWidth;
        [self.menuView slideMenuAtProgress:rate];
        [self.menuView deselectedItemsIfNeeded];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (![scrollView isKindOfClass:BLScrollView.class]) { return; }
    
    _targetX = targetContentOffset->x;
}

#pragma mark - BLMenuView Delegate
- (void)menuView:(BLMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    if (!_hasInited) { return; }
    _selectIndex = (int)index;
    _startDragging = NO;
    CGPoint targetP = CGPointMake(_viewWidth*index, 0);
    [self.scrollView setContentOffset:targetP animated:self.pageAnimatable];
    if (!self.pageAnimatable) {
        // 由于不触发 -scrollViewDidScroll: 手动处理控制器
        [self bl_removeSuperfluousViewControllersIfNeeded];
        UIViewController *currentViewController = self.displayVC[@(currentIndex)];
        if (currentViewController) {
            [self bl_removeViewController:currentViewController atIndex:currentIndex];
        }
        [self bl_layoutChildViewControllers];
        self.currentViewController = self.displayVC[@(self.selectIndex)];
        [self bl_postFullyDisplayedNotificationWithCurrentIndex:(int)index];
        [self didEnterController:self.currentViewController atIndex:index];
    }
}

- (CGFloat)menuView:(BLMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    if (self.automaticallyCalculatesItemWidths) {
        return [self bl_calculateItemWithAtIndex:index];
    }
    
    if (self.itemsWidths.count == self.childControllersCount) {
        return [self.itemsWidths[index] floatValue];
    }
    return self.menuItemWidth;
}

- (CGFloat)menuView:(BLMenuView *)menu itemMarginAtIndex:(NSInteger)index {
    if (self.itemsMargins.count == self.childControllersCount + 1) {
        return [self.itemsMargins[index] floatValue];
    }
    return self.itemMargin;
}

- (CGFloat)menuView:(BLMenuView *)menu titleSizeForState:(BLMenuItemState)state {
    switch (state) {
        case BLMenuItemStateSelected: {
            return self.titleSizeSelected;
            break;
        }
        case BLMenuItemStateNormal: {
            return self.titleSizeNormal;
            break;
        }
    }
}

- (UIColor *)menuView:(BLMenuView *)menu titleColorForState:(BLMenuItemState)state {
    switch (state) {
        case BLMenuItemStateSelected: {
            return self.titleColorSelected;
            break;
        }
        case BLMenuItemStateNormal: {
            return self.titleColorNormal;
            break;
        }
    }
}

#pragma mark - BLMenuViewDataSource
- (NSInteger)numbersOfTitlesInMenuView:(BLMenuView *)menu {
    return self.childControllersCount;
}

- (NSString *)menuView:(BLMenuView *)menu titleAtIndex:(NSInteger)index {
    return [self titleAtIndex:index];
}

@end
