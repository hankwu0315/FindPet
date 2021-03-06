//
//  AppDelegate.m
//  FindPet
//
//  Created by user51 on 2016/11/22.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "StartViewController.h"

@interface AppDelegate (){
    NSUserDefaults *userDefaults;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    self.window.tintColor = [UIColor blackColor];
    

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void) :(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    if (![[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"userID"]) {
        
        StartViewController *startViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"startNC"];
        [self.window.rootViewController presentViewController:startViewController animated:YES completion:nil];
    }
}


@end
