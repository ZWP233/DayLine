//
//  AppDelegate.m
//  DayLine
//
//  Created by ZWP on 16/4/16.
//  Copyright © 2016年 TianXingJian. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "TableViewController.h"
#import <ECSlidingViewController/ECSlidingViewController.h>
@interface AppDelegate ()
@property (nonatomic,strong) ECSlidingViewController *slidingVc;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     [Parse setApplicationId:@"zUocxTMeCjblDfgppDqwycvVrW9PVXHR7vEGtRr3" clientKey:@"3CzmD5cGfH7ztP2uGco5rz6U0JFQXPPPauTXtqAx"];
    
    //初始化app窗口,将窗口设置为全屏
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //将上述窗口设置为该app唯一的主窗口，并且直接显示出来
    [self.window makeKeyAndVisible];
    LeftViewController * leftVc = [Utilities getStoryboardInstanceByIdentity:@"Main" byIdentity:@"C"];
    TableViewController * tabView = [Utilities getStoryboardInstanceByIdentity:@"Main" byIdentity:@"Tab"];
    //----------------------侧滑开始 center----------------------
    //初始化侧滑框架,并且设置中间显示的页面
    _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
    //设置侧滑 的  耗时
    _slidingVc.defaultTransitionDuration = 0.25f;
    //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
    _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    //设置上述手势的识别范围
    [tabView.view addGestureRecognizer:_slidingVc.panGesture];
    //----------------------侧滑开始 left----------------------
    _slidingVc.underLeftViewController = leftVc;
    //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
    _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuSwitchAction) name:@"MenuSwitch" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EnableGestureAction) name:@"EnableGesture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisableGestureAction) name:@"DisableGesture" object:nil];
    
//    //删除防止重名
//    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
//    //添加 此键  放进全局变量   ，之后来判断用户是否登录进入的侧滑
//    [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@NO];
    
    self.window.rootViewController = _slidingVc;
    return YES;
}

- (void) menuSwitchAction{
    NSLog(@"menu");
    //如果中间那扇门在在右侧，说明  已经被侧滑  因此需要关闭
    if (_slidingVc.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        //中间  页面向左滑
        [_slidingVc resetTopViewAnimated:YES];
    }else {
        //中间  页面向右滑
        [_slidingVc anchorTopViewToRightAnimated:YES];
    }
}
//激活 侧滑手势
- (void)EnableGestureAction{
    _slidingVc.panGesture.enabled = YES;
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "txj.DayLine" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DayLine" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DayLine.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
