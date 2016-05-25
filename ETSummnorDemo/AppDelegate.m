//
//  AppDelegate.m
//  ETSummnorDemo
//
//  Created by chaoran on 16/5/25.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "AppDelegate.h"
#import "ETJSSummoner.h"
#import "JSRunner.h"
#import "ETSummonerTest.h"
#import "ETTestViewController.h"
#import "ETTestCollectionViewController.h"
#import <dlfcn.h>

@interface AppDelegate ()
@property (nonatomic,strong) UIWindow* rootWindow;
@property (nonatomic,strong) JSContext* jsContext;
@end

@implementation AppDelegate

-(UIViewController*)loadJSRootViewController
{
    _jsContext = [ETJSSummoner initJSContext];
    
    NSString* jsFilePath = [[NSBundle mainBundle]pathForResource:@"ETJSViewController" ofType:@"js"];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    [_jsContext evaluateScript:jsContent];
    
    JRPointer* jsRootViewControllerPtr = [_jsContext[@"root_view_controller"]toObject];
    
    return jsRootViewControllerPtr.obj;
}
-(UIViewController*)loadJSCollectionViewController
{
    _jsContext = [ETJSSummoner initJSContext];
    
    NSString* jsFilePath = [[NSBundle mainBundle]pathForResource:@"ETJSCollectionViewController" ofType:@"js"];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    [_jsContext evaluateScript:jsContent];
    
    JRPointer* jsRootViewControllerPtr = [_jsContext[@"root_view_controller"]toObject];
    
    return jsRootViewControllerPtr.obj;
}
-(UIViewController*)loadChannelViewController
{
    ETTestCollectionViewController* testViewController = [[ETTestCollectionViewController alloc]init];
    
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:testViewController];
    
    return nav;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
//    
    [ETSummonerTest testCallCFunctions];
//    
//    return YES;
//    void* value = dlsym(RTLD_DEFAULT, "UICollectionElementKindSectionHeader");
//    
//    void** ptr = value;
//    
//    NSString* p = (__bridge NSString*)(*ptr);
//    
//    NSLog(@"%@",p);
    
    // Override point for customization after application launch.
    
//    UIViewController* rootViewController = [self loadJSRootViewController];
    
   // UIViewController* rootViewController = [self loadChannelViewController];
    
    UIViewController* rootViewController = [self loadJSCollectionViewController];
    
    _rootWindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    _rootWindow.rootViewController = rootViewController;
    
    [_rootWindow makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
