
#import <UIKit/UIKit.h>

@interface JKRSearchResultViewController : UITableViewController

@property (nonatomic, strong) NSArray<NSString *> *filterDataArray;
@property (nonatomic, copy) void(^kSearchContentClick)(NSString *text);

@end
