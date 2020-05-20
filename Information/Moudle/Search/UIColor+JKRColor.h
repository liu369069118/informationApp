

#import <UIKit/UIKit.h>

@interface UIColor (JKRColor)

#define JKRColor(r,g,b,a) [UIColor jkr_colorWithRed:r green:g blue:b alpha:a]
#define JKRColorHex(_hex_) [UIColor jkr_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]

+ (UIColor *)jkr_colorWithHexString:(NSString *)hexString;
+ (UIColor *)jkr_colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

@end
