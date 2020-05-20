
#import <UIKit/UIKit.h>
@class JKRSearchBar;

@protocol JKRSearchBarDelegate <NSObject>

@optional
- (void)searchBarTextDidBeginEditing:(JKRSearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(JKRSearchBar *)searchBar;
- (void)searchBar:(JKRSearchBar *)searchBar textDidChange:(NSString *)searchText;

@end

@interface JKRSearchBar : UIView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) id<JKRSearchBarDelegate> delegate;
@property (nonatomic, strong) NSString *text;

@end