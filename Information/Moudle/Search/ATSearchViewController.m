//
//  ATSearchViewController.m
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATSearchViewController.h"
#import "JKRSearchController.h"
#import "JKRSearchResultViewController.h"
#import "JKRTestViewController.h"

#define kSafeAreaNavHeight (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO) ? 88 : 64)

@interface ATSearchViewController ()<UITableViewDataSource, UITableViewDelegate, JKRSearchControllerhResultsUpdating, JKRSearchControllerDelegate, JKRSearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JKRSearchController *searchController;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILabel *searchFooter;

@property (nonatomic, strong) NSArray<NSString *> *searchAllData; //检索数据中心
@property (nonatomic, strong) NSDictionary *gpcodeDatas;

@end

@implementation ATSearchViewController

static NSString *const CellIdentifier = @"WEICHAT_ID";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitle:@"信息检索"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_navigation_back_white"] style:UIBarButtonItemStyleDone target:self action:@selector(goback)];
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    [self.tableView setTableHeaderView:self.searchController.searchBar];
    self.jkr_lightStatusBar = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearSearchHistory)];
    _searchFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    _searchFooter.userInteractionEnabled = YES;
    _searchFooter.font = [UIFont systemFontOfSize:14];
    _searchFooter.textAlignment = NSTextAlignmentCenter;
    _searchFooter.text = @"清空搜索历史";
    _searchFooter.textColor = [UIColor colorWithHexString:@"666666"];
    [_searchFooter addGestureRecognizer:tap];
    self.tableView.tableFooterView = _searchFooter;
    
    
    NSArray *datas = [ATUtil mainDataList];
    NSMutableArray *names = [NSMutableArray array];
    NSMutableDictionary *dics = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in datas) {
        NSString *name = [dic objectForKey:@"XXGP_sname"];
        if (name) {
            [dics setObject:dic forKey:name.copy];
            [names addObject:name.copy];
        }
    }
    self.searchAllData = names.copy;
    self.gpcodeDatas = dics.copy;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [self.dataArray objectAtIndex:indexPath.row];
    [self jumpDetail:str];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y < - kSafeAreaNavHeight + self.searchController.searchBar.height) {
        if (y < - kSafeAreaNavHeight + self.searchController.searchBar.height * 0.5) {
            [self.tableView setContentOffset:CGPointMake(0, - kSafeAreaNavHeight) animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0, - kSafeAreaNavHeight + self.searchController.searchBar.height) animated:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;
    if (y < - kSafeAreaNavHeight + self.searchController.searchBar.height) {
        if (y < - kSafeAreaNavHeight + self.searchController.searchBar.height * 0.5) {
            [self.tableView setContentOffset:CGPointMake(0, - kSafeAreaNavHeight) animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0, - kSafeAreaNavHeight + self.searchController.searchBar.height) animated:YES];
        }
    }
}

#pragma mark - JKRSearchControllerhResultsUpdating
- (void)updateSearchResultsForSearchController:(JKRSearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF CONTAINS %@)", searchText];
    JKRSearchResultViewController *resultController = (JKRSearchResultViewController *)searchController.searchResultsController;
    if (!(searchText.length > 0)) resultController.filterDataArray = @[];
    else resultController.filterDataArray = [self.searchAllData filteredArrayUsingPredicate:predicate];
}

#pragma mark - JKRSearchControllerDelegate
- (void)willPresentSearchController:(JKRSearchController *)searchController {
    NSLog(@"willPresentSearchController, %@", searchController);
}

- (void)didPresentSearchController:(JKRSearchController *)searchController {
    NSLog(@"didPresentSearchController, %@", searchController);
}

- (void)willDismissSearchController:(JKRSearchController *)searchController {
    NSLog(@"willDismissSearchController, %@", searchController);
}

- (void)didDismissSearchController:(JKRSearchController *)searchController {
    NSLog(@"didDismissSearchController, %@", searchController);
}

#pragma mark - JKRSearchBarDelegate
- (void)searchBarTextDidBeginEditing:(JKRSearchBar *)searchBar {
    
}

- (void)searchBarTextDidEndEditing:(JKRSearchBar *)searchBar {
    
}

- (void)searchBar:(JKRSearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"searchBar:%@ textDidChange:%@", searchBar, searchText);
}


- (void)goback {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    }
    return _tableView;
}

- (JKRSearchController *)searchController {
    if (!_searchController) {
        JKRSearchResultViewController *resultSearchController = [[JKRSearchResultViewController alloc] init];
        resultSearchController.kSearchContentClick = ^(NSString *text) {
            [self updateHistoryData:text];
        };
        _searchController = [[JKRSearchController alloc] initWithSearchResultsController:resultSearchController];
        _searchController.searchBar.placeholder = @"搜索";
        _searchController.hidesNavigationBarDuringPresentation = YES;
        _searchController.searchResultsUpdater = self;
        _searchController.searchBar.delegate = self;
        _searchController.delegate = self;
    }
    return _searchController;
}

- (void)clearSearchHistory {
    [self.dataArray  removeAllObjects];
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"searchHistory"];
}

- (void)updateHistoryData:(NSString *)text {
    if (text) {
        if (![self.dataArray containsObject:text]) {
            [self.dataArray addObject:text];
            [self.tableView reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:self.dataArray.copy forKey:@"searchHistory"];
        }
        [self jumpDetail:text];
    }
}

- (void)jumpDetail:(NSString *)text {
    if (text && text.length > 0) {
        NSDictionary *dic = [self.gpcodeDatas objectForKey:text];
        NSString *gpcode = [dic objectForKey:@"code"];
//        XXGP_StockDetailViewController *detailvc = [XXGP_StockDetailViewController new];
//        detailvc.hidesBottomBarWhenPushed = YES;
//        detailvc.gpcode = gpcode;
//        [self.navigationController pushViewController:detailvc animated:YES];
    }
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchHistory"];
        if (history) {
            _dataArray = history.mutableCopy;
        } else {
            _dataArray = [NSMutableArray array];
        }
    }
    return _dataArray;
}


@end
