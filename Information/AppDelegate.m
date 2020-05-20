//
//  AppDelegate.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "AppDelegate.h"
#import "ATRootHomePageController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ATRootHomePageController *rootVc = [[ATRootHomePageController alloc] init];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVc];
    self.window.rootViewController = rootNav;
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
