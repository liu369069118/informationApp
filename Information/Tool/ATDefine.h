//
//  ATDefine.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#ifndef ATDefine_h
#define ATDefine_h

#ifndef kScreenWidth
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#endif

#ifndef kScreenHeight
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#endif

#ifndef kScreenScale
#define kScreenScale [UIScreen mainScreen].scale
#endif

#define iPhoneX_Series ([ATUtil isFullScreenIPhone])

#define ATColorA(r, g, b ,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ATColor(r, g, b) ATColorA(r, g, b ,1.0f)

#define kATNavigationBarHeight (iPhoneX_Series ? 88 : 64)
#define kATStatusBarHeight (iPhoneX_Series ? 44 : 20)
#define kATIphoneXSafeMargin (iPhoneX_Series ? 34 : 0)



#endif /* ATDefine_h */
